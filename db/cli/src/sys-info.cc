/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include "pdef/sys-info.hh"


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace db {

/* -------------------------------------------------------------------------- */

  nlohmann::json
SysInfoEngineEnt::toJSON() const
{
  return this->value;
}


/* -------------------------------------------------------------------------- */

  void
to_json( nlohmann::json & j, const SysInfoEngineEnt & e )
{
  j = e.toJSON();
}

  void
from_json( const nlohmann::json & j, SysInfoEngineEnt & e )
{
  e.value = j;
}


/* -------------------------------------------------------------------------- */

SysInfoEngineEnt::SysInfoEngineEnt( sqlite3pp::database & db
                                  , floco::ident_view     parent_ident
                                  , floco::version_view   parent_version
                                  , std::string_view      id
                                  )
  : id( id )
{
  sqlite3pp::query cmd( db, R"SQL(
    SELECT value FROM SysInfoEngineEnts WHERE ( parent = ? ) AND ( id ? )
  )SQL" );
  std::string parent( parent_ident );
  parent += "/";
  parent += parent_version;
  cmd.bind( 1, parent,   sqlite3pp::nocopy );
  cmd.bind( 2, this->id, sqlite3pp::nocopy );
  auto rsl = cmd.begin();
  if ( rsl == cmd.end() )
    {
      std::string msg = "No such sysInfoEnt: parent = '" + parent +
                        "', ident = '" + this->id + "'.";
      throw sqlite3pp::database_error( msg.c_str() );
    }
  this->value = nlohmann::json::parse( ( * rsl ).get<const char *>( 0 ) );
}


/* -------------------------------------------------------------------------- */

  void
SysInfoEngineEnt::sqlite3Write( sqlite3pp::database & db
                              , floco::ident_view     parent_ident
                              , floco::version_view   parent_version
                              ) const
{
  sqlite3pp::command cmd( db, R"SQL(
    INSERT OR REPLACE INTO SysInfoEngineEnts (
      parent, id, value
    ) VALUES ( ?, ?, ? )
  )SQL" );
  /* We have to copy any fileds that aren't already `std::string' */
  std::string parent( parent_ident );
  parent += "/";
  parent += parent_version;
  cmd.bind( 1, parent,                               sqlite3pp::nocopy );
  cmd.bind( 2, this->id,                             sqlite3pp::nocopy );
  cmd.bind( 3, nlohmann::json( this->value ).dump(), sqlite3pp::copy );
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
