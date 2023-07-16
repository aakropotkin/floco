/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include "pdef/bin-info.hh"


/* -------------------------------------------------------------------------- */

namespace floco {

/* -------------------------------------------------------------------------- */

  void
BinInfo::init( const nlohmann::json & j )
{
  this->reset();
  for ( const auto & [key, value] : j.items() )
    {
      if ( ( key == "binDir" ) && value.is_string() )
        {
          this->binDir = value;
        }
      else if ( ( key == "binPairs" ) && value.is_object() )
        {
          this->binPairs = value;
        }
    }
}


/* -------------------------------------------------------------------------- */

BinInfo::BinInfo( sqlite3pp::database & db
                , ident_view            parent_ident
                , version_view          parent_version
                )
{
  sqlite3pp::query cmd( db, R"SQL(
    SELECT binInfo_binDir, binInfo_binPairs FROM pdefs
    WHERE ( ident = ? ) AND ( version = ? )
  )SQL" );

  std::string parent( parent_ident );
  parent += "/";
  parent += parent_version;

  cmd.bind( 1, std::string( parent_ident ),   sqlite3pp::copy );
  cmd.bind( 2, std::string( parent_version ), sqlite3pp::copy );

  auto rsl = cmd.begin();
  if ( rsl == cmd.end() )
    {
      std::string msg = "No such pdef: '" + parent + "'.";
      throw sqlite3pp::database_error( msg.c_str() );
    }

  try          { this->binDir = ( * rsl ).get<const char *>( 0 ); }
  catch( ... ) { this->binDir = std::nullopt;             }

  try
    {
      std::string bps = ( * rsl ).get<const char *>( 1 );
      this->binPairs = nlohmann::json::parse( std::move( bps ) );
    }
  catch( ... )
    {
      this->binPairs = std::nullopt;
    }
}


/* -------------------------------------------------------------------------- */

  BinInfo &
BinInfo::operator=( const db::PjsCore & pjs )
{
  this->reset();
  if ( pjs.bin.is_object() )
    {
      this->binPairs = pjs.bin;
    }
  else
    {
      assert( pjs.bin.is_string() );  /* TODO: throw */
      if ( pjs.bin.get<std::string_view>().ends_with( ".js" ) )
        {
          this->binPairs = (std::unordered_map<std::string, std::string>) {
            { pjs.name, pjs.bin.get<std::string>() }
          };
        }
      else
        {
          this->binDir = pjs.bin;
        }
    }
  return * this;
}


/* -------------------------------------------------------------------------- */

  void
BinInfo::sqlite3Write( sqlite3pp::database & db
                     , ident_view            parent_ident
                     , version_view          parent_version
                     ) const
{
  sqlite3pp::command cmd( db, R"SQL(
    INSERT OR REPLACE INTO pdefs (
      ident, version, binInfo_binDir, binInfo_binPairs
    ) VALUES ( ?, ?, ?, ? )
  )SQL" );
  std::string parent( parent_ident );
  parent += "/";
  parent += parent_version;
  /* We have to copy any fileds that aren't already `std::string' */
  cmd.bind( 1, std::string( parent_ident ),   sqlite3pp::copy );
  cmd.bind( 2, std::string( parent_version ), sqlite3pp::copy );
  if ( this->binDir.has_value() )
    {
      cmd.bind( 3, this->binDir.value(), sqlite3pp::nocopy );
    }
  else
    {
      cmd.bind( 3 );
    }

  if ( this->binPairs.has_value() )
    {
      nlohmann::json pairs = this->binPairs.value();
      cmd.bind( 4, pairs.dump(), sqlite3pp::copy );
    }
  else
    {
      cmd.bind( 4 );
    }
  cmd.execute_all();
}


/* -------------------------------------------------------------------------- */

  nlohmann::json
BinInfo::toJSON() const
{
  nlohmann::json j = {
    { "binDir",   nlohmann::json() }
  , { "binPairs", nlohmann::json() }
  };

  if ( this->binDir.has_value() )   { j["binDir"] = this->binDir.value();     }
  if ( this->binPairs.has_value() ) { j["binPairs"] = this->binPairs.value(); }

  return std::move( j );
}


/* -------------------------------------------------------------------------- */

  void
to_json( nlohmann::json & j, const BinInfo & e )
{
  j = e.toJSON();
}

  void
from_json( const nlohmann::json & j, BinInfo & e )
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
