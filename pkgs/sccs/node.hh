/* ========================================================================== *
 *
 * Graph interfaces and constructs.
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <stdexcept>

#include "types.hh"
#include "package.hh"

/* -------------------------------------------------------------------------- */

namespace floco {
  namespace graph {

/* -------------------------------------------------------------------------- */

class Node {

/* -------------------------------------------------------------------------- */

  /* Data */

  const Package * _package;
  const Node    * _parent;
  const Node    * _root;
  edge_set_t      _edgesIn;
  edge_map_t      _edgesOut;
  overrides_t     _overrides;
  node_map_t      _children;


/* -------------------------------------------------------------------------- */

  public:

/* -------------------------------------------------------------------------- */

    /* Constructors */

    Node(
      const Package * package   = nullptr
    , const Node    * parent    = nullptr
    , const Node    * root      = nullptr
    , edge_set_t      edgesIn   = {}
    , edge_map_t      edgesOut  = {}
    , overrides_t     overrides = {}
    , node_map_t      children  = {}
    ) : _package( package )
      , _parent( parent )
      , _root( root )
      , _edgesIn( edgesIn )
      , _edgesOut( edgesOut )
      , _overrides( overrides )
      , _children( children )
    {};


/* -------------------------------------------------------------------------- */

    /* Accessors */

    const Package     * package()   const { return this->_package; }
    const Node        * parent()    const { return this->_parent; }
    const Node        * root()      const { return this->_root; }
    const overrides_t & overrides() const { return this->_overrides; }
    const ident_t     & name()      const { return this->_package->name(); }
    const version_t   & version()   const { return this->_package->version(); }

    edge_set_t & edgesIn()  { return this->_edgesIn; }
    edge_map_t & edgesOut() { return this->_edgesOut; }
    node_map_t & children() { return this->_children; }


/* -------------------------------------------------------------------------- */

    /* Predicates */

    bool isTop()         const { return this->_parent == nullptr; }
    bool inBundle()      const { return false; /* FIXME */ }
    bool hasShrinkwrap() const { return false; /* FIXME */ }
    bool inShrinkwrap()  const { return false; /* FIXME */ }


/* -------------------------------------------------------------------------- */

    /* Utils */

    void addEdgeIn( Edge * edge );
    void addEdgeOut( Edge * edge );

    Node * resolve( const ident_t & name ) const;


/* -------------------------------------------------------------------------- */

    /* Operators */

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


/* -------------------------------------------------------------------------- */

};  /* End `class Node' */


/* -------------------------------------------------------------------------- */

  };  /* End `namespace floco::graph' */
};  /* End `namespace floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
