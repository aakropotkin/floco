/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include "pjs-core.hh"
#include <cstdio>                                         // for snprintf
#include <filesystem>                                     // for path
#include <fstream>                                        // for ifstream
#include <initializer_list>                               // for initializer...
#include <nlohmann/detail/iterators/iter_impl.hpp>        // for iter_impl
#include <nlohmann/detail/iterators/iteration_proxy.hpp>  // for iteration_p...
#include <nlohmann/detail/json_ref.hpp>                   // for json_ref
#include <nlohmann/detail/value_t.hpp>                    // for value_t
#include <nlohmann/json.hpp>                              // for basic_json
#include <stdexcept>                                      // for invalid_arg...
#include <string>                                         // for string, bas...
#include <utility>                                        // for make_pair
#include <vector>                                         // for vector
#include "fetch.hh"                                       // for curlFile


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

/* `PjsCore' Implementations */

  void
PjsCore::init(       std::string_view   url
             , const nlohmann::json   & json
             ,       unsigned long      timestamp
             )
{
  this->url       = url;
  this->timestamp = timestamp;
  for ( auto & [key, value] : json.items() )
    {
      if ( key == "name" )              { this->name         = value; }
      else if ( key == "version" )      { this->version      = value; }
      else if ( key == "bin" )          { this->bin          = value; }
      else if ( key == "dependencies" ) { this->dependencies = value; }
      else if ( key == "os" )           { this->os           = value; }
      else if ( key == "cpu" )          { this->cpu          = value; }
      else if ( key == "engines" )      { this->engines      = value; }
      else if ( key == "devDependencies" )
        {
          this->devDependencies = value;
        }
      else if ( key == "devDependenciesMeta" )
        {
          this->devDependenciesMeta = value;
        }
      else if ( key == "peerDependencies" )
        {
          this->peerDependencies = value;
        }
      else if ( key == "peerDependenciesMeta" )
        {
          this->peerDependenciesMeta = value;
        }
    }
}


PjsCore::PjsCore( std::string_view url )
{
  std::string   tmp = std::tmpnam( nullptr );
  std::string   _url( url );
  unsigned long timestamp = std::time( nullptr );
  floco::fetch::curlFile( _url.c_str(), tmp.c_str() );
  std::ifstream f( tmp );
  nlohmann::json json = nlohmann::json::parse( f );
  f.close();
  remove( tmp.c_str() );
  this->init( url, json, timestamp );
}


/* -------------------------------------------------------------------------- */

/* `BinInfo' Implementations */

BinInfo::BinInfo( std::string_view name, std::string_view s )
{
  initByStrings( name, s );
}

BinInfo::BinInfo( const nlohmann::json & j )
{
  if ( j.type() != nlohmann::json::value_t::object )
    {
      throw std::invalid_argument(
        "BinInfo JSON without a name must be an object of strings"
      );
    }
  this->initByObject( j );
}

BinInfo::BinInfo( std::string_view name, const nlohmann::json & j )
{
  nlohmann::json::value_t t = j.type();
  if ( t == nlohmann::json::value_t::object )
    {
      this->initByObject( j );
    }
  else if ( t == nlohmann::json::value_t::string )
    {
      this->initByStrings( name, j.get<std::string_view>() );
    }
  else
    {
      throw std::invalid_argument(
        "BinInfo JSON must be a string or object of strings"
      );
    }
}

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
