/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include "pdef/peer-info.hh"


/* -------------------------------------------------------------------------- */

namespace floco {

/* -------------------------------------------------------------------------- */

  void
PeerInfo::Ent::init( const nlohmann::json & j )
{
  this->optional = false;
  for ( auto & [key, value] : j.items() )
    {
      if ( key == "descriptor" )    { this->descriptor = std::move( value ); }
      else if ( key == "optional" ) { this->optional   = value;              }
    }
}


/* -------------------------------------------------------------------------- */

  nlohmann::json
PeerInfo::Ent::toJSON() const
{
  return nlohmann::json {
    { "descriptor", this->descriptor }
  , { "optional",   this->optional   }
  };
}


/* -------------------------------------------------------------------------- */

  void
to_json( nlohmann::json & j, const PeerInfo::Ent & e )
{
  j = e.toJSON();
}

  void
from_json( const nlohmann::json & j, PeerInfo::Ent & e )
{
  e.init( j );
}


/* -------------------------------------------------------------------------- */

PeerInfo::Ent::Ent( sqlite3pp::database & db
                  , ident_view     parent_ident
                  , version_view   parent_version
                  , ident_view     ident
                  )
{
  sqlite3pp::query cmd( db, R"SQL(
    SELECT descriptor, optional FROM peerInfoEnts
    WHERE ( parent = ? ) AND ( ident = ? )
  )SQL" );
  std::string parent( parent_ident );
  parent += "/";
  parent += parent_version;
  cmd.bind( 1, parent,               sqlite3pp::copy );
  cmd.bind( 2, std::string( ident ), sqlite3pp::copy   );
  auto rsl = cmd.begin();
  if ( rsl == cmd.end() )
    {
      std::string msg = "No such peerInfoEnt: parent = '" + parent +
                        "', ident = '" + std::string( ident ) + "'.";
      throw sqlite3pp::database_error( msg.c_str() );
    }
  this->descriptor = std::string( ( * rsl ).get<const char *>( 0 ) );
  this->optional   = ( * rsl ).get<int>( 1 ) != 0;
}


/* -------------------------------------------------------------------------- */

  void
PeerInfo::Ent::sqlite3Write( sqlite3pp::database & db
                           , ident_view     parent_ident
                           , version_view   parent_version
                           , ident_view     ident
                           ) const
{
  sqlite3pp::command cmd( db, R"SQL(
    INSERT OR REPLACE INTO peerInfoEnts (
      parent, ident, descriptor, optional
    ) VALUES ( ?, ?, ?, ? )
  )SQL" );
  /* We have to copy any fileds that aren't already `std::string' */
  std::string parent( parent_ident );
  parent += "/";
  parent += parent_version;
  cmd.bind( 1, parent,               sqlite3pp::copy );
  cmd.bind( 2, std::string( ident ), sqlite3pp::copy );
  cmd.bind( 3, this->descriptor,     sqlite3pp::copy );
  cmd.bind( 4, this->optional );
  cmd.execute_all();
}


/* -------------------------------------------------------------------------- */

  void
PeerInfo::init( const nlohmann::json & j )
{
  this->peers.clear();
  for ( auto & [ident, e] : j.items() )
    {
      this->peers.emplace( std::move( ident ), PeerInfo::Ent( e ) );
    }
}


/* -------------------------------------------------------------------------- */

  nlohmann::json
PeerInfo::toJSON() const
{
  nlohmann::json j = nlohmann::json::object();
  for ( auto & [ident, e] : this->peers ) { j.emplace( ident, e.toJSON() ); }
  return j;
}


/* -------------------------------------------------------------------------- */

PeerInfo::PeerInfo( sqlite3pp::database & db
                  , ident_view            parent_ident
                  , version_view          parent_version
                  )
{
  sqlite3pp::query cmd( db, R"SQL(
    SELECT ident, descriptor, optional FROM peerInfoEnts WHERE ( parent = ? )
  )SQL" );
  std::string parent( parent_ident );
  parent += "/";
  parent += parent_version;
  cmd.bind( 1, parent, sqlite3pp::copy );
  for ( auto i = cmd.begin(); i != cmd.end(); ++i )
    {
      this->peers.emplace(
        ident( ( * i ).get<const char *>( 0 ) )
      , PeerInfo::Ent( ( * i ).get<const char *>( 1 )
                     , ( ( * i ).get<int>( 2 ) != 0 )
                     )
      );
    }
}


/* -------------------------------------------------------------------------- */

  void
PeerInfo::sqlite3Write( sqlite3pp::database & db
                      , ident_view            parent_ident
                      , version_view          parent_version
                      ) const
{
  for ( const auto & [ident, e] : this->peers )
    {
      e.sqlite3Write( db, parent_ident, parent_version, ident );
    }
}


/* -------------------------------------------------------------------------- */

  void
to_json( nlohmann::json & j, const PeerInfo & d )
{
  j = d.toJSON();
}


  void
from_json( const nlohmann::json & j, PeerInfo & d )
{
  d.init( j );
}


/* -------------------------------------------------------------------------- */

}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
