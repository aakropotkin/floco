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
#include "sqlite3pp.h"
#include "util.hh"
#include "floco-registry.hh"


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace db {

/* -------------------------------------------------------------------------- */

/* `PjsCore' Implementations */

  void
PjsCore::init( const nlohmann::json & json )
{
  for ( const auto & [key, value] : json.items() )
    {
      if ( key == "name" )                  { this->name             = value; }
      else if ( key == "version" )          { this->version          = value; }
      else if ( key == "bin" )              { this->bin              = value; }
      else if ( key == "os" )               { this->os               = value; }
      else if ( key == "cpu" )              { this->cpu              = value; }
      else if ( key == "engines" )          { this->engines          = value; }
      else if ( key == "engines" )          { this->engines          = value; }
      else if ( key == "scripts" )          { this->scripts          = value; }
      else if ( key == "dependencies" )     { this->dependencies     = value; }
      else if ( key == "devDependencies" )  { this->devDependencies  = value; }
      else if ( key == "peerDependencies" ) { this->peerDependencies = value; }
      else if ( key == "devDependenciesMeta" )
        {
          this->devDependenciesMeta = value;
        }
      else if ( key == "peerDependenciesMeta" )
        {
          this->peerDependenciesMeta = value;
        }
      else if ( key == "optionalDependencies" )
        {
          this->optionalDependencies = value;
        }
      else if ( key == "bundledDependencies" )
        {
          this->bundledDependencies = value;
        }
    }
}


/* -------------------------------------------------------------------------- */

PjsCore::PjsCore( std::string_view url )
{
  this->init( floco::fetch::fetchJSON( url ) );
}


/* -------------------------------------------------------------------------- */

PjsCore::PjsCore( floco::ident_view name, floco::version_view version )
{
  this->init( floco::fetch::fetchJSON(
    floco::registry::defaultRegistry.getVInfoURL( name, version )
  ) );
}


/* -------------------------------------------------------------------------- */

PjsCore::PjsCore( sqlite3pp::database & db
                , floco::ident_view     name
                , floco::version_view   version
                )
  : name( name ), version( version )
{
  sqlite3pp::query cmd( db, R"SQL(
    SELECT
      bin
    , dependencies, devDependencies, devDependenciesMeta
    , peerDependencies, peerDependenciesMeta
    , optionalDependencies, bundledDependencies
    , os, cpu, engines, scripts
    FROM PjsCore WHERE ( name = ? ) AND ( version = ? )
  )SQL" );
  cmd.bind( 1, this->name,    sqlite3pp::copy );
  cmd.bind( 2, this->version, sqlite3pp::copy );
  auto _rsl = cmd.begin();
  if ( _rsl == cmd.end() )
    {
      std::string msg = "No such PjsCore: ident = '" + this->name +
                        "', version = '" + this->version + "'.";
      throw sqlite3pp::database_error( msg.c_str() );
    }
  auto rsl              = * _rsl;
  this->bin             = nlohmann::json::parse( rsl.get<const char *>( 0 ) );
  this->dependencies    = nlohmann::json::parse( rsl.get<const char *>( 1 ) );
  this->devDependencies = nlohmann::json::parse( rsl.get<const char *>( 2 ) );

  this->devDependenciesMeta =
    nlohmann::json::parse( rsl.get<const char *>( 3 ) );

  this->peerDependencies = nlohmann::json::parse( rsl.get<const char *>( 4 ) );

  this->peerDependenciesMeta =
    nlohmann::json::parse( rsl.get<const char *>( 5 ) );

  this->optionalDependencies =
    nlohmann::json::parse( rsl.get<const char *>( 6 ) );

  this->bundledDependencies =
    nlohmann::json::parse( rsl.get<const char *>( 7 ) );

  this->os      = nlohmann::json::parse( rsl.get<const char *>(  8 ) );
  this->cpu     = nlohmann::json::parse( rsl.get<const char *>(  9 ) );
  this->engines = nlohmann::json::parse( rsl.get<const char *>( 10 ) );
  this->scripts = nlohmann::json::parse( rsl.get<const char *>( 11 ) );
}


/* -------------------------------------------------------------------------- */

  void
PjsCore::sqlite3Write( sqlite3pp::database & db ) const
{
  sqlite3pp::command cmd( db, R"SQL(
    INSERT OR REPLACE INTO PjsCore (
      name, version, bin
    , dependencies, devDependencies, devDependenciesMeta
    , peerDependencies, peerDependenciesMeta
    , optionalDependencies, bundledDependencies
    , os, cpu, engines, scripts
    ) VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )
  )SQL" );
  /* We have to copy any fileds that aren't already `std::string' */
  cmd.bind(  1, this->name,                        sqlite3pp::copy );
  cmd.bind(  2, this->version,                     sqlite3pp::copy );
  cmd.bind(  3, this->bin.dump(),                  sqlite3pp::copy );
  cmd.bind(  4, this->dependencies.dump(),         sqlite3pp::copy );
  cmd.bind(  5, this->devDependencies.dump(),      sqlite3pp::copy );
  cmd.bind(  6, this->devDependenciesMeta.dump(),  sqlite3pp::copy );
  cmd.bind(  7, this->peerDependencies.dump(),     sqlite3pp::copy );
  cmd.bind(  8, this->peerDependenciesMeta.dump(), sqlite3pp::copy );
  cmd.bind(  9, this->optionalDependencies.dump(), sqlite3pp::copy );
  cmd.bind( 10, this->bundledDependencies.dump(),  sqlite3pp::copy );
  cmd.bind( 11, this->os.dump(),                   sqlite3pp::copy );
  cmd.bind( 12, this->cpu.dump(),                  sqlite3pp::copy );
  cmd.bind( 13, this->engines.dump(),              sqlite3pp::copy );
  cmd.bind( 14, this->scripts.dump(),              sqlite3pp::copy );
  cmd.execute();
}


/* -------------------------------------------------------------------------- */

  nlohmann::json
PjsCore::toJSON() const
{
  return nlohmann::json {
    { "name",                 this->name                 }
  , { "version",              this->version              }
  , { "bin",                  this->bin                  }
  , { "dependencies",         this->dependencies         }
  , { "devDependencies",      this->devDependencies      }
  , { "devDependenciesMeta",  this->devDependenciesMeta  }
  , { "peerDependencies",     this->peerDependencies     }
  , { "peerDependenciesMeta", this->peerDependenciesMeta }
  , { "optionalDependencies", this->optionalDependencies }
  , { "bundledDependencies",  this->bundledDependencies  }
  , { "os",                   this->os                   }
  , { "cpu",                  this->cpu                  }
  , { "engines",              this->engines              }
  , { "scripts",              this->scripts              }
  };
}


/* -------------------------------------------------------------------------- */

  bool
PjsCore::hasBuildScript() const
{
  for ( const auto & [name, _] : this->scripts.items() )
    {
      if ( ( name == "prebuild"  ) ||
           ( name == "build"     ) ||
           ( name == "postbuild" )
         )
        {
          return true;
        }
    }
  return false;
}

  bool
PjsCore::hasInstallScript() const
{
  for ( const auto & [name, _] : this->scripts.items() )
    {
      if ( ( name == "preinstall"  ) ||
           ( name == "install"     ) ||
           ( name == "postinstall" )
         )
        {
          return true;
        }
    }
  return false;
}


/* -------------------------------------------------------------------------- */

  void
to_json( nlohmann::json & j, const PjsCore & p )
{
  j = p.toJSON();
}


  void
from_json( const nlohmann::json & j, PjsCore & p )
{
  p.init( j );
}


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::db' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
