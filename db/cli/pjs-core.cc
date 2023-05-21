/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include <string>
#include <iostream>
#include <vector>

#include <sqlite3.h>
#include <nlohmann/json.hpp>

#include "floco-sql.hh"


/* -------------------------------------------------------------------------- */

static const nlohmann::json defaultPjs = {
  { "name",                 nullptr }
, { "version",              nullptr }
, { "bin",                  nullptr }
, { "dependencies",         nlohmann::json::object() }
, { "devDependencies",      nlohmann::json::object() }
, { "devDependenciesMeta",  nlohmann::json::object() }
, { "peerDependencies",     nlohmann::json::object() }
, { "peerDependenciesMeta", nlohmann::json::object() }
, { "os",                   { "*" } }
, { "cpu",                  { "*" } }
, { "engines",              nlohmann::json::object() }
};

static const std::vector<std::string> pjsKeys = {
  "name"
, "version"
, "bin"
, "dependencies"
, "devDependencies"
, "devDependenciesMeta"
, "peerDependencies"
, "peerDependenciesMeta"
, "os"
, "cpu"
, "engines"
};


/* -------------------------------------------------------------------------- */

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

  nlohmann::json full = defaultPjs;

  char ts[128];
  std::snprintf( ts, sizeof( ts ), "%lu", timestamp );

  sql += "    '" + url + "', " + ts;

  for ( auto & [key, value] : pjs.items() )
    {
      for ( auto i = pjsKeys.begin(); i != pjsKeys.end(); ++i )
        {
          if ( ( *i ) == key )
            {
              full[key] = value;
              break;
            }
        }
    }

  for ( auto key = pjsKeys.begin(); key != pjsKeys.end(); ++key )
    {
      if ( full[*key] == nullptr )
        {
          sql += ", NULL";
        }
      else
        {
          if ( full[*key].type() != nlohmann::json::value_t::string )
            {
              sql += ", '" + full[*key].dump() + "'";
            }
          else
            {
              sql += ", '" + full[*key].get<std::string>() + "'";
            }
        }
    }

  sql += " );";

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

  std::cout << pjsJsonToSQL( "https://foo.com", 0, o ) << std::endl;

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
