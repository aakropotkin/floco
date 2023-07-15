/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include "pdef/dep-info.hh"


/* -------------------------------------------------------------------------- */

namespace floco {

/* -------------------------------------------------------------------------- */

  void
DepInfo::Ent::init( const nlohmann::json & j )
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
DepInfo::Ent::toJSON() const
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
to_json( nlohmann::json & j, const DepInfo::Ent & e )
{
  j = e.toJSON();
}

  void
from_json( const nlohmann::json & j, DepInfo::Ent & e )
{
  e.init( j );
}


/* -------------------------------------------------------------------------- */

DepInfo::Ent::Ent( sqlite3pp::database & db
                 , ident_view     parent_ident
                 , version_view   parent_version
                 , ident_view     ident
                 )
{
  sqlite3pp::query cmd( db, R"SQL(
    SELECT descriptor, runtime, dev, optional, bundled FROM depInfoEnts
    WHERE ( parent = ? ) AND ( ident = ? )
  )SQL" );
  std::string parent( parent_ident );
  parent += "/";
  parent += parent_version;
  cmd.bind( 1, parent,               sqlite3pp::copy );
  cmd.bind( 2, std::string( ident ), sqlite3pp::copy );
  auto rsl = cmd.begin();
  if ( rsl == cmd.end() )
    {
      std::string msg = "No such depInfoEnt: parent = '" + parent +
                        "', ident = '" + std::string( ident ) + "'.";
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
DepInfo::Ent::sqlite3Write( sqlite3pp::database & db
                          , ident_view     parent_ident
                          , version_view   parent_version
                          , ident_view     ident
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
  cmd.bind( 1, parent,               sqlite3pp::copy );
  cmd.bind( 2, std::string( ident ), sqlite3pp::copy );
  cmd.bind( 3, this->descriptor,     sqlite3pp::nocopy );
  cmd.bind( 4, this->runtime()  );
  cmd.bind( 5, this->dev()      );
  cmd.bind( 6, this->optional() );
  cmd.bind( 7, this->bundled()  );
  cmd.execute_all();
}


/* -------------------------------------------------------------------------- */

  void
DepInfo::init( const nlohmann::json & j )
{
  this->deps.clear();
  for ( auto & [ident, e] : j.items() )
    {
      this->deps.emplace( std::move( ident ), DepInfo::Ent( e ) );
    }
}


/* -------------------------------------------------------------------------- */

  nlohmann::json
DepInfo::toJSON() const
{
  nlohmann::json j = nlohmann::json::object();
  for ( auto & [ident, e] : this->deps ) { j.emplace( ident, e.toJSON() ); }
  return j;
}


/* -------------------------------------------------------------------------- */

DepInfo::DepInfo( sqlite3pp::database & db
                , ident_view            parent_ident
                , version_view          parent_version
                )
{
  sqlite3pp::query cmd( db, R"SQL(
    SELECT ident, descriptor, runtime, dev, optional, bundled FROM depInfoEnts
    WHERE ( parent = ? )
  )SQL" );
  std::string parent( parent_ident );
  parent += "/";
  parent += parent_version;
  cmd.bind( 1, parent, sqlite3pp::copy );
  for ( auto i = cmd.begin(); i != cmd.end(); ++i )
    {
      this->deps.emplace(
        ident( ( * i ).get<const char *>( 0 ) )
      , DepInfo::Ent( ( * i ).get<const char *>( 1 )
                    , ( ( * i ).get<int>( 2 ) != 0 )
                    , ( ( * i ).get<int>( 3 ) != 0 )
                    , ( ( * i ).get<int>( 4 ) != 0 )
                    , ( ( * i ).get<int>( 5 ) != 0 )
                    )
      );
    }
}


/* -------------------------------------------------------------------------- */

DepInfo::DepInfo( const db::PjsCore & pjs )
{
  auto madd = [&]( std::string_view ident )
  {
    std::string i( ident );
    if ( this->deps.find( i ) != this->deps.end() )
      {
        this->deps.emplace( std::move( i ), DepInfo::Ent() );
      }
  };

  for ( const auto & [ident, descriptor] : pjs.dependencies.items() )
    {
      madd( ident );
      this->deps.at( ident ).descriptor = descriptor;
      this->deps.at( ident )._flags.set( 0, true );
    }

  for ( const auto & [ident, descriptor] : pjs.devDependencies.items() )
    {
      madd( ident );
      this->deps.at( ident ).descriptor = descriptor;
      this->deps.at( ident )._flags.set( 1, true );
    }

  for ( const auto & [ident, meta] : pjs.devDependenciesMeta.items() )
    {
      madd( ident );
      for ( const auto & [key, value] : meta.items() )
        {
          if ( key == "optional" )
            {
              this->deps.at( ident )._flags.set( 2, true );
            }
        }
      this->deps.at( ident )._flags.set( 1, true );
    }

  // TODO: optionalDependencies
  // TODO: bundledDependencies
}


/* -------------------------------------------------------------------------- */

  void
DepInfo::sqlite3Write( sqlite3pp::database & db
                     , ident_view            parent_ident
                     , version_view          parent_version
                     ) const
{
  for ( const auto & [ident, e] : this->deps )
    {
      e.sqlite3Write( db, parent_ident, parent_version, ident );
    }
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

}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
