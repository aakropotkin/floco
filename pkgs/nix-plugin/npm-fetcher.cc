/* ========================================================================== *
 *
 * Expose `npm' as a fetcher interface.
 *
 * -------------------------------------------------------------------------- */

#include <nix/config.h>
#include <nix/filetransfer.hh>
#include <nix/cache.hh>
#include <nix/store-api.hh>
#include <nix/types.hh>
#include <nix/url-parts.hh>
#include <nix/fetchers.hh>
#include <nix/fetch-settings.hh>

#include <optional>
#include <nlohmann/json.hpp>
#include <fstream>


/* -------------------------------------------------------------------------- */

namespace nix::fetchers {

/* -------------------------------------------------------------------------- */

struct DownloadUrl
{
  std::string url;
  Headers headers;
};


/* -------------------------------------------------------------------------- */

const static std::string npmVersionRegexS =
  "[0-9]+\\.[0-9]+\\.[0-9]+(-[a-zA-Z0-9._]+(\\+[a-zA-Z0-9._])?)?";
std::regex npmVersionRegex( npmVersionRegexS, std::regex::ECMAScript );

const static std::string npmEscapedIdentScopedRegexS =
  "(@|%40)[^@/\%]+\%2[fF][^@/\%]+";
std::regex npmEscapedIdentScopedRegex(
  npmEscapedIdentScopedRegexS, std::regex::ECMAScript
);

const static std::string npmUnescapedScopeRegexS = "@[^@/\%]+";
std::regex npmUnescapedScopeRegex(
  npmUnescapedScopeRegexS, std::regex::ECMAScript
);

const static std::string npmUnescapedBnameRegexS = "[^@/\%]+";
std::regex npmUnescapedBnameRegex(
  npmUnescapedBnameRegexS, std::regex::ECMAScript
);


/* -------------------------------------------------------------------------- */

struct NpmArchiveInputScheme : InputScheme
{
  const std::string type() const { return "npm"; }

    std::optional<Input>
  inputFromURL( const ParsedURL & url ) override
  {
    if ( url.scheme != type() ) return {};

    if ( url.authority && ( url.authority != "registry.npmjs.org" ) )
      {
        throw BadURL(
          " '%s', only 'registry.npmjs.org' is supported", url.url
        );
      }

    auto path = tokenizeString<std::vector<std::string>>( url.path, "/" );

    std::string ident;
    std::string version;

    auto size = path.size();
    /**
     * @foo/bar/1.0.0
     * baz/1.0.0
     * %40foo%2Fbar/1.0.0
     * @foo%2fbar/1.0.0
     */
    if ( size == 3 )
      {
        if ( std::regex_match( path[0], npmUnescapedScopeRegex ) &&
             std::regex_match( path[1], npmUnescapedBnameRegex ) &&
             std::regex_match( path[2], npmVersionRegex ) )
          {
            ident   = path[0] + "/" + path[1];
            version = path[3];
          }
        else
          {
            throw BadURL(
              "in URL '%s', '%s' is not a valid <SCOPE>[@/]<VERSION> URI",
              url.url, url.path
            );
          }
      }
    else if ( size == 2 )
      {
        auto spat =
          tokenizeString<std::vector<std::string>>( path[1], "@" );
        /* baz/1.0.0, %40foo%2Fbar/1.0.0, @foo%2fbar/1.0.0 */
        if ( std::regex_match( path[0], npmUnescapedBnameRegex ) &&
             std::regex_match( path[1], npmVersionRegex ) )
          {
            ident   = path[0];
            version = path[1];
          }
        else if ( std::regex_match( path[0], npmEscapedIdentScopedRegex ) &&
                  std::regex_match( path[1], npmVersionRegex ) )
          {
            ident = std::regex_replace( path[0], std::regex( "%40" ), "@" );
            ident = std::regex_replace(
              ident, std::regex( "\%2[fF]" ), "/"
            );
          }
        else if ( std::regex_match( path[0], npmUnescapedScopeRegex ) &&
             std::regex_match( spat[0], npmUnescapedBnameRegex ) &&
             std::regex_match( spat[1], npmVersionRegex ) )
          {
            ident   = path[0] + "/" + spat[0];
            version = spat[1];
          }
        else
          {
            throw BadURL(
              "in URL '%s', '%s' is not a valid <SCOPE>[@/]<VERSION> URI",
              url.url, url.path
            );
          }
      }
    else if ( size == 1 )
      {
        auto spat =
          tokenizeString<std::vector<std::string>>( path[0], "@" );
        if ( std::regex_match( spat[0], npmUnescapedBnameRegex ) &&
             std::regex_match( spat[1], npmVersionRegex ) )
          {
            ident   = spat[0];
            version = spat[1];
          }
        else
          {
            throw BadURL(
              "in URL '%s', '%s' is not a valid <SCOPE>[@/]<VERSION> URI",
              url.url, url.path
            );
          }
      }
    else
      {
        throw BadURL( "URL '%s' is invalid", url.url );
      }

    Input input;
    input.attrs.insert_or_assign( "type", type() );
    input.attrs.insert_or_assign( "ident", ident );
    input.attrs.insert_or_assign( "version", version );

    for ( auto &[name, value] : url.query )
      {
        if ( name == "unpack" )
          {
            input.attrs.insert_or_assign(
              "unpack",
              Explicit<bool> { ( value != "0" ) && ( value != "false" ) }
            );
          }
      }

    return input;
  }


/* -------------------------------------------------------------------------- */

    std::optional<Input>
  inputFromAttrs(const Attrs & attrs) override
  {
    if ( maybeGetStrAttr( attrs, "type" ) != type() ) return {};

    for ( auto & [name, value] : attrs )
      {
        if ( name != "type" &&
             name != "ident" &&
             name != "version" &&
             name != "narHash" &&
             name != "lastModified" &&
             name != "sha512" &&
             name != "unpack"
           )
          {
            throw Error( "unsupported input attribute '%s'", name );
          }
      }

    getStrAttr( attrs, "ident" );
    getStrAttr( attrs, "version" );
    maybeGetStrAttr( attrs, "sha512" );
    maybeGetBoolAttr( attrs, "unpack" );

    Input input;
    input.attrs = attrs;
    return input;
  }


/* -------------------------------------------------------------------------- */

    ParsedURL
  toURL( const Input & input ) override
  {
    auto ident   = getStrAttr( input.attrs, "ident");
    auto version = getStrAttr( input.attrs, "version");
    auto path    = ident + "/" + version;
    auto unpack  = maybeGetBoolAttr( input.attrs, "unpack" );
    auto url = ParsedURL {
      .scheme = type(),
      .path = path,
    };

    if ( unpack.has_value() )
      {
        url.query.insert_or_assign( "unpack", ( *unpack ) ? "1" : "0" );
      }
    return url;
  }


/* -------------------------------------------------------------------------- */

  bool hasAllInfo( const Input & input ) override { return true; }


/* -------------------------------------------------------------------------- */

    std::optional<std::string>
  getAccessToken( const std::string & host ) const
  {
    auto tokens = fetchSettings.accessTokens.get();
    if ( auto token = get( tokens, host ) )
      {
        return *token;
      }
    return {};
  }


/* -------------------------------------------------------------------------- */

    Headers
  makeHeadersWithAuthTokens( const std::string & host ) const
  {
    Headers headers;
    auto accessToken = getAccessToken(host);
    if ( accessToken )
      {
        auto hdr = std::pair<std::string, std::string>(
          "Authorization", fmt( "token %s", *accessToken )
        );
        headers.push_back( hdr );
      }
    return headers;
  }


/* -------------------------------------------------------------------------- */

    DownloadUrl
  getDownloadUrl( const Input & input )
  {
    auto ident   = getStrAttr( input.attrs, "ident" );
    auto version = getStrAttr( input.attrs, "version" );
    auto bname   =
      ident[0] == '@' ? ident.substr( ident.find_first_of( "/" ) + 1 )
                      : ident;
    auto url = fmt(
      "registry.npmjs.org/%s/-/%s-%s.tgz", ident, bname, version
    );
    // TODO
    Headers headers = makeHeadersWithAuthTokens( "registry.npmjs.org" );
    return DownloadUrl { url, headers };
  }


/* -------------------------------------------------------------------------- */

    std::pair<StorePath, Input>
  fetch( ref<Store> store, const Input & _input ) override
  {
    Input input( _input );
    auto       ident   = getStrAttr( input.attrs, "ident" );
    auto       version = getStrAttr( input.attrs, "version" );
    const bool unpack =
      maybeGetBoolAttr( input.attrs, "unpack" ).value_or( false );
    auto bname =
      ident[0] == '@' ? ident.substr( ident.find_first_of( "/" ) + 1 )
                      : ident;
    auto url  = getDownloadUrl( input );
    auto name = bname + "-" + version + ( unpack ? "" : ".tgz" );
    if ( unpack )
      {
        auto tree = downloadTarball( store, url.url, name, true ).first;
        return { std::move( tree.storePath ), input };
      }
    else
      {
        auto file = downloadFile( store, url.url, name, true );
        return { std::move( file.storePath ), input };
      }
  }


/* -------------------------------------------------------------------------- */

};  /* End `struct NpmArchiveInputScheme' */


/* -------------------------------------------------------------------------- */

static auto rNpmArchiveInputScheme = OnStartup( [] {
  registerInputScheme( std::make_unique<NpmArchiveInputScheme>() );
} );


/* -------------------------------------------------------------------------- */

};  /* End Namespace `nix::fetchers' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
