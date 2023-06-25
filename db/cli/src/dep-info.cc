/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include "pdef/dep-info.hh"


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace db {

/* -------------------------------------------------------------------------- */

  void
DepInfoEnt::init( const nlohmann::json & j )
{
  this->_flags = 0b0100;
  for ( auto & [key, value] : j.items() )
    {
      if ( key == "descriptor" )    { this->descriptor = std::move( value ); }
      else if ( key == "runtime" )  { this->_flags.set( 0, value );          }
      else if ( key == "dev" )      { this->_flags.set( 1, value );          }
      else if ( key == "optional" ) { this->_flags.set( 2, value );          }
      else if ( key == "bundled" )  { this->_flags.set( 3, value );          }
    }
}


/* -------------------------------------------------------------------------- */

  nlohmann::json
DepInfoEnt::toJSON() const
{
  return nlohmann::json {
    { "descriptor", this->descriptor }
  , { "runtime",    this->runtime()  }
  , { "dev",        this->dev()      }
  , { "optional",   this->optional() }
  , { "bundled",    this->bundled()  }
  };
}


/* -------------------------------------------------------------------------- */

  void
to_json( nlohmann::json & j, const DepInfoEnt & e )
{
  j = e.toJSON();
}

  void
from_json( const nlohmann::json & j, DepInfoEnt & e )
{
  e.init( j );
}


/* -------------------------------------------------------------------------- */

DepInfoEnt::DepInfoEnt( sqlite3pp::database & db
                      , floco::ident_view     parent_ident
                      , floco::version_view   parent_version
                      , floco::ident_view     ident
                      )
  : ident( ident )
{
  sqlite3pp::query cmd( db, R"SQL(
    SELECT descriptor, runtime, dev, optional, bundled FROM depInfoEnts
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
  this->initFlags(
    ( ( * rsl ).get<int>( 1 ) != 0 )
  , ( ( * rsl ).get<int>( 2 ) != 0 )
  , ( ( * rsl ).get<int>( 3 ) != 0 )
  , ( ( * rsl ).get<int>( 4 ) != 0 )
  );
}


/* -------------------------------------------------------------------------- */

  void
DepInfoEnt::sqlite3Write( sqlite3pp::database & db
                        , floco::ident_view     parent_ident
                        , floco::version_view   parent_version
                        ) const
{
  sqlite3pp::command cmd( db, R"SQL(
    INSERT OR REPLACE INTO depInfoEnts (
      parent, ident, descriptor, runtime, dev, optional, bundled
    ) VALUES ( ?, ?, ?, ?, ?, ?, ? )
  )SQL" );
  /* We have to copy any fileds that aren't already `std::string' */
  std::string parent( parent_ident );
  parent += "/";
  parent += parent_version;
  cmd.bind( 1, parent,           sqlite3pp::nocopy );
  cmd.bind( 2, this->ident,      sqlite3pp::nocopy );
  cmd.bind( 3, this->descriptor, sqlite3pp::nocopy );
  cmd.bind( 4, this->runtime()  );
  cmd.bind( 5, this->dev()      );
  cmd.bind( 6, this->optional() );
  cmd.bind( 7, this->bundled()  );
  cmd.execute();
}


/* -------------------------------------------------------------------------- */

  void
DepInfo::init( const nlohmann::json & j )
{
  this->deps.clear();
  for ( auto & [ident, e] : j.items() )
    {
      DepInfoEnt d( ident, e );
      this->deps.emplace( floco::ident_view( d.ident ), std::move( d ) );
    }
}


/* -------------------------------------------------------------------------- */

DepInfo::DepInfo( const std::list<DepInfoEnt> & deps )
{
  for ( const auto & _d : deps )
    {
      DepInfoEnt d( _d );
      this->deps.emplace( floco::ident_view( d.ident ), std::move( d ) );
    }
}


/* -------------------------------------------------------------------------- */

DepInfo::DepInfo( sqlite3pp::database & db
                , floco::ident_view     parent_ident
                , floco::version_view   parent_version
                )
{
  // TODO
}


/* -------------------------------------------------------------------------- */

  nlohmann::json
DepInfo::toJSON() const
{
  nlohmann::json j = nlohmann::json::object();
  for ( auto & [ident, e] : this->deps ) { j.emplace( e.ident, e ); }
  return j;
}


/* -------------------------------------------------------------------------- */

  void
DepInfo::sqlite3Write( sqlite3pp::database & db
                     , floco::ident_view     parent_ident
                     , floco::version_view   parent_version
                     ) const
{
  // TODO
}


/* -------------------------------------------------------------------------- */

  void
to_json( nlohmann::json & j, const DepInfo & d )
{
  j = d.toJSON();
}


  void
from_json( const nlohmann::json & j, DepInfo & d )
{
  d.init( j );
}


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::db' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
