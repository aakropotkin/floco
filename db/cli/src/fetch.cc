/* ========================================================================== *
 *
 * Usage: ./fetch URL OUT-FILE;
 *
 * -------------------------------------------------------------------------- */

#include "fetch.hh"
#include <cstdio>                // for fclose, fopen, fwrite, FILE, size_t
#include <cstdlib>               // for EXIT_FAILURE, EXIT_SUCCESS, size_t
#include <functional>            // for _Placeholder, bind, _1, _2, _3, func...
#include <iostream>              // for operator<<, endl, basic_ostream, ost...
#include <memory>                // for allocator
#include <filesystem>            // for path
#include <nix/fetchers.hh>
#include <nix/eval-inline.hh>
#include <nix/store-api.hh>
#include <nix/shared.hh>
#include <nix/url.hh>
#include <fstream>
#include "floco-registry.hh"


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace fetch {

/* -------------------------------------------------------------------------- */

  std::string
fetchFile( std::string_view url )
{
  // TODO: move this so you don't re-init on every fetch.
  nix::initNix();
  nix::initGC();

  /* NOTE: Store settings use `nix::settings' not `nix::globalConfig'. */
  nix::evalSettings.pureEval = false;
  nix::settings.tarballTtl   = floco::registry::registryTTL;

  nix::EvalState         state( {}, nix::openStore() );
  nix::ParsedURL         purl = nix::parseURL( std::string( url ) );
  std::filesystem::path filepath( purl.path );
  std::string           _url( url );

  nix::fetchers::DownloadFileResult rsl = nix::fetchers::downloadFile(
    state.store, _url, filepath.filename(), false
  );

  return state.store->toRealPath( rsl.storePath );

}

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
