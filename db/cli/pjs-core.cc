#include <iostream>
#include <sqlite3.h>

  int
main( int argc, char * argv[], char ** envp )
{
  sqlite3 * DB;
  std::string sql = "CREATE TABLE PERSON ("
                    "  ID INT PRIMARY KEY   NOT NULL"
                    ", NAME     TEXT NOT NULL"
                    ", SURNAME  TEXT   NOT NULL"
                    ", AGE      INT   NOT NULL"
                    ", ADDRESS  CHAR( 50 )"
                    ", SALARY   REAL );";
  int exit = 0;
  exit = sqlite3_open( "example.db", & DB );
  char * messaggeError;
  exit = sqlite3_exec( DB, sql.c_str(), NULL, 0, &messaggeError );

  if ( exit != SQLITE_OK ) {
    std::cerr << "Error Create Table" << std::endl;
    sqlite3_free( messaggeError );
  }
  else
    std::cout << "Table created Successfully" << std::endl;
  sqlite3_close( DB );
  return 0;
}
