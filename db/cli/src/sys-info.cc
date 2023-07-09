/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include "pdef/sys-info.hh"


/* -------------------------------------------------------------------------- */

namespace floco {

/* -------------------------------------------------------------------------- */

  void
SysInfo::init( const nlohmann::json & j )
{
  this->cpu.clear();
  this->os.clear();
  this->engines.clear();
  for ( auto & [key, value] : j.items() )
    {
      if ( key == "os" )           { this->os      = value; }
      else if ( key == "cpu" )     { this->cpu     = value; }
      else if ( key == "engines" ) { this->engines = value; }
    }
}


/* -------------------------------------------------------------------------- */

SysInfo::SysInfo( sqlite3pp::database & db
                , ident_view            parent_ident
                , version_view          parent_version
                )
{
  sqlite3pp::query coreCmd( db, R"SQL(
    SELECT sysInfo_cpu, sysInfo_os FROM pdefs
    WHERE ( ident = ? ) AND ( version = ? )
  )SQL" );
  sqlite3pp::query engsCmd( db, R"SQL(
    SELECT id, value FROM sysInfoEngineEnts WHERE ( parent = ? )
  )SQL" );

  std::string parent( parent_ident );
  parent += "/";
  parent += parent_version;

  coreCmd.bind( 1, std::string( parent_ident ),   sqlite3pp::copy );
  coreCmd.bind( 2, std::string( parent_version ), sqlite3pp::copy );
  engsCmd.bind( 1, parent,                        sqlite3pp::copy );

  auto rsl = coreCmd.begin();
  if ( rsl == coreCmd.end() )
    {
      std::string msg = "No such pdef: '" + parent + "'.";
      throw sqlite3pp::database_error( msg.c_str() );
    }

  this->cpu = nlohmann::json::parse( ( * rsl ).get<const char *>( 0 ) );
  this->os  = nlohmann::json::parse( ( * rsl ).get<const char *>( 1 ) );

  for ( rsl = engsCmd.begin(); rsl != engsCmd.end(); ++rsl )
    {
      this->engines.emplace(
        std::string( ( * rsl ).get<const char *>( 0 ) )
      , nlohmann::json::parse( ( * rsl ).get<const char *>( 1 ) )
      );
    }
}


/* -------------------------------------------------------------------------- */

  void
SysInfo::sqlite3WriteEngines( sqlite3pp::database & db
                            , ident_view            parent_ident
                            , version_view          parent_version
                            ) const
{
  /* We have to copy any fileds that aren't already `std::string' */
  std::string parent( parent_ident );
  parent += "/";
  parent += parent_version;
  for ( auto & [id, value] : this->engines )
    {
      sqlite3pp::command cmd( db, R"SQL(
        INSERT OR REPLACE INTO SysInfoEngineEnts (
          parent, id, value
        ) VALUES ( ?, ?, ? )
      )SQL" );
      cmd.bind( 1, parent,                         sqlite3pp::copy );
      cmd.bind( 2, id,                             sqlite3pp::copy );
      cmd.bind( 3, nlohmann::json( value ).dump(), sqlite3pp::copy );
      cmd.execute_all();
    }
}


  void
SysInfo::sqlite3WriteCore( sqlite3pp::database & db
                         , ident_view            parent_ident
                         , version_view          parent_version
                         ) const
{
  sqlite3pp::command cmd( db, R"SQL(
    INSERT OR REPLACE INTO pdefs (
      ident, version, sysInfo_cpu, sysInfo_os
    ) VALUES ( ?, ?, ?, ? )
  )SQL" );
  std::string parent( parent_ident );
  parent += "/";
  parent += parent_version;
  /* We have to copy any fileds that aren't already `std::string' */
  cmd.bind( 1, std::string( parent_ident ),        sqlite3pp::copy );
  cmd.bind( 2, std::string( parent_version ),      sqlite3pp::copy );
  cmd.bind( 3, nlohmann::json( this->cpu ).dump(), sqlite3pp::copy   );
  cmd.bind( 4, nlohmann::json( this->os ).dump(),  sqlite3pp::copy   );
  cmd.execute_all();
}


/* -------------------------------------------------------------------------- */

  nlohmann::json
SysInfo::toJSON() const
{
  return nlohmann::json {
    { "cpu",     this->cpu     }
  , { "os",      this->os      }
  , { "engines", this->engines }
  };
}


/* -------------------------------------------------------------------------- */

  void
to_json( nlohmann::json & j, const SysInfo & e )
{
  j = e.toJSON();
}

  void
from_json( const nlohmann::json & j, SysInfo & e )
{
  e.init( j );
}


/* -------------------------------------------------------------------------- */

}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
