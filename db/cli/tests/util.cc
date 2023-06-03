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

  int
main( int argc, char * argv[], char ** envp )
{
  nlohmann::json j = { { "foo", "bar" } };

  std::optional<std::string> s =
    floco::util::maybeGetJSON<std::string>( j, "foo" );

  if ( s.value_or( "NOPE" ) == "NOPE" )
    {
      std::cerr << "maybeGetJSON return 'std::nullopt' for valid key"
                << std::endl;
      return EXIT_FAILURE;
    }

  s = floco::util::maybeGetJSON<std::string>( j, "bar" );

  if ( s.value_or( "NOPE" ) != "NOPE" )
    {
      std::cerr << "maybeGetJSON didn't return 'std::nullopt' for missing key"
                << std::endl;
      return EXIT_FAILURE;
    }

  return EXIT_SUCCESS;
}


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
