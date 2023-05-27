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

#include "pjs-core.hh"
#include "floco-sql.hh"


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace db {

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
            , nlohmann::json    & pjs
            , unsigned long       timestamp
            )
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

  char ts[128] = "unixepoch()";
  if ( 0 < timestamp )
    {
      std::snprintf( ts, sizeof( ts ), "%lu", timestamp );
    }

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

/* `BinInfo' Implementations */

  void
BinInfo::initByStrings( std::string_view name, std::string_view s )
{
  if ( pathIsJSFile( s ) )
    {
      if ( name[0] == '@' )
        {
          std::filesystem::path bname( name );
          this->_binPairs.emplace( std::make_pair( bname.filename(), s ) );
        }
      else
        {
          this->_binPairs.emplace( std::make_pair( name, s ) );
        }
      this->_isPairs = true;
    }
  else
    {
      this->_binDir  = s;
      this->_isPairs = false;
    }
}

  void
BinInfo::initByObject( const nlohmann::json & j )
{
  for ( auto & [bname, path] : j.items() )
    {
      this->_binPairs.emplace( std::make_pair( bname, path ) );
    }
  this->_isPairs = true;
}


  nlohmann::json
BinInfo::toJSON() const
{
  nlohmann::json j;
  if ( this->_isPairs )
    {
      j = nlohmann::json::object();
      for ( auto & [bname, path] : this->_binPairs )
        {
          j[bname] = path;
        }
    }
  else
    {
      j = this->_binDir;
    }
  return j;
}

  std::string
BinInfo::toSQLValue() const
{
  std::string sql;
  if ( this->_isPairs )
    {
      sql = "'{";
      for ( auto & [bname, path] : this->_binPairs )
        {
          sql += "\"" + bname + "\":\"" + path + "\",";
        }
      sql[sql.length() - 1] = '}';
      sql += "'";
    }
  else
    {
      sql = "'" + this->_binDir + "'";
    }
  return sql;
}


/* -------------------------------------------------------------------------- */

/* `BinInfo' <--> JSON */

void to_json( nlohmann::json & j, const BinInfo & b ) { j = b.toJSON(); }

  void
from_json( const nlohmann::json & j, BinInfo & b )
{
  if ( j.contains( "name" ) )
    {
      if ( j.contains( "bin" ) )
        {
          b = BinInfo( j["name"].get<std::string_view>(), j["bin"] );
        }
      else
        {
          b = BinInfo();
        }
    }
  else
    {
      if ( j.contains( "bin" ) )
        {
          b = BinInfo( j["bin"] );
        }
      else
        {
          b = BinInfo( j );
        }
    }
}


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::db' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
