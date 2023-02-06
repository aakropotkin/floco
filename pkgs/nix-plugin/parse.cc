/* ========================================================================== *
 *
 * Parse package specs, identifiers, descriptors, etc.
 *
 * -------------------------------------------------------------------------- */

#include <cstring>
#include <limits>
#include <nix/config.h>
#include <nix/cache.hh>
#include <nix/types.hh>
#include <nix/url-parts.hh>
#include <nix/url.hh>
#include <nix/util.hh>
#include <optional>
#include <nlohmann/json.hpp>
#include <fstream>
#include <regex>
#include <stdexcept>
#include <string.h>

#include "parse.hh"


/* -------------------------------------------------------------------------- */

using namespace::nix;

namespace floco::parse {

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

  static bool
isExactVersion( const std::string & v )
{
  return std::regex_match( v, npmVersionRegex );
}


/* -------------------------------------------------------------------------- */

  void
ParsedSpec::setKind()
{
  if ( this->locator.has_value() )
    {
      if ( isExactVersion( this->locator.value() ) )
        {
          this->kind = SpecKind::version;
        }
      else
        {
          // Assume that anything containing `[:/]' is a URL.
          // TODO: Write a real REGEX pattern to detect `SemVer' properly.
          if ( ( strchr( this->locator.value().c_str(), ':' ) != NULL ) ||
               ( strchr( this->locator.value().c_str(), '/' ) != NULL )
             )
            {
              this->kind = SpecKind::url;
            }
          else
            {
              this->kind = SpecKind::semver;
            }
        }
    }
  else
    {
      this->kind = SpecKind::nullspec;
    }
}


/* -------------------------------------------------------------------------- */

  void
ParsedSpec::initIdent( const std::string & ident )
{
  /* Scoped */
  if ( ( ident[0] == '@' ) || ( ident[0] == '%' ) )
    {
      if ( ident[0] == '@' )
        {
          int i = strcspn( ident.c_str(), "/" );
          this->scope = ident.substr( 1, i - 1 );
          this->bname = ident.substr( i + 1 );
        }
      else
        {
          this->scope = ident.substr( 3 );
          int i = strcspn( this->scope.value().c_str(), "%/" );
          if ( this->scope.value()[i] == '%' )
            {
              this->bname = this->scope.value().substr( i + 3 );
            }
          else
            {
              this->bname = this->scope.value().substr( i + 1 );
            }
          this->scope = this->scope.value().substr( 0, i - 1 );
        }
    }
  else
    {
      this->scope = std::nullopt;
      this->bname = ident;
    }
}


/* -------------------------------------------------------------------------- */

ParsedSpec::ParsedSpec( const std::string & raw )
{
  std::string unesc = std::regex_replace( raw, std::regex( "%40" ), "@" );
  unesc = std::regex_replace( unesc, std::regex( "\%2[fF]" ), "/" );
  auto path = tokenizeString<std::vector<std::string>>( unesc, "/" );

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
           std::regex_match( path[1], npmUnescapedBnameRegex )
         )
        {
          this->scope   = path[0].substr( 1 );
          this->bname   = path[1];
          this->locator = path[2];
        }
    }
  else if ( size == 2 )
    {
      auto spat =
        tokenizeString<std::vector<std::string>>( path[1], "@" );
      /* baz/1.0.0, %40foo%2Fbar/1.0.0, @foo%2fbar/1.0.0 */
      if ( std::regex_match( path[0], npmUnescapedBnameRegex ) )
        {
          this->scope   = std::nullopt;
          this->bname   = path[0];
          this->locator = path[1];
        }
      else if ( std::regex_match( path[0], npmUnescapedScopeRegex ) &&
                std::regex_match( spat[0], npmUnescapedBnameRegex )
              )
        {
          this->scope   = path[0].substr( 1 );
          this->bname   = path[1];
          this->locator = path[2];
        }
      else
        {
          throw std::runtime_error(
            "'" + raw + "' is not a valid <SCOPE>[@/]<VERSION> URI"
          );
        }
    }
  else if ( size == 1 )
    {
      auto spat =
        tokenizeString<std::vector<std::string>>( path[0], "@" );
      if ( std::regex_match( spat[0], npmUnescapedBnameRegex ) )
        {
          this->scope   = std::nullopt;
          this->bname   = spat[0];
          this->locator = spat[1];
        }
      else
        {
          throw std::runtime_error(
            "'" + raw + "' is not a valid <SCOPE>[@/]<VERSION> URI"
          );
        }
    }
  else
    {
      throw std::runtime_error(
        "'" + raw + "' is not a valid <SCOPE>[@/]<VERSION> URI"
      );
    }

  if ( isExactVersion( this->locator ) )
    {
      this->kind = SpecKind::version;
    }
  else
    {
      if ( ( strchr( this->locator.c_str(), ':' ) != NULL ) ||
           ( strchr( this->locator.c_str(), ':' ) != NULL )
         )
        {
          this->kind = SpecKind::url;
        }
      else
        {
          this->kind = SpecKind::semver;
        }
    }
}


/* -------------------------------------------------------------------------- */

ParsedSpec::ParsedSpec(
  const std::string & ident,
  const std::string & locator
)
{
  if ( ident[0] == '@' )
    {
      int i = strcspn( ident.c_str(), "/" );
      this->scope   = ident.substr( 1, i - 1 );
      this->bname   = ident.substr( i + 1 );
      this->locator = locator;
    }
  else
    {
      this->scope   = std::nullopt;
      this->bname   = ident;
      this->locator = locator;
    }

  if ( isExactVersion( locator ) )
    {
      this->kind = SpecKind::version;
    }
  else
    {
      if ( ( strchr( locator.c_str(), ':' ) != NULL ) ||
           ( strchr( locator.c_str(), '/' ) != NULL )
         )
        {
          this->kind = SpecKind::url;
        }
      else
        {
          this->kind = SpecKind::semver;
        }
    }
}


/* -------------------------------------------------------------------------- */

ParsedSpec::ParsedSpec(
  const std::optional<std::string> & scope,
  const std::string                & bname,
  const std::string                & locator
)
{
  this->bname   = bname;
  this->locator = locator;

  /* Handle scope part */
  if ( scope.has_value() )
    {
      if ( scope.value()[0] == '@' )
        {
          if ( scope.value().back() == '/' )
            {
              this->scope =
                scope.value().substr( 1, scope.value().size() - 1 );
            }
          else
            {
              this->scope = scope.value().substr( 1 );
            }
        }
      else
        {
          if ( scope.value().back() == '/' )
            {
              this->scope =
                scope.value().substr( 0, scope.value().size() - 1 );
            }
          else
            {
              this->scope = scope;
            }
        }
    }
  else
    {
      this->scope = scope;
    }

}



/* -------------------------------------------------------------------------- */

};  /* End Namespace `floco::parse' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
