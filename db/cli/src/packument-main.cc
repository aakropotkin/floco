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
#include "vinfo.hh"
#include "date.hh"

#include <ctime>
#include <map>


/* -------------------------------------------------------------------------- */

using namespace floco::db;


/* -------------------------------------------------------------------------- */

  int
main( int argc, char * argv[], char ** envp )
{
  Packument p( (std::string_view) "https://registry.npmjs.org/lodash" );
  VInfo     v( p.versions["4.17.21"].get<nlohmann::json::object_t>() );
  nlohmann::json j;
  to_json( j, v );
  std::cout << j.dump() << std::endl;
  return EXIT_SUCCESS;
}


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
