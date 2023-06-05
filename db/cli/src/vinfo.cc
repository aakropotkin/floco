/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include "vinfo.hh"
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
#include "floco-registry.hh"


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace db {

/* -------------------------------------------------------------------------- */

/* `PjsCore' Implementations */

  void
VInfo::init( const nlohmann::json & json )
{
  this->PjsCore::init( json );
  for ( auto & [key, value] : json.items() )
    {
      if ( key == "_id" )                 { this->_id            = value; }
      else if ( key == "homepage" )       { this->homepage       = value; }
      else if ( key == "description" )    { this->description    = value; }
      else if ( key == "license" )        { this->license        = value; }
      else if ( key == "repository" )     { this->repository     = value; }
      else if ( key == "dist" )           { this->dist           = value; }
      else if ( key == "_hasShrinkwrap" ) { this->_hasShrinkwrap = value; }
    }
  if ( this->_id.empty() )
    {
      this->_id = this->name + "@" + this->version;
    }
}


VInfo::VInfo( std::string_view url )
{
  this->init( floco::fetch::fetchJSON( url ) );
}


VInfo::VInfo( floco::ident_view name, floco::version_view version )
{
  this->init( floco::fetch::fetchJSON(
    floco::registry::defaultRegistry.getVInfoURL( name, version )
  ) );
}


/* -------------------------------------------------------------------------- */

  nlohmann::json
VInfo::toJSON() const
{
  nlohmann::json j;
  to_json( j, * this );
  return j;
}


/* -------------------------------------------------------------------------- */

  bool
VInfo::operator==( const VInfo & other ) const
{
  return
    ( * ( (PjsCore *) this ) ) == ( (PjsCore &) other ) &&
    /* VInfo Fields */
    ( this->_id == other._id ) &&
    ( this->homepage == other.homepage ) &&
    ( this->description == other.description ) &&
    ( this->license == other.license ) &&
    ( this->repository == other.repository ) &&
    ( this->dist == other.dist ) &&
    ( this->_hasShrinkwrap == other._hasShrinkwrap )
  ;
}

  bool
VInfo::operator!=( const VInfo & other ) const
{
  return ! ( ( * this ) == other );
}


/* -------------------------------------------------------------------------- */

// TODO: define `VInfo::init( db, _id )' as a helper for this routine, and a
// new constructor taking those args.
VInfo::VInfo( sqlite3pp::database & db
            , floco::ident_view     name
            , floco::version_view   version
            )
  : PjsCore( db, name, version )
{
  std::string _id( name );
  _id += "@";
  _id += version;
  this->_id = _id;
  sqlite3pp::query cmd( db, R"SQL(
    SELECT homepage, description, license, repository, dist, _hasShrinkwrap
    FROM VInfo WHERE ( _id = ? )
  )SQL" );
  cmd.bind( 1, _id, sqlite3pp::nocopy );
  auto rsl = * cmd.begin();

  const char * s = rsl.get<const char *>( 0 );
  if ( s != nullptr ) { this->homepage = std::string( s ); }

  s = rsl.get<const char *>( 1 );
  if ( s != nullptr ) { this->description = std::string( s ); }

  s = rsl.get<const char *>( 2 );
  if ( s != nullptr ) { this->license = std::string( s ); }

  s = rsl.get<const char *>( 3 );
  if ( s != nullptr ) { this->repository = nlohmann::json::parse( s ); }

  s = rsl.get<const char *>( 4 );
  if ( s != nullptr ) { this->dist = nlohmann::json::parse( s ); }

  this->_hasShrinkwrap = rsl.get<int>( 5 ) != 0;
}


/* -------------------------------------------------------------------------- */

  static inline int
bindStringOrNull(       sqlite3pp::command       & cmd
                ,       int                        idx
                , const std::string              & value
                ,       sqlite3pp::copy_semantic   fcopy
                )
{
  if ( value.empty() ) { return cmd.bind( idx, sqlite3pp::null_type() ); }
  else                 { return cmd.bind( idx, value, fcopy ); }
}

  void
VInfo::sqlite3Write( sqlite3pp::database & db ) const
{
  this->PjsCore::sqlite3Write( db );
  sqlite3pp::command cmd( db, R"SQL(
    INSERT OR REPLACE INTO VInfo (
      _id, homepage, description, license, repository, dist, _hasShrinkwrap
    ) VALUES ( ?, ?, ?, ?, ?, ?, ? )
  )SQL" );
  /* We have to copy any fileds that aren't already `std::string' */
  cmd.bind(              1, this->_id,               sqlite3pp::nocopy );
  bindStringOrNull( cmd, 2, this->homepage,          sqlite3pp::nocopy );
  bindStringOrNull( cmd, 3, this->description,       sqlite3pp::nocopy );
  bindStringOrNull( cmd, 4, this->license,           sqlite3pp::nocopy );
  cmd.bind(              5, this->repository.dump(), sqlite3pp::copy );
  cmd.bind(              6, this->dist.dump(),       sqlite3pp::copy );
  cmd.bind(              7, this->_hasShrinkwrap );
  cmd.execute();
}


/* -------------------------------------------------------------------------- */

  void
to_json( nlohmann::json & j, const VInfo & v )
{
  to_json( j, (const PjsCore &) v );
  j.merge_patch( {
    { "_id",            v._id }
  , { "homepage",       v.homepage }
  , { "description",    v.description }
  , { "license",        v.license }
  , { "repository",     v.repository }
  , { "dist",           v.dist }
  , { "_hasShrinkwrap", v._hasShrinkwrap }
  } );
}


/* -------------------------------------------------------------------------- */

  void
from_json( const nlohmann::json & j, VInfo & v )
{
  VInfo _v( j );
  v = _v;
}


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::db' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
