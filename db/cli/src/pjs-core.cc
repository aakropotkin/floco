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
#include <sqlite3pp.h>


/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace db {

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

PjsCore::PjsCore( sqlite3pp::database & db
                , std::string_view name
                , std::string_view version
                )
  : name( name ), version( version )
{
  sqlite3pp::query cmd(
    db
  , R"SQL(
      SELECT
          bin
        , dependencies, devDependencies, devDependenciesMeta
        , peerDependencies, peerDependenciesMeta
        , os, cpu, engines
     FROM PjsCores WHERE ( name = ? ) AND ( version = ? )
  )SQL" );
  cmd.bind( 1, this->name,    sqlite3pp::nocopy );
  cmd.bind( 2, this->version, sqlite3pp::nocopy );
  auto rsl = * cmd.begin();
  this->bin             = nlohmann::json::parse( rsl.get<const char *>( 0 ) );
  this->dependencies    = nlohmann::json::parse( rsl.get<const char *>( 1 ) );
  this->devDependencies = nlohmann::json::parse( rsl.get<const char *>( 2 ) );

  this->devDependenciesMeta =
    nlohmann::json::parse( rsl.get<const char *>( 3 ) );

  this->peerDependencies = nlohmann::json::parse( rsl.get<const char *>( 4 ) );

  this->peerDependenciesMeta =
    nlohmann::json::parse( rsl.get<const char *>( 5 ) );

  this->os      = nlohmann::json::parse( rsl.get<const char *>( 6 ) );
  this->cpu     = nlohmann::json::parse( rsl.get<const char *>( 7 ) );
  this->engines = nlohmann::json::parse( rsl.get<const char *>( 8 ) );
}


/* -------------------------------------------------------------------------- */

  void
PjsCore::sqlite3Write( sqlite3pp::database & db )
{
  sqlite3pp::command cmd( db, R"SQL(
    INSERT OR REPLACE INTO PjsCores (
      name, version, bin
    , dependencies, devDependencies, devDependenciesMeta
    , peerDependencies, peerDependenciesMeta
    , os, cpu, engines
    ) VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )
  )SQL" );
  /* We have to copy any fileds that aren't already `std::string' */
  cmd.bind(  1, this->name,                        sqlite3pp::nocopy );
  cmd.bind(  2, this->version,                     sqlite3pp::nocopy );
  cmd.bind(  3, this->bin.dump(),                  sqlite3pp::copy );
  cmd.bind(  4, this->dependencies.dump(),         sqlite3pp::copy );
  cmd.bind(  5, this->devDependencies.dump(),      sqlite3pp::copy );
  cmd.bind(  6, this->devDependenciesMeta.dump(),  sqlite3pp::copy );
  cmd.bind(  7, this->peerDependencies.dump(),     sqlite3pp::copy );
  cmd.bind(  8, this->peerDependenciesMeta.dump(), sqlite3pp::copy );
  cmd.bind(  9, this->os.dump(),                   sqlite3pp::copy );
  cmd.bind( 10, this->cpu.dump(),                  sqlite3pp::copy );
  cmd.bind( 11, this->engines.dump(),              sqlite3pp::copy );
  cmd.execute();
}


/* -------------------------------------------------------------------------- */

  void
to_json( nlohmann::json & j, const PjsCore & p )
{
  j = nlohmann::json {
    { "name",                 p.name }
  , { "version",              p.version }
  , { "bin",                  p.bin }
  , { "dependencies",         p.dependencies }
  , { "devDependencies",      p.devDependencies }
  , { "devDependenciesMeta",  p.devDependenciesMeta }
  , { "peerDependencies",     p.peerDependencies }
  , { "peerDependenciesMeta", p.peerDependenciesMeta }
  , { "os",                   p.os }
  , { "cpu",                  p.cpu }
  , { "engines",              p.engines }
  };
}


  void
from_json( const nlohmann::json & j, PjsCore & p )
{

  j.at( "name" ).get_to( p.name );
  j.at( "version" ).get_to( p.version );

  try { j.at( "bin" ).get_to( p.bin ); } catch( ... ) {}

  try
    {
      j.at( "dependencies" ).get_to( p.dependencies );
    }
  catch( ... )
    {}

  try
    {
      j.at( "devDependencies" ).get_to( p.devDependencies );
    }
  catch( ... )
    {}

  try
    {
      j.at( "devDependenciesMeta" ).get_to( p.devDependenciesMeta );
    }
  catch( ... )
    {}

  try
    {
      j.at( "peerDependencies" ).get_to( p.peerDependencies );
    }
  catch( ... )
    {}

  try
    {
      j.at( "peerDependenciesMeta" ).get_to( p.peerDependenciesMeta );
    }
  catch( ... )
    {}

  try { j.at( "os" ).get_to( p.os ); }           catch( ... ) {}
  try { j.at( "cpu" ).get_to( p.cpu ); }         catch( ... ) {}
  try { j.at( "engines" ).get_to( p.engines ); } catch( ... ) {}

}



/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::db' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
