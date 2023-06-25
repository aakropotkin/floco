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
  , { "runtime",    this->runtime() }
  , { "dev",        this->dev() }
  , { "optional",   this->optional() }
  , { "bundled",    this->bundled() }
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
  // TODO
}


/* -------------------------------------------------------------------------- */

  void
DepInfoEnt::sqlite3Write( sqlite3pp::database & db
                        , floco::ident_view     parent_ident
                        , floco::version_view   parent_version
                        ) const
{
  // TODO
}



/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::db' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
