/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include <stddef.h>               // for NULL
#include <iostream>               // for operator<<, endl, basic_ostream
#include <map>                    // for operator!=
#include <nlohmann/json.hpp>      // for basic_json
#include <nlohmann/json_fwd.hpp>  // for json
#include <string>                 // for allocator, basic_string, string
#include "floco-sql.hh"           // for pjsCoreSchemaSQL
#include "pjs-core.hh"            // for pjsJsonToSQL, db
#include <sqlite3pp.h>


/* -------------------------------------------------------------------------- */

using namespace floco::db;


/* -------------------------------------------------------------------------- */

  int
main( int argc, char * argv[], char ** envp )
{
  sqlite3pp::database db( "pjs-core.db" );
  db.execute( pjsCoreSchemaSQL );

  PjsCore p( (std::string_view) "https://registry.npmjs.org/lodash/4.17.21" );

  nlohmann::json j;
  to_json( j, p );

  std::cout << j.dump() << std::endl;

  p.sqlite3Write( db );

  return EXIT_SUCCESS;
}


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
