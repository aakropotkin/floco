/* ========================================================================== *
 *
 * Graph interfaces and constructs.
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

  /* Data */
  ident_t   _name;
  version_t _version;
  dep_map_t _dependencies;
  dep_map_t _devDependencies;
  dep_map_t _peerDependencies;
  dep_map_t _optionalDependencies;
  dep_set_t _bundledDependencies;


  public:
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

};


/* -------------------------------------------------------------------------- */

class Node {

  /* Data */
  const Package * _package;
  const Node    * _parent;
  const Node    * _root;
  edge_set_t      _edgesIn;
  edge_map_t      _edgesOut;
  overrides_t     _overrides;

  public:
    Node(
      const Package * package   = nullptr
    , const Node    * parent    = nullptr
    , const Node    * root      = nullptr
    , edge_set_t      edgesIn   = {}
    , edge_map_t      edgesOut  = {}
    , overrides_t     overrides = {}
    ) : _package( package )
      , _parent( parent )
      , _root( root )
      , _edgesIn( edgesIn )
      , _edgesOut( edgesOut )
      , _overrides( overrides )
    {};

    const Package     * package()   const { return this->_package; }
    const Node        * parent()    const { return this->_parent; }
    const Node        * root()      const { return this->_root; }
    const overrides_t & overrides() const { return this->_overrides; }
    const ident_t     & name()      const { return this->_package->name(); }
    const version_t   & version()   const { return this->_package->version(); }

    edge_set_t & edgesIn()  { return this->_edgesIn; }
    edge_map_t & edgesOut() { return this->_edgesOut; }

    bool isTop()         const { return this->_parent == nullptr; }
    bool inBundle()      const { return false; /* FIXME */ }
    bool hasShrinkwrap() const { return false; /* FIXME */ }
    bool inShrinkwrap()  const { return false; /* FIXME */ }

    void addEdgeIn( Edge * edge );
    void addEdgeOut( Edge * edge );

    Node & resolve( const ident_t & name ) const;

      bool
    operator==( const Node & other ) const {
      return ( this->name() == other.name() ) &&
             ( this->version() == other.version() );
    }

      bool
    operator!=( const Node & other ) const {
      return ( this->name() != other.name() ) ||
             ( this->version() != other.version() );
    }
};


/* -------------------------------------------------------------------------- */

  };
};


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
