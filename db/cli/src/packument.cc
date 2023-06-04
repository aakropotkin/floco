/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include "fetch.hh"
#include "packument.hh"
#include "date.hh"
#include <map>
#include <string>
#include <nlohmann/json.hpp>      // for basic_json
#include <nlohmann/json_fwd.hpp>  // for json
#include "util.hh"

/* -------------------------------------------------------------------------- */

namespace floco {
  namespace db {

/* -------------------------------------------------------------------------- */

PackumentVInfo::PackumentVInfo( const Packument     & p
                              , floco::version_view   version
                              )
  : time( p.time.at( std::string( version ) ) )
  , VInfo( p.versions.at( std::string( version ) ) )
{
  for ( auto & [tag, v] : p.dist_tags )
    {
      if ( v == version )
        {
          this->distTags.emplace( tag );
        }
    }
}


/* -------------------------------------------------------------------------- */

  void
Packument::init( const nlohmann::json & j )
{
  try
    {
      j.at( "_id" ).get_to( this->_id );
    }
  catch ( nlohmann::json::out_of_range & e )
    {
      j.at( "name" ).get_to( this->_id );
    }

  try
    {
      j.at( "name" ).get_to( this->name );
    }
  catch ( nlohmann::json::out_of_range & e )
    {
      j.at( "_id" ).get_to( this->name );
    }

  floco::util::tryGetJSONTo( j, "_rev",      this->_rev );
  floco::util::tryGetJSONTo( j, "time",      this->time );
  floco::util::tryGetJSONTo( j, "dist-tags", this->dist_tags );
  floco::util::tryGetJSONTo( j, "versions",  this->versions );

  for ( auto & [version, vj] : this->versions )
    {
      this->vinfos.emplace( version, PackumentVInfo( * this, version ) );
    }

}


/* -------------------------------------------------------------------------- */

Packument::Packument( std::string_view url )
  : Packument( floco::fetch::fetchJSON( url ) )
{}


/* -------------------------------------------------------------------------- */

  std::map<floco::version_view, floco::timestamp_view>
Packument::versionsBefore( floco::timestamp_view before ) const
{
  std::tm b = floco::util::parseDateTime( before );

  std::map<floco::version_view, floco::timestamp_view> keeps;

  for ( auto & [version, timestamp] : this->time )
    {
      if ( floco::util::dateBefore( b, timestamp ) )
        {
          keeps.emplace( version, timestamp );
        }
    }

  return keeps;
}


/* -------------------------------------------------------------------------- */

  nlohmann::json
Packument::toJSON() const
{
  nlohmann::json j;
  to_json( j, * this );
  return j;
}


/* -------------------------------------------------------------------------- */

  bool
Packument::operator==( const Packument & other ) const
{
  return
    ( this->_id == other._id ) &&
    ( this->_rev == other._rev ) &&
    ( this->name == other.name ) &&
    ( this->time == other.time ) &&
    ( this->dist_tags == other.dist_tags ) &&
    ( this->versions == other.versions )
  ;
}


  bool
Packument::operator!=( const Packument & other ) const
{
  return ! ( ( * this ) == other );
}


/* -------------------------------------------------------------------------- */

  void
to_json( nlohmann::json & j, const Packument & p )
{
  j = nlohmann::json {
    { "_id",       p._id }
  , { "_rev",      p._rev }
  , { "name",      p.name }
  , { "time",      p.time }
  , { "dist-tags", p.dist_tags }
  , { "versions",  p.versions }
  };
}

  void
from_json( const nlohmann::json & j, Packument & p )
{
  Packument _p( j );
  p = _p;
}


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::db' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
