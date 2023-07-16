
/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include "pdef.hh"
#include "floco/exception.hh"
#include "floco-sql.hh"


/* -------------------------------------------------------------------------- */

namespace floco {

/* -------------------------------------------------------------------------- */

  ltype
parseLtype( std::string_view l )
{
  if ( l == "file" ) { return ltype::LT_FILE; }
  if ( l == "dir" )  { return ltype::LT_DIR;  }
  if ( l == "link" ) { return ltype::LT_LINK; }
  throw floco::FlocoException(
    "parseLtype(): Invalid lifecycle type: '" + std::string( l ) + "'."
  );
}


  std::string_view
ltypeToString( const ltype & l )
{
  switch ( l )
    {
      case ltype::LT_FILE: return "file"; break;
      case ltype::LT_DIR:  return "dir";  break;
      case ltype::LT_LINK: return "link"; break;
      default:             return "NONE"; break;
    }
}


/* -------------------------------------------------------------------------- */

  void
PdefCore::reset()
{
  this->key               = {};
  this->ident             = {};
  this->version           = "0.0.0-0";
  this->ltype             = floco::LT_NONE;
  this->fetcher           = "composed";
  this->fetchInfo         = nlohmann::json::object();
  this->lifecycle.build   = false;
  this->lifecycle.install = false;
  this->binInfo.reset();
  this->fsInfo.dir        = ".";
  this->fsInfo.gypfile    = false;
  this->fsInfo.shrinkwrap = false;
  this->depInfo.reset();
  this->peerInfo.reset();
  this->sysInfo.reset();
}


/* -------------------------------------------------------------------------- */

  void
PdefCore::init( const nlohmann::json & j )
{
  this->reset();
  for ( auto & [key, value] : j.items() )
    {
      if ( key == "key" )       { this->key       = value; }
      if ( key == "ident" )     { this->ident     = value; }
      if ( key == "version" )   { this->version   = value; }
      if ( key == "ltype" )     { this->ltype     = value; }
      if ( key == "fetcher" )   { this->fetcher   = value; }
      if ( key == "fetchInfo" ) { this->fetchInfo = value; }

      if ( key == "lifecycle" )
        {
          for ( auto & [lkey, lvalue] : value.items() )
            {
              if ( lkey == "build" )   { this->lifecycle.build   = lvalue; }
              if ( lkey == "install" ) { this->lifecycle.install = lvalue; }
            }
        }

      if ( key == "binInfo" ) { from_json( value, this->binInfo ); }

      if ( key == "fsInfo" )
        {
          for ( auto & [fkey, fvalue] : value.items() )
            {
              if ( fkey == "dir" )        { this->fsInfo.dir        = fvalue; }
              if ( fkey == "gypfile" )    { this->fsInfo.gypfile    = fvalue; }
              if ( fkey == "shrinkwrap" ) { this->fsInfo.shrinkwrap = fvalue; }
            }
        }

      if ( key == "depInfo" )  { from_json( value, this->depInfo  ); }
      if ( key == "peerInfo" ) { from_json( value, this->peerInfo ); }
      if ( key == "sysInfo" )  { from_json( value, this->sysInfo  ); }
    }
}


/* -------------------------------------------------------------------------- */

  nlohmann::json
PdefCore::toJSON() const
{
  return {
    { "key",       this->key       }
  , { "ident",     this->ident     }
  , { "version",   this->version   }
  , { "type",      this->ltype     }
  , { "fetcher",   this->fetcher   }
  , { "fetchInfo", this->fetchInfo }
  , { "lifecycle", { { "build",   this->lifecycle.build   }
                   , { "install", this->lifecycle.install }
                   }
    }
  , { "binInfo", this->binInfo }
  , { "fsInfo",  { { "dir",        this->fsInfo.dir        }
                 , { "gypfile",    this->fsInfo.gypfile    }
                 , { "shrinkwrap", this->fsInfo.shrinkwrap }
                 }
    }
  , { "depInfo",  this->depInfo  }
  , { "peerInfo", this->peerInfo }
  , { "sysInfo",  this->sysInfo  }
  };
}


/* -------------------------------------------------------------------------- */

  void
from_json( const nlohmann::json & j, PdefCore & p )
{
  p.init( j );
}

  void
to_json( nlohmann::json & j, const PdefCore & p )
{
  j = p.toJSON();
}


/* -------------------------------------------------------------------------- */

  void
PdefCore::sqlite3WriteCore( sqlite3pp::database & db ) const
{
  sqlite3pp::command cmd( db, R"SQL(
    INSERT OR REPLACE INTO pdefs (
      key, ident, version, ltype, fetcher, fetchInfo
    , lifecycle_build, lifecycle_install
    , fsInfo_dir, fsInfo_gypfile, fsInfo_shrinkwrap
    ) VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )
  )SQL" );
  /* We have to copy any fileds that aren't already `std::string' */
  cmd.bind( 1, this->key,     sqlite3pp::nocopy );
  cmd.bind( 2, this->ident,   sqlite3pp::nocopy );
  cmd.bind( 3, this->version, sqlite3pp::nocopy );
  cmd.bind( 4, std::string( ltypeToString( this->ltype ) ), sqlite3pp::copy );
  cmd.bind( 5, this->fetcher, sqlite3pp::nocopy );
  std::string fetchInfoJSON = this->fetchInfo.dump();
  cmd.bind( 6, fetchInfoJSON, sqlite3pp::copy );

  cmd.bind( 7, this->lifecycle.build ? 1 : 0 );
  cmd.bind( 8, this->lifecycle.install ? 1 : 0 );

  cmd.bind(  9, this->fsInfo.dir, sqlite3pp::nocopy );
  cmd.bind( 10, this->fsInfo.gypfile    ? 1 : 0 );
  cmd.bind( 11, this->fsInfo.shrinkwrap ? 1 : 0 );

  cmd.execute_all();
}


  void
PdefCore::sqlite3Write( sqlite3pp::database & db ) const
{
  db.execute( pdefsSchemaSQL );
  this->sqlite3WriteCore( db );

  this->binInfo.sqlite3Write(        db, this->ident, this->version );
  this->depInfo.sqlite3Write(        db, this->ident, this->version );
  this->peerInfo.sqlite3Write(       db, this->ident, this->version );
  this->sysInfo.sqlite3WriteCore(    db, this->ident, this->version );
  this->sysInfo.sqlite3WriteEngines( db, this->ident, this->version );
}


/* -------------------------------------------------------------------------- */

PdefCore::PdefCore( sqlite3pp::database & db
                  , floco::ident_view     ident
                  , floco::version_view   version
                  )
  : ident( ident ), version( version )
{
  {
    sqlite3pp::query cmd( db, R"SQL(
      SELECT key, ltype, fetcher, fetchInfo
    , lifecycle_build, lifecycle_install
    , fsInfo_dir, fsInfo_gypfile, fsInfo_shrinkwrap
    FROM pdefs WHERE ( ident = ? ) AND ( version = ? )
    )SQL" );
    cmd.bind( 1, this->ident,   sqlite3pp::nocopy );
    cmd.bind( 2, this->version, sqlite3pp::nocopy );

    auto _i = cmd.begin();
    auto i  = * _i;

    this->key       = i.get<const char *>( 0 );
    this->ltype     = parseLtype( i.get<const char *>( 1 ) );
    this->fetcher   = i.get<const char *>( 2 );
    std::string fi  = i.get<const char *>( 3 );
    this->fetchInfo = nlohmann::json::parse( std::move( fi ) );

    this->lifecycle.build   = i.get<int>( 4 ) != 0;
    this->lifecycle.install = i.get<int>( 5 ) != 0;

    this->fsInfo.dir        = i.get<const char *>( 6 );
    this->fsInfo.gypfile    = i.get<int>( 7 ) != 0;
    this->fsInfo.shrinkwrap = i.get<int>( 8 ) != 0;
  }

  this->depInfo  = DepInfo(  db, this->ident, this->version );
  this->peerInfo = PeerInfo( db, this->ident, this->version );
  this->sysInfo  = SysInfo(  db, this->ident, this->version );
  this->binInfo  = BinInfo(  db, this->ident, this->version );
}


/* -------------------------------------------------------------------------- */

PdefCore::PdefCore( const db::PjsCore & pjs )
  : ident( pjs.name )
  , version( pjs.version )
  , key( pjs.name + "/" + pjs.version )
  , ltype( LT_NONE )
  , fetcher( "unknown" )
{
  this->binInfo  = pjs;
  this->depInfo  = pjs;
  this->peerInfo = pjs;
  this->sysInfo  = pjs;
}


/* -------------------------------------------------------------------------- */

  PdefCore &
PdefCore::operator=( const db::PjsCore & pjs )
{
  this->ident   = pjs.name;
  this->version = pjs.version;
  this->key     = pjs.name + "/" + pjs.version;
  /* XXX: Do not set `ltype', `fetcher', or `fetchInfo' */

  this->binInfo  = pjs;
  this->depInfo  = pjs;
  this->peerInfo = pjs;
  this->sysInfo  = pjs;

  return * this;
}


/* -------------------------------------------------------------------------- */

}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
