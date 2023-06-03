/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include <stddef.h>               // for NULL
#include <iostream>               // for operator<<, endl, basic_ostream
#include <nlohmann/json.hpp>      // for basic_json
#include <optional>
#include <string>                 // for allocator, basic_string, string
#include "pjs-core.hh"


/* -------------------------------------------------------------------------- */

enum test_status { pass = EXIT_SUCCESS, fail = EXIT_FAILURE, error };

struct TestResult {
  test_status s   = test_status::error;
  std::string msg = "UNSET";
  TestResult() : s( test_status::pass ), msg( "PASS" ) {}

  TestResult( test_status s ) : s( s )
  {
    if ( s == test_status::pass )       { this->msg = "PASS"; }
    else if ( s == test_status::error ) { this->msg = "ERROR"; }
    else                                { this->msg = "FAIL"; }
  }

  TestResult( test_status s, std::string_view msg ) : s( s ), msg( msg ) {}
  TestResult( test_status s, const char * msg ) : s( s ), msg( msg ) {}
  TestResult( std::string_view msg ) : s( test_status::fail ), msg( msg ) {}
  TestResult( const char * msg )     : s( test_status::fail ), msg( msg ) {}
};


/* -------------------------------------------------------------------------- */

  TestResult
test_PjsCore_constructorsRegistry()
{
  try
    {
      floco::db::PjsCore p0(
        (std::string_view) "https://registry.npmjs.org/lodash/4.17.21"
      );
      floco::db::PjsCore p1( "lodash", "4.17.21" );
      if ( p0 != p1 )
        {
          return TestResult(
            "PjsCore constructors registry URLs produced different results"
          );
        }
    }
  catch( ... )
    {
      return TestResult(
        test_status::error
      , "ERROR: Failed to construct PjsCore(s) from registry fetcher(s)"
      );
    }
  return TestResult();
}



/* -------------------------------------------------------------------------- */

  int
main( int argc, char * argv[], char ** envp )
{
  test_status ec = test_status::pass;
  TestResult  rsl( test_status::error );

  rsl = test_PjsCore_constructorsRegistry();

  if ( rsl.s != test_status::pass )
    {
      std::cerr << rsl.msg << std::endl;
      if ( ec != test_status::error )
        {
          ec = test_status::fail;
        }
    }

  return (int) ec;
}


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
