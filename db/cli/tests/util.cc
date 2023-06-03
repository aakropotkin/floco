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
#include "util.hh"


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
test_maybeGetJSON()
{
  nlohmann::json j = { { "foo", "bar" } };

  std::optional<std::string> s =
    floco::util::maybeGetJSON<std::string>( j, "foo" );

  if ( s.value_or( "NOPE" ) == "NOPE" )
    {
      return TestResult( "maybeGetJSON return 'std::nullopt' for valid key" );
    }

  s = floco::util::maybeGetJSON<std::string>( j, "bar" );

  if ( s.value_or( "NOPE" ) != "NOPE" )
    {
      return TestResult(
        "maybeGetJSON didn't return 'std::nullopt' for missing key"
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

  rsl = test_maybeGetJSON();

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
