/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include "pdef/peer-info.hh"


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace db {

/* -------------------------------------------------------------------------- */

  void
PeerInfoEnt::init( const nlohmann::json & j )
{
  for ( auto & [key, value] : j.items() )
    {
      if ( key == "descriptor" )    { this->descriptor = std::move( value ); }
      else if ( key == "optional" ) { this->optional   = value;              }
    }
}


/* -------------------------------------------------------------------------- */

  nlohmann::json
PeerInfoEnt::toJSON() const
{
  return nlohmann::json {
    { "descriptor", this->descriptor }
  , { "optional",   this->optional   }
  };
}


/* -------------------------------------------------------------------------- */

  void
to_json( nlohmann::json & j, const PeerInfoEnt & e )
{
  j = e.toJSON();
}

  void
from_json( const nlohmann::json & j, PeerInfoEnt & e )
{
  e.init( j );
}


/* -------------------------------------------------------------------------- */

PeerInfoEnt::PeerInfoEnt( sqlite3pp::database & db
                        , floco::ident_view     parent_ident
                        , floco::version_view   parent_version
                        , floco::ident_view     ident
                        )
  : ident( ident )
{
  sqlite3pp::query cmd( db, R"SQL(
    SELECT descriptor, optional, FROM depInfoEnts
    WHERE ( parent = ? ) AND ( ident = ? )
  )SQL" );
  std::string parent( parent_ident );
  parent += "/";
  parent += parent_version;
  cmd.bind( 1, parent,      sqlite3pp::nocopy );
  cmd.bind( 2, this->ident, sqlite3pp::nocopy );
  auto rsl = cmd.begin();
  if ( rsl == cmd.end() )
    {
      std::string msg = "No such depInfoEnt: parent = '" + parent +
                        "', ident = '" + this->ident + "'.";
      throw sqlite3pp::database_error( msg.c_str() );
    }
  this->descriptor = std::string( ( * rsl ).get<const char *>( 0 ) );
  this->optional   = ( * rsl ).get<int>( 1 ) != 0;
}


/* -------------------------------------------------------------------------- */

  void
PeerInfoEnt::sqlite3Write( sqlite3pp::database & db
                        , floco::ident_view     parent_ident
                        , floco::version_view   parent_version
                        ) const
{
  sqlite3pp::command cmd( db, R"SQL(
    INSERT OR REPLACE INTO PeerInfoEnts (
      parent, ident, descriptor, optional
    ) VALUES ( ?, ?, ?, ? )
  )SQL" );
  /* We have to copy any fileds that aren't already `std::string' */
  std::string parent( parent_ident );
  parent += "/";
  parent += parent_version;
  cmd.bind( 1, parent,           sqlite3pp::nocopy );
  cmd.bind( 2, this->ident,      sqlite3pp::nocopy );
  cmd.bind( 3, this->descriptor, sqlite3pp::nocopy );
  cmd.bind( 4, this->optional );
  cmd.execute();
}


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::db' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
