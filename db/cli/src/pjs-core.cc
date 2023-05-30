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
pjsJsonToSQL( nlohmann::json & pjs )
{
  std::string sql = R"SQL(
    INSERT OR REPLACE INTO PjsCores (
      name, version, bin
    , dependencies, devDependencies, devDependenciesMeta
    , peerDependencies, peerDependenciesMeta
    , os, cpu, engines
    ) VALUES (
  )SQL";
  bool comma = false;

  nlohmann::json full = defaultPjs;

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
      if ( comma )
        {
          sql+= ", ";
        }
      else
        {
          comma = true;
        }

      if ( full[*key] == nullptr )
        {
          sql += "NULL";
        }
      else
        {
          if ( full[*key].type() != nlohmann::json::value_t::string )
            {
              sql += "'" + full[*key].dump() + "'";
            }
          else
            {
              sql += "'" + full[*key].get<std::string>() + "'";
            }
        }
    }

  sql += " );";

  return sql;
}


/* -------------------------------------------------------------------------- */

/* `PjsCore' Implementations */

  void
PjsCore::init( const nlohmann::json & json )
{
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
  this->init( floco::fetch::fetchJSON( url ) );
}


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::db' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
