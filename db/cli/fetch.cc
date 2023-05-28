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
#include <fstream>


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace fetch {

/* -------------------------------------------------------------------------- */

  int
nixDownloadFile( const char * url, const char * outFile )
{
  std::string   _url( url );

  nix::initNix();
  nix::initGC();

  nix::evalSettings.pureEval = false;

  nix::EvalState state( {}, nix::openStore() );

  std::filesystem::path outpath( outFile );

  nix::fetchers::DownloadFileResult rsl = nix::fetchers::downloadFile(
    state.store, _url, outpath.filename(), false
  );

  std::string storePath( state.store->toRealPath( rsl.storePath ) );
  std::string line;
  std::ifstream f( storePath );

  if ( outpath == "/dev/stdout" )
    {
      while ( ! ( f.fail() || f.eof() ) )
        {
          f >> line;
          std::cout << line;
        }
      return EXIT_SUCCESS;
    }
  else if ( outpath == "/dev/stderr" )
    {
      while ( ! ( f.fail() || f.eof() ) )
        {
          f >> line;
          std::cerr << line;
        }
      return EXIT_SUCCESS;
    }

  if ( std::filesystem::exists( outpath ) )
    {
      try
        {
          std::filesystem::remove( outpath );
        }
      catch( std::filesystem::filesystem_error & e )
        {
          std::cout << e.what() << std::endl;
          return EXIT_FAILURE;
        }
    }

  try
    {
      std::filesystem::create_symlink( storePath, outpath.string() );
    }
  catch( std::filesystem::filesystem_error & e )
    {
      std::cout << e.what() << std::endl;
      return EXIT_FAILURE;
    }

  return EXIT_SUCCESS;
}


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::fetch' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
