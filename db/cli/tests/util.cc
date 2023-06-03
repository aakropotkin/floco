/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include <stddef.h>               // for NULL
#include <iostream>               // for operator<<, endl, basic_ostream
#include <nlohmann/json.hpp>      // for basic_json
#include <string>                 // for allocator, basic_string, string
#include "util.hh"


/* -------------------------------------------------------------------------- */

namespace fu = floco::util;


/* -------------------------------------------------------------------------- */

  int
main( int argc, char * argv[], char ** envp )
{
  nlohmann::json j = { { "foo", 1 } };
  std::cout << j.dump() << std::endl;
  return EXIT_SUCCESS;
}


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
