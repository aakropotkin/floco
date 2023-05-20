/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include <iostream>
#include <sqlite3.h>

#include "floco-sql.hh"


/* -------------------------------------------------------------------------- */

  int
main( int argc, char * argv[], char ** envp )
{
  sqlite3     * db;
  char        * messageError;
  std::string   sql = pjsCoreSchemaSQL;
  int           err = 0;

  err = sqlite3_open( "pjs-core.db", & db );
  err = sqlite3_exec( db, sql.c_str(), NULL, 0, & messageError );

  if ( err != SQLITE_OK )
    {
      std::cerr << "Error Create Table" << std::endl;
      sqlite3_free( messageError );
    }
  else
    {
      std::cout << "Table created Successfully" << std::endl;
    }

  sqlite3_close( db );

  return err;
}


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
