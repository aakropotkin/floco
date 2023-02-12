/* ========================================================================== *
 *
 * An edge in a dependency graph.
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <stdexcept>

#include "types.hh"

/* -------------------------------------------------------------------------- */

namespace floco {
  namespace graph {

/* -------------------------------------------------------------------------- */

class Edge {

/* -------------------------------------------------------------------------- */

  /* Data */
  EdgeType                _type;
  ident_t                 _name;
  spec_t                  _spec;
  std::optional<spec_t>   _accept;
  Node                  * _from;
  Node                  * _to;
  bool                    _peerConflicted;
  bool                    _overridden;

  std::optional<EdgeError> _error;

  overrides_elem_t _overrides;


/* -------------------------------------------------------------------------- */

  public:

/* -------------------------------------------------------------------------- */

    Edge(
      EdgeType                   type           = EdgeType::prod
    , ident_t                    name           = nullptr
    , spec_t                     spec           = "*"
    , std::optional<spec_t>      accept         = std::nullopt
    , Node                     * from           = nullptr
    , Node                     * to             = nullptr
    , bool                       peerConflicted = false
    , bool                       overridden     = false
    , std::optional<EdgeError>   error          = std::nullopt
    , overrides_elem_t           overrides      = std::nullopt
    ) : _type( type )
      , _name( name )
      , _spec( spec )
      , _accept( accept )
      , _to( to )
      , _peerConflicted( peerConflicted )
      , _overridden( overridden )
      , _overrides( overrides )
    {
      if ( from == nullptr )
        {
          throw std::invalid_argument(
            "Edge::Edge(): from must be a Node, but received nullptr"
          );
        }
      this->setFrom( from );

      if ( error.has_value() )
        {
          this->_error = error;
        }
      else
        {
          this->_error = this->loadError();
        }
    }


/* -------------------------------------------------------------------------- */

    /* Accessors */
    spec_t                spec()    const;
    EdgeType              type()    const { return this->_type; }
    ident_t               name()    const { return this->_name; }
    spec_t                rawSpec() const { return this->_spec; }
    std::optional<spec_t> accept()  const { return this->_accept; }

    Node * from() { return this->_from; }
    Node * to()   { return this->_to; }


/* -------------------------------------------------------------------------- */

    /* Predicates */
    bool bundled()   const;
    bool workspace() const { return this->_type == EdgeType::workspace; }
    bool prod()      const { return this->_type == EdgeType::prod; }
    bool dev()       const { return this->_type == EdgeType::dev; }

      bool
    optional() const {
      return ( this->_type == EdgeType::optional ) ||
             ( this->_type == EdgeType::peerOptional );
    }

      bool
    peer() const {
      return ( this->_type == EdgeType::peer ) ||
             ( this->_type == EdgeType::peerOptional );
    }


/* -------------------------------------------------------------------------- */

    /* Error Checking */
    bool valid()     { return this->error() == EdgeError::ok; }
    bool missing()   { return this->error() == EdgeError::missing; }
    bool invalid()   { return this->error() == EdgeError::invalid; }
    bool peerLocal() { return this->error() == EdgeError::peer_local; }

      EdgeError
    error() {
      if ( ! this->_error.has_value() )
        {
          this->_error = this->loadError();
        }
      return this->_error.value();
    }


/* -------------------------------------------------------------------------- */

    /* Util */
    bool satisfiedBy( const Node * node ) const;
    void reload( bool hard = false );
    void detach();
    // ??? toJSON() const;


/* -------------------------------------------------------------------------- */

  private:

/* -------------------------------------------------------------------------- */

    EdgeError loadError() const;
    void      setFrom( Node * node );


/* -------------------------------------------------------------------------- */

};  /* End `class Edge' */


/* -------------------------------------------------------------------------- */

  };  /* End `namespace floco::graph' */
};  /* End `namespace floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
