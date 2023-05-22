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


/* -------------------------------------------------------------------------- */

#ifndef MAIN_PROG
  #define MAIN_PROG  fetch
#endif


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

#if MAIN_PROG == fetch
  int
main( int argc, char * argv[], char ** envp )
{
  if ( argc != 3 )
    {
      std::cerr << argv[0] << ": Wrong number of arguments" << std::endl
                << argv[0] << ": Usage: " << " url file"    << std::endl;
      return EXIT_FAILURE;
    }
  return curlFile( argv[1], argv[2] );
}
#endif


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
