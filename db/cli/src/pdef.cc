
/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include "pdef.hh"
#include "floco/exception.hh"


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

  namespace db {

/* -------------------------------------------------------------------------- */

  void
PdefCore::reset()
{
  this->key               = "";
  this->ident             = "";
  this->version           = "0.0.0-0";
  this->ltype             = floco::LT_NONE;
  this->fetcher           = "composed";
  this->fetchInfo         = nlohmann::json::object();
  this->lifecycle.build   = false;
  this->lifecycle.install = false;
  this->binInfo.binDir    = std::nullopt;
  this->binInfo.binPairs  = std::nullopt;
  this->fsInfo.dir        = ".";
  this->fsInfo.gypfile    = false;
  this->fsInfo.shrinkwrap = false;
  this->depInfo.deps      = {};
  this->peerInfo.peers    = {};
  this->sysInfo.cpu       = { "*" };
  this->sysInfo.os        = { "*" };
  this->sysInfo.engines   = {};
}


/* -------------------------------------------------------------------------- */

  void
PdefCore::init( const nlohmann::json & j )
{
  this->reset();
  for ( auto & [key, value] : j.items() )
    {
      if ( key == "key" )     { this->key     = value; }
      if ( key == "ident" )   { this->ident   = value; }
      if ( key == "version" ) { this->version = value; }

      if ( key == "ltype" )
        {
          this->ltype = floco::parseLtype( (std::string) value );
        }

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

      if ( key == "binInfo" )
        {
          for ( auto & [bkey, bvalue] : value.items() )
            {
              if ( bkey == "binDir" )   { this->binInfo.binDir   = bvalue; }
              if ( bkey == "binPairs" ) { this->binInfo.binPairs = bvalue; }
            }
        }

      if ( key == "fsInfo" )
        {
          for ( auto & [fkey, fvalue] : value.items() )
            {
              if ( fkey == "dir" )        { this->fsInfo.dir        = fvalue; }
              if ( fkey == "gypfile" )    { this->fsInfo.gypfile    = fvalue; }
              if ( fkey == "shrinkwrap" ) { this->fsInfo.shrinkwrap = fvalue; }
            }
        }

      if ( key == "depInfo" )  { from_json( value, this->depInfo );  }
      if ( key == "peerInfo" ) { from_json( value, this->peerInfo ); }
      if ( key == "sysInfo" )  { from_json( value, this->sysInfo );  }
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
