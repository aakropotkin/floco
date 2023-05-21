/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include <string>
#include <iostream>

#include <sqlite3.h>
#include <nlohmann/json.hpp>

#include "floco-sql.hh"


/* -------------------------------------------------------------------------- */

  static inline bool
jsonHasKey( nlohmann::json & json, const std::string & key )
{
  for ( nlohmann::json::iterator i = json.begin(); i != json.end(); ++i )
    {
      if ( i.key() == key )
        {
          return true;
        }
    }
  return false;
}


/* -------------------------------------------------------------------------- */

  void
addObjectOrEmpty(       nlohmann::json & pjs
                ,       std::string    & sql
                , const std::string    & key )
{
  if ( jsonHasKey( pjs, key ) )
    {
      sql += "'" + pjs[key].dump() + "', ";
    }
  else
    {
      sql += "'{}', ";
    }
}


  const std::string
pjsJsonToSQL( const std::string   url
            , unsigned long       timestamp
            , nlohmann::json    & pjs )
{
  std::string sql = R"SQL(
    INSERT OR REPLACE INTO PjsCores (
      url, timestamp, name, version, bin
    , dependencies, devDependencies, devDependenciesMeta
    , peerDependencies, peerDependenciesMeta
    , os, cpu, engines
    ) VALUES (
  )SQL";

  char ts[128];
  std::snprintf( ts, sizeof( ts ), "%lu", timestamp );

  sql += "    '" + url + "', " + ts + ", '";
  sql += pjs["name"].get<std::string>() + "', '";
  sql += pjs["version"].get<std::string>() + "', ";

  addObjectOrEmpty( pjs, sql, "bin" );
  addObjectOrEmpty( pjs, sql, "dependencies" );
  addObjectOrEmpty( pjs, sql, "devDependencies" );
  addObjectOrEmpty( pjs, sql, "devDependenciesMeta" );
  addObjectOrEmpty( pjs, sql, "peerDependencies" );
  addObjectOrEmpty( pjs, sql, "peerDependenciesMeta" );
  // TODO: OS
  // TODO: CPU
  addObjectOrEmpty( pjs, sql, "engines" );

  sql += ");";

  return sql;
}


/* -------------------------------------------------------------------------- */

  int
main( int argc, char * argv[], char ** envp )
{
  sqlite3 * db;
  char    * messageError;
  int       err = 0;

  nlohmann::json o;
  o["name"]    = "@floco/phony";
  o["version"] = "4.2.0";

  std::cout << pjsJsonToSQL( "foo", 0, o );

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

  sqlite3_close( db );

  return err;
}


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
