/* ========================================================================== *
 *
 * Usage: ./fetch URL OUT-FILE;
 *
 * -------------------------------------------------------------------------- */

#include <cstdlib>
#include <cstdio>
#include <cstring>

#include <curlpp/cURLpp.hpp>
#include <curlpp/Easy.hpp>
#include <curlpp/Options.hpp>
#include <curlpp/Exception.hpp>

#include "fetch.hh"


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace fetch {

/* -------------------------------------------------------------------------- */

  size_t
fileCallback( FILE * f, char * ptr, size_t size, size_t nmemb )
{
  return fwrite( ptr, size, nmemb, f );
}


/* -------------------------------------------------------------------------- */

  int
curlFile( const char * url, const char * outFile )
{
  int    ec   = EXIT_FAILURE;
  FILE * file = fopen( outFile, "w" );

  if ( ! file )
    {
      std::cerr << "Error opening " << outFile << std::endl;
      return EXIT_FAILURE;
    }

  try
    {
      curlpp::Cleanup cleaner;
      curlpp::Easy    request;

      // Set the writer callback to enable cURL to write result in a memory area
      using namespace std::placeholders;
      curlpp::options::WriteFunction * test =
        new curlpp::options::WriteFunction(
          std::bind( & fileCallback, file, _1, _2, _3 )
        );
      request.setOpt( test );

      // Setting the URL to retrive.
      request.setOpt( new curlpp::options::Url( url ) );
      request.setOpt( new curlpp::options::Verbose( false ) );
      request.perform();

      ec = EXIT_SUCCESS;
    }
  catch ( curlpp::LogicError & e )
    {
      std::cout << e.what() << std::endl;
      ec = EXIT_FAILURE;
    }
  catch ( curlpp::RuntimeError & e )
    {
      std::cout << e.what() << std::endl;
      ec = EXIT_FAILURE;
    }

  fclose( file );

  return ec;
}


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::fetch' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
