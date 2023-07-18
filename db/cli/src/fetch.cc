/* ========================================================================== *
 *
 * Usage: ./fetch URL OUT-FILE;
 *
 * -------------------------------------------------------------------------- */

#include <cstdio>
#include <cstdlib>
#include <functional>
#include <iostream>
#include <memory>
#include <filesystem>
#include <nix/fetchers.hh>
#include <nix/eval-inline.hh>
#include <nix/store-api.hh>
#include <nix/shared.hh>
#include <nix/url.hh>
#include "fetch.hh"
#include <fstream>
#include "util.hh"
#include "floco-registry.hh"


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace fetch {

/* -------------------------------------------------------------------------- */

  std::string
fetchFile( std::string_view url )
{
  util::initNix();

  nix::EvalState        state( {}, nix::openStore() );
  nix::ParsedURL        purl = nix::parseURL( std::string( url ) );
  std::filesystem::path filepath( purl.path );
  std::string           _url( url );

  nix::fetchers::DownloadFileResult rsl = nix::fetchers::downloadFile(
    state.store, _url, filepath.filename(), false
  );

  return state.store->toRealPath( rsl.storePath );

}


/* -------------------------------------------------------------------------- */

  std::string
fetchFileTo( std::string_view url, std::string_view outfile, bool link )
{
  std::string           storePath = fetchFile( url );
  std::filesystem::path outpath( outfile );

  if ( link )
    {
      if ( std::filesystem::exists( outpath ) )
        {
          try
            {
              std::filesystem::remove( outpath );
              std::filesystem::create_symlink( storePath, outfile );
            }
          catch( std::filesystem::filesystem_error & e )
            {
              std::cout << e.what() << std::endl;
            }
        }
    }
  else  /* Write */
    {
      std::ifstream f( storePath );
      std::string   of( outfile );
      std::ofstream o( of );
      std::string   line;
      while ( ! ( f.fail() || f.eof() ) )
        {
          f >> line;
          o << line;
        }
    }

  return storePath;
}


/* -------------------------------------------------------------------------- */

  nlohmann::json
fetchJSON( std::string_view url )
{
  return nlohmann::json::parse( std::ifstream( fetchFile( url ) ) );
}


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::fetch' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
