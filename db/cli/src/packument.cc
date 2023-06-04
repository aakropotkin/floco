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

// TODO: define `PackumentVInfo::init( db, _id )' as a helper for this routine,
// and a new constructor taking those args.
PackumentVInfo::PackumentVInfo( sqlite3pp::database & db
                              , floco::ident_view     name
                              , floco::version_view   version
                              )
  : VInfo( db, name, version )
{
  sqlite3pp::query cmd( db, R"SQL(
    SELECT time, distTags FROM PackumentVInfo WHERE ( _id = ? )
  )SQL" );
  cmd.bind( 1, this->_id, sqlite3pp::nocopy );
  auto rsl = * cmd.begin();

  this->time = (unsigned long) rsl.get<int>( 0 );

  const char * s = rsl.get<const char *>( 1 );
  if ( s != nullptr ) { this->distTags = nlohmann::json::parse( s ); }
}


/* -------------------------------------------------------------------------- */

  void
PackumentVInfo::sqlite3Write( sqlite3pp::database & db ) const
{
  this->VInfo::sqlite3Write( db );
  sqlite3pp::command cmd( db, R"SQL(
    INSERT OR REPLACE INTO PackumentVInfo ( _id, time, distTags )
    VALUES ( ?, ?, ? )
  )SQL" );
  cmd.bind( 1, this->_id, sqlite3pp::nocopy );
  cmd.bind( 2, (int) this->time.epoch() );

  /* We have to copy any fileds that aren't already `std::string' */
  nlohmann::json j = this->distTags;
  cmd.bind( 3, j.dump(), sqlite3pp::copy );

  cmd.execute();
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
  floco::util::tryGetJSONTo( j, "dist-tags", this->distTags );

  nlohmann::json versions;
  floco::util::tryGetJSONTo( j, "versions",  versions );

  for ( auto & [version, vj] : versions.items() )
    {
      std::unordered_set<std::string_view> distTags;
      for ( auto & [tag, v] : this->distTags )
        {
          if ( version == v )
            {
              distTags.emplace( tag );
            }
        }
      this->vinfos.emplace( version
                          , PackumentVInfo(
                              floco::util::DateTime( this->time.at( version ) )
                            , vj
                            , distTags
                            )
                          );
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
    ( this->distTags == other.distTags ) &&
    ( this->vinfos == other.vinfos )
  ;
}


  bool
Packument::operator!=( const Packument & other ) const
{
  return ! ( ( * this ) == other );
}


/* -------------------------------------------------------------------------- */

Packument::Packument( sqlite3pp::database & db
                    , floco::ident_view     name
                    )
  : _id( name ), name( name )
{
  sqlite3pp::query cmd( db, R"SQL(
    SELECT _rev, time, distTags FROM Packument WHERE ( name = ? )
  )SQL" );
  cmd.bind( 1, this->name, sqlite3pp::nocopy );
  auto rsl = * cmd.begin();

  const char * s = rsl.get<const char *>( 0 );
  if ( s != nullptr ) { this->_rev = s; }

  s = rsl.get<const char *>( 1 );
  if ( s != nullptr ) { this->time = nlohmann::json::parse( s ); }

  s = rsl.get<const char *>( 2 );
  if ( s != nullptr ) { this->distTags = nlohmann::json::parse( s ); }

  nlohmann::json j;

  for ( auto & [version, time] : this->time )
    {
      if ( ( version == "created" ) || ( version == "modified" ) )
        {
          continue;
        }
      else
        {
          this->vinfos.emplace( version, PackumentVInfo( db, name, version ) );
        }
    }
}


/* -------------------------------------------------------------------------- */

  void
Packument::sqlite3Write( sqlite3pp::database & db ) const
{
  sqlite3pp::command cmd( db, R"SQL(
    INSERT OR REPLACE INTO Packument ( _id, _rev, name, time, distTags )
    VALUES ( ?, ?, ?, ?, ? )
  )SQL" );
  cmd.bind( 1, this->_id,  sqlite3pp::nocopy );
  cmd.bind( 2, this->_rev, sqlite3pp::nocopy );
  cmd.bind( 3, this->name, sqlite3pp::nocopy );

  /* We have to copy any fileds that aren't already `std::string' */
  nlohmann::json j = this->time;
  cmd.bind( 4, j.dump(), sqlite3pp::copy );
  j = this->distTags;
  cmd.bind( 5, j.dump(), sqlite3pp::copy );

  cmd.execute();

  for ( auto & [version, pvi] : this->vinfos )
    {
      pvi.sqlite3Write( db );
    }
}


/* -------------------------------------------------------------------------- */

  void
to_json( nlohmann::json & j, const Packument & p )
{
  nlohmann::json versions = nlohmann::json::object();
  for ( auto & [version, pvi] : p.vinfos )
    {
      versions.emplace( version, pvi.toJSON() );
    }
  j = nlohmann::json {
    { "_id",       p._id }
  , { "_rev",      p._rev }
  , { "name",      p.name }
  , { "time",      p.time }
  , { "dist-tags", p.distTags }
  , { "versions",  versions }
  };
}


/* -------------------------------------------------------------------------- */

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
