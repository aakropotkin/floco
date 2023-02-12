/* ========================================================================== *
 *
 * A package "manifest", being the contents of a `package.json' file.
 *
 * -------------------------------------------------------------------------- */

#include <nlohmann/json.hpp>
#include <fstream>

#include "package.hh"

/* -------------------------------------------------------------------------- */

using json = nlohmann::json;

/* -------------------------------------------------------------------------- */

namespace floco {
  namespace graph {

/* -------------------------------------------------------------------------- */

  Package
loadPackage( const std::string & path )
{
  std::ifstream f( path );
  json data = json::parse( f );

  auto _name                 = data.find( "name" );
  auto _version              = data.find( "version" );
  auto _dependencies         = data.find( "dependencies" );
  auto _devDependencies      = data.find( "devDependencies" );
  auto _peerDependencies     = data.find( "peerDependencies" );
  auto _optionalDependencies = data.find( "optionalDependencies" );
  auto _bundledDependencies  = data.find( "bundledDependencies" );

  dep_map_t dependencies;
  dep_map_t devDependencies;
  dep_map_t peerDependencies;
  dep_map_t optionalDependencies;
  dep_set_t bundledDependencies;

  if ( _dependencies == data.end() )
    {
      dependencies = {};
    }
  else
    {
      dependencies = _dependencies.value();
    }

  if ( _devDependencies == data.end() )
    {
      devDependencies = {};
    }
  else
    {
      devDependencies = _devDependencies.value();
    }

  if ( _peerDependencies == data.end() )
    {
      peerDependencies = {};
    }
  else
    {
      peerDependencies = _peerDependencies.value();
    }

  if ( _optionalDependencies == data.end() )
    {
      optionalDependencies = {};
    }
  else
    {
      optionalDependencies = _optionalDependencies.value();
    }

  if ( _bundledDependencies == data.end() )
    {
      bundledDependencies = {};
    }
  else
    {
      bundledDependencies = _bundledDependencies.value();
    }

  return Package(
    _name == data.end()    ? nullptr : _name.value()
  , _version == data.end() ? nullptr : _version.value()
  , dependencies
  , devDependencies
  , peerDependencies
  , optionalDependencies
  , bundledDependencies
  );

}

/* -------------------------------------------------------------------------- */

  };  /* End `namespace floco::graph' */
};  /* End `namespace floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
