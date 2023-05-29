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

#include <map>


/* -------------------------------------------------------------------------- */

using namespace floco::db;


/* -------------------------------------------------------------------------- */

  int
main( int argc, char * argv[], char ** envp )
{
  //std::ifstream f( argv[1] );
  //nlohmann::json j = nlohmann::json::parse( f );
  //Packument p;
  Packument p( (std::string_view) "https://registry.npmjs.org/lodash" );

  //from_json( j, p );
  //to_json( j, p );

  //std::cout << j.dump() << std::endl;

  std::map<std::string_view, std::string_view> vs =
    p.versionsBefore( "2016-11-16T07:21:41.106Z" );

  for ( auto & [version, timestamp] : vs )
    {
      std::cout << version << ": " << timestamp << std::endl;
    }

  return EXIT_SUCCESS;
}


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
