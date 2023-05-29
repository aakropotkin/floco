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

/* -------------------------------------------------------------------------- */

namespace floco {
  namespace db {

/* -------------------------------------------------------------------------- */

Packument::Packument( const nlohmann::json & j )
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

  try { j.at( "_rev" ).get_to( this->_rev ); }           catch ( ... ) {}
  try { j.at( "time" ).get_to( this->time ); }           catch ( ... ) {}
  try { j.at( "dist-tags" ).get_to( this->dist_tags ); } catch ( ... ) {}
  try { j.at( "versions" ).get_to( this->versions ); }   catch ( ... ) {}
}


/* -------------------------------------------------------------------------- */

Packument::Packument( std::string_view url )
  : Packument( floco::fetch::fetchJSON( url ) )
{}


/* -------------------------------------------------------------------------- */

  std::map<std::string_view, std::string_view>
Packument::versionsBefore( std::string_view before )
{
  std::tm b = floco::util::parseDateTime( before );

  std::map<std::string_view, std::string_view> keeps;

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

/* TODO: Move to a common init function shared by `Packument( JSON )' */
  void
from_json( const nlohmann::json & j, Packument & p )
{
  try
    {
      j.at( "_id" ).get_to( p._id );
    }
  catch ( nlohmann::json::out_of_range & e )
    {
      j.at( "name" ).get_to( p._id );
    }

  try
    {
      j.at( "name" ).get_to( p.name );
    }
  catch ( nlohmann::json::out_of_range & e )
    {
      j.at( "_id" ).get_to( p.name );
    }

  try { j.at( "_rev" ).get_to( p._rev ); }           catch ( ... ) {}
  try { j.at( "time" ).get_to( p.time ); }           catch ( ... ) {}
  try { j.at( "dist-tags" ).get_to( p.dist_tags ); } catch ( ... ) {}
  try { j.at( "versions" ).get_to( p.versions ); }   catch ( ... ) {}
}



/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::db' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
