/* ========================================================================== *
 *
 * Parse package specs, identifiers, descriptors, etc.
 *
 * -------------------------------------------------------------------------- */

#include "graph.hh"
#include <cstddef>

/* -------------------------------------------------------------------------- */

namespace floco {
  namespace graph {

/* -------------------------------------------------------------------------- */

  spec_t
Edge::spec() const
{
  return this->_spec;  /* TODO */
}


/* -------------------------------------------------------------------------- */

  bool
Edge::bundled() const
{
  if ( this->_from == nullptr )
    {
      return false;
    }
  return false;  /* TODO: check `bundledDependencies' info in Node. */
}


/* -------------------------------------------------------------------------- */

  bool
Edge::satisfiedBy( const Node * node ) const
{
  return false;  /* TODO */
}


/* -------------------------------------------------------------------------- */

  void
Edge::reload( bool hard )
{
  /* TODO */
}


/* -------------------------------------------------------------------------- */

  void
Edge::detach()
{
  /* TODO */
}


/* -------------------------------------------------------------------------- */

  EdgeError
Edge::loadError() const
{
  if ( this->_to == nullptr )
    {
      return this->optional() ? EdgeError::ok : EdgeError::missing;
    }
  else if ( this->peer() &&
       ( this->_from == this->_to->parent() ) &&
       ( ! this->_from->isTop() )
     )
    {
      return EdgeError::peer_local;
    }
  else
    {
      return this->satisfiedBy( this->_to ) ? EdgeError::ok
                                            : EdgeError::invalid;
    }
}


/* -------------------------------------------------------------------------- */

  void
Edge::setFrom( const Node * node )
{
  /* TODO */
}


/* -------------------------------------------------------------------------- */

  };
};


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
