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
#include <fstream>
#include "packument.hh"
#include "vinfo.hh"
#include "date.hh"
#include "floco-sql.hh"           // for packumentsSchemaSQL
#include "sqlite3pp.h"

#include <ctime>
#include <map>


/* -------------------------------------------------------------------------- */

using namespace floco::db;


/* -------------------------------------------------------------------------- */

  int
main( int argc, char * argv[], char ** envp )
{
  Packument p( (std::string_view) "https://registry.npmjs.org/lodash" );

  nlohmann::json j = p.toJSON();

  const char filename[] = "packument.db";

  int ec = EXIT_SUCCESS;

  remove( filename );
  sqlite3pp::database db( filename );
  try
    {
      db.execute( pjsCoreSchemaSQL );
      db.execute( packumentsSchemaSQL );

      p.sqlite3Write( db );

      Packument p2( db, "lodash" );

      PackumentVInfo pvi  = p.versions.at( "4.17.21" );
      PackumentVInfo pvi2 = p2.versions.at( "4.17.21" );

      if ( pvi != pvi2 )
        {
          ec = EXIT_FAILURE;
        }
    }
  catch ( std::exception & e )
    {
      std::cerr << e.what() << std::endl;
      ec = EXIT_FAILURE;
    }

  if ( ! floco::db::db_has( db, "lodash" ) )
    {
      std::cerr << "db_has( db, \"lodash\" )" << std::endl;
      ec = EXIT_FAILURE;
    }

  if ( floco::db::db_has( db, "phony" ) )
    {
      std::cerr << "db_has( db, \"phony\" )" << std::endl;
      ec = EXIT_FAILURE;
    }

  if ( ! floco::db::db_stale( db, "phony" ) )
    {
      std::cerr << "db_stale( db, \"phony\" )" << std::endl;
      ec = EXIT_FAILURE;
    }

  db.disconnect();
  remove( filename );

  return ec;
}


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
