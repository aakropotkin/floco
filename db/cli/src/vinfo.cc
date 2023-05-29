/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include "vinfo.hh"
#include <cstdio>                                         // for snprintf
#include <filesystem>                                     // for path
#include <fstream>                                        // for ifstream
#include <initializer_list>                               // for initializer...
#include <nlohmann/detail/iterators/iter_impl.hpp>        // for iter_impl
#include <nlohmann/detail/iterators/iteration_proxy.hpp>  // for iteration_p...
#include <nlohmann/detail/json_ref.hpp>                   // for json_ref
#include <nlohmann/detail/value_t.hpp>                    // for value_t
#include <nlohmann/json.hpp>                              // for basic_json
#include <stdexcept>                                      // for invalid_arg...
#include <string>                                         // for string, bas...
#include <utility>                                        // for make_pair
#include <vector>                                         // for vector
#include "fetch.hh"                                       // for curlFile


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace db {

/* -------------------------------------------------------------------------- */

/* `PjsCore' Implementations */

  void
VInfo::init( const nlohmann::json & json )
{
  this->PjsCore::init( json );
  for ( auto & [key, value] : json.items() )
    {
      if ( key == "_id" )                 { this->_id            = value; }
      else if ( key == "homepage" )       { this->homepage       = value; }
      else if ( key == "description" )    { this->description    = value; }
      else if ( key == "license" )        { this->license        = value; }
      else if ( key == "repository" )     { this->repository     = value; }
      else if ( key == "dist" )           { this->dist           = value; }
      else if ( key == "_hasShrinkwrap" ) { this->_hasShrinkwrap = value; }
    }
  if ( this->_id.empty() )
    {
      this->_id = this->name + "@" + this->version;
    }
}


VInfo::VInfo( std::string_view url )
{
  this->init( floco::fetch::fetchJSON( url ) );
}


/* -------------------------------------------------------------------------- */

  void
to_json( nlohmann::json & j, const VInfo & v )
{
  j = nlohmann::json {
    { "_id",                  v._id }
  , { "name",                 v.name }
  , { "version",              v.version }
  , { "bin",                  v.bin }
  , { "dependencies",         v.dependencies }
  , { "devDependencies",      v.devDependencies }
  , { "devDependenciesMeta",  v.devDependenciesMeta }
  , { "peerDependencies",     v.peerDependencies }
  , { "peerDependenciesMeta", v.peerDependenciesMeta }
  , { "os",                   v.os }
  , { "cpu",                  v.cpu }
  , { "engines",              v.engines }
  , { "homepage",             v.homepage }
  , { "description",          v.description }
  , { "license",              v.license }
  , { "repository",           v.repository }
  , { "dist",                 v.dist }
  , { "_hasShrinkwrap",       v._hasShrinkwrap }
  };
}


/* -------------------------------------------------------------------------- */

  void
from_json( const nlohmann::json & j, VInfo & v )
{
  VInfo _v( j );
  v = _v;
}



/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::db' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
