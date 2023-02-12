/* ========================================================================== *
 *
 * A package "manifest", being the contents of a `package.json' file.
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <stdexcept>

#include "types.hh"

/* -------------------------------------------------------------------------- */

namespace floco {
  namespace graph {

/* -------------------------------------------------------------------------- */

class Package {

/* -------------------------------------------------------------------------- */

  /* Data */
  ident_t   _name;
  version_t _version;
  dep_map_t _dependencies;
  dep_map_t _devDependencies;
  dep_map_t _peerDependencies;
  dep_map_t _optionalDependencies;
  dep_set_t _bundledDependencies;


/* -------------------------------------------------------------------------- */

  public:

/* -------------------------------------------------------------------------- */

    Package(
      ident_t   name                 = nullptr
    , version_t version              = nullptr
    , dep_map_t dependencies         = {}
    , dep_map_t devDependencies      = {}
    , dep_map_t peerDependencies     = {}
    , dep_map_t optionalDependencies = {}
    , dep_set_t bundledDependencies  = {}
    ) : _name( name )
      , _version( version )
      , _dependencies( dependencies )
      , _devDependencies( devDependencies )
      , _peerDependencies( peerDependencies )
      , _optionalDependencies( optionalDependencies )
      , _bundledDependencies( bundledDependencies )
    {}


/* -------------------------------------------------------------------------- */

    /* Accessors */
    const ident_t   & name()    const { return this->_name; }
    const version_t & version() const { return this->_version; }

      const dep_map_t &
    dependencies() const {
      return this->_dependencies;
    };

      const dep_map_t &
    devDependencies()  const {
      return this->_devDependencies;
    };

      const dep_map_t &
    peerDependencies() const {
      return this->_peerDependencies;
    };

      const dep_map_t &
    optionalDependencies() const {
      return this->_optionalDependencies;
    };

      const dep_set_t &
    bundledDependencies() const {
      return this->_bundledDependencies;
    };


/* -------------------------------------------------------------------------- */

};  /* End `class Package' */



/* -------------------------------------------------------------------------- */

Package loadPackage( const std::string & path );


/* -------------------------------------------------------------------------- */

  };  /* End `namespace floco::graph' */
};  /* End `namespace floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
