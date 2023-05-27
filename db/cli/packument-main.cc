/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

//#include <sqlite3.h>              // for sqlite3_exec, sqlite3_free, sqlite3...
#include <stddef.h>               // for NULL
#include <iostream>               // for operator<<, endl, basic_ostream
#include <map>                    // for operator!=
#include <nlohmann/json.hpp>      // for basic_json
#include <nlohmann/json_fwd.hpp>  // for json
#include <string>                 // for allocator, basic_string, string
#include <fstream>
#include "packument.hh"


/* -------------------------------------------------------------------------- */

using namespace floco::db;


/* -------------------------------------------------------------------------- */

  int
main( int argc, char * argv[], char ** envp )
{
  std::ifstream f( argv[1] );
  nlohmann::json j = nlohmann::json::parse( f );
  Packument p;

  from_json( j, p );
  to_json( j, p );

  std::cout << j.dump() << std::endl;

  return EXIT_SUCCESS;
}


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
