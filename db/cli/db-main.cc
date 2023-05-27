/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include <sqlite3.h>              // for sqlite3_exec, sqlite3_free, sqlite3...
#include <stddef.h>               // for NULL
#include <iostream>               // for operator<<, endl, basic_ostream
#include <map>                    // for operator!=
#include <nlohmann/json.hpp>      // for basic_json
#include <nlohmann/json_fwd.hpp>  // for json
#include <string>                 // for allocator, basic_string, string
#include "floco-sql.hh"           // for pjsCoreSchemaSQL
#include "pjs-core.hh"            // for pjsJsonToSQL, db


/* -------------------------------------------------------------------------- */

using namespace floco::db;


/* -------------------------------------------------------------------------- */

  int
main( int argc, char * argv[], char ** envp )
{
  sqlite3 * db;
  char    * messageError;
  int       err = 0;

  err = sqlite3_open( "pjs-core.db", & db );
  err = sqlite3_exec( db, pjsCoreSchemaSQL, NULL, 0, & messageError );

  if ( err != SQLITE_OK )
    {
      std::cerr << "Error Create Table" << std::endl;
      sqlite3_free( messageError );
    }
  else
    {
      std::cout << "Table created Successfully" << std::endl;
    }


  /* Create a dummy row */
  nlohmann::json o;
  o["name"]    = "@floco/phony";
  o["version"] = "4.2.0";

  std::string sql = pjsJsonToSQL( "https://foo.com", o );
  err = sqlite3_exec( db, sql.c_str(), NULL, 0, & messageError );
  if ( err != SQLITE_OK )
    {
      std::cerr << "Error Inserting into Table" << std::endl;
      sqlite3_free( messageError );
    }
  else
    {
      std::cout << "Inserted into Table Successfully" << std::endl;
    }

  sqlite3_close( db );

  return err;
}


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
