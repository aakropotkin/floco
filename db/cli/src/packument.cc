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
#include "floco-registry.hh"

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
  sqlite3pp::query cmd( db
  , "SELECT time, distTags FROM PackumentVInfo WHERE ( _id = ? )"
  );
  cmd.bind( 1, this->_id, sqlite3pp::nocopy );
  auto b = cmd.begin();
  if ( b == cmd.end() )
    {
      std::string msg =
        "No such row '" + this->name + "@" + this->version + "'";
      throw sqlite3pp::database_error( msg.c_str() );
    }
  auto rsl = * b;

  this->time = (unsigned long) rsl.get<int>( 0 );

  const char * s = rsl.get<const char *>( 1 );
  if ( s != nullptr ) { this->distTags = nlohmann::json::parse( s ); }
}


/* -------------------------------------------------------------------------- */

  void
PackumentVInfo::sqlite3Write( sqlite3pp::database & db ) const
{
  this->VInfo::sqlite3Write( db );
  sqlite3pp::command cmd( db
  , "INSERT OR REPLACE INTO PackumentVInfo ( _id, time, distTags )"
    "VALUES ( ?, ?, ? )"
  );
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
  for ( auto & [key, value] : j.items() )
    {
      if ( key == "_id" )
        {
          this->_id = std::move( value );
        }
      else if ( key == "name" )
        {
          this->name = std::move( value );
        }
      else if ( key == "_rev" )
        {
          this->_rev = std::move( value );
        }
      else if ( key == "time" )
        {
          this->time = std::move( value );
        }
      else if ( key == "dist-tags" )
        {
          this->distTags = std::move( value );
        }
      else if ( key == "versions" )
        {
          for ( auto & [version, vj] : value.items() )
            {
              this->versions.emplace(
                std::move( version )
              , PackumentVInfo( (unsigned long) 0, std::move( vj ), {} )
              );
            }
        }
    }

  /* Do a second pass and inject `dist-tags' into `PackumentVInfo' records. */
  std::unordered_set<std::string_view> distTags;
  for ( auto i = this->distTags.begin(); i != this->distTags.end(); ++i )
    {
      try
        {
          this->versions.at( i->second ).distTags.emplace( i->first );
        }
      catch( const std::out_of_range & e )
        {
          /* Some versions are deprecated by deleting the `VInfo' record under
           * `versions' - while their absolute URL will still allow users to
           * see the packae, it will not appear in our record, and should be
           * scrubbed from this record. */
          this->distTags.erase( i );
        }
    }

  /* Do a second pass and inject `time' into `PackumentVInfo' records. */
  for ( auto i = this->time.begin(); i != this->time.end(); ++i )
    {
      if ( ( i->first == "created" ) || ( i->first == "modified" ) )
        {
          continue;
        }
      try
        {
          this->versions.at( i->first ).time =
            floco::util::DateTime( i->second );
        }
      catch( const std::out_of_range & e )
        {
          /* Some versions are deprecated by deleting the `VInfo' record under
           * `versions' - while their absolute URL will still allow users to
           * see the packae, it will not appear in our record, and should be
           * scrubbed from this record. */
          this->time.erase( i );
        }
    }

  /* Set `name'/`_id' if missing. */
  if ( this->_id.empty() )       { this->_id  = this->name; }
  else if ( this->name.empty() ) { this->name = this->_id;  }

}  /* End `Packument::init()' */


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
  nlohmann::json versions = nlohmann::json::object();
  for ( auto & [version, pvi] : this->versions )
    {
      versions.emplace( std::move( version ), pvi.toJSON() );
    }
  return nlohmann::json {
    { "_id",       this->_id             }
  , { "_rev",      this->_rev            }
  , { "name",      this->name            }
  , { "time",      this->time            }
  , { "dist-tags", this->distTags        }
  , { "versions",  std::move( versions ) }
  };
}


/* -------------------------------------------------------------------------- */

  bool
Packument::operator==( const Packument & other ) const
{
  return
    ( this->_id      == other._id      ) &&
    ( this->_rev     == other._rev     ) &&
    ( this->name     == other.name     ) &&
    ( this->time     == other.time     ) &&
    ( this->distTags == other.distTags ) &&
    ( this->versions == other.versions )
  ;
}


/* -------------------------------------------------------------------------- */

Packument::Packument( sqlite3pp::database & db
                    , floco::ident_view     ident
                    )
  : _id( ident ), name( ident )
{
  sqlite3pp::query cmd( db
  , "SELECT _rev, time, distTags FROM Packument WHERE ( name = ? )"
  );
  cmd.bind( 1, this->name, sqlite3pp::nocopy );

  auto b = cmd.begin();
  if ( b == cmd.end() )
    {
      std::string msg = "No such row '" + this->name + "'";
      throw sqlite3pp::database_error( msg.c_str() );
    }
  auto rsl = * b;

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
          this->versions.emplace( version
                                , PackumentVInfo( db, ident, version )
                                );
        }
    }
}


/* -------------------------------------------------------------------------- */

  void
Packument::sqlite3Write( sqlite3pp::database & db ) const
{
  sqlite3pp::command cmd( db
  , "INSERT OR REPLACE INTO Packument ( _id, _rev, name, time, distTags )"
    "VALUES ( ?, ?, ?, ?, ? )"
  );
  cmd.bind( 1, this->_id,  sqlite3pp::nocopy );
  cmd.bind( 2, this->_rev, sqlite3pp::nocopy );
  cmd.bind( 3, this->name, sqlite3pp::nocopy );

  /* We have to copy any fileds that aren't already `std::string' */
  nlohmann::json j = this->time;
  cmd.bind( 4, j.dump(), sqlite3pp::copy );
  j = this->distTags;
  cmd.bind( 5, j.dump(), sqlite3pp::copy );

  cmd.execute();

  for ( auto & [version, pvi] : this->versions )
    {
      pvi.sqlite3Write( db );
    }
}


/* -------------------------------------------------------------------------- */

  void
to_json( nlohmann::json & j, const Packument & p )
{
  j = p.toJSON();
}


/* -------------------------------------------------------------------------- */

  void
from_json( const nlohmann::json & j, Packument & p )
{
  p.init( j );
}


/* -------------------------------------------------------------------------- */

  bool
db_has( sqlite3pp::database & db, floco::ident_view ident )
{
  sqlite3pp::query cmd( db
  , "SELECT COUNT( _id ) FROM Packument WHERE ( name = ? )"
  );
  std::string _name( ident );
  cmd.bind( 1, _name, sqlite3pp::nocopy );
  auto rsl = * cmd.begin();
  return 0 < rsl.get<int>( 0 );
}


/* -------------------------------------------------------------------------- */

  bool
db_stale( sqlite3pp::database & db, floco::ident_view ident )
{
  sqlite3pp::query cmd( db
  , "SELECT _rev FROM Packument WHERE ( name = ? )"
  );
  std::string _name( ident );
  cmd.bind( 1, _name, sqlite3pp::nocopy );
  auto b = cmd.begin();
  if ( b == cmd.end() ) { return true; }
  auto rsl = * b;

  nlohmann::json j = floco::fetch::fetchJSON(
    floco::registry::defaultRegistry.getPackumentURL( ident )
  );
  if ( auto search = j.find( "_rev" ); search != j.end() )
    {
      return ( * search ) == std::string( rsl.get<const char *>( 0 ) );
    }
  else
    {
      return false;
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
