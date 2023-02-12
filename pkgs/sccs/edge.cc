/* ========================================================================== *
 *
 * Parse package specs, identifiers, descriptors, etc.
 *
 * -------------------------------------------------------------------------- */

#include "graph.hh"
#include <cstddef>
#include <stdexcept>

/* -------------------------------------------------------------------------- */

namespace floco {
  namespace graph {

/* -------------------------------------------------------------------------- */

  static bool
depValid(
  const Node   * node
, const spec_t & spec
, std::string  & accept
, const Node   * from
)
{
  /* TODO */
  return false;
}


/* -------------------------------------------------------------------------- */

  spec_t
Edge::spec() const
{
  if ( ! this->_overrides.has_value() )
    {
      return this->_spec;
    }

  ident_t name = std::get<0>( this->_overrides.value() );
  auto    ov   = std::get<1>( this->_overrides.value() );

  if ( ( name != this->_name ) || ( ov == "*" ) )
    {
      return this->_spec;
    }

  if ( ov.c_str()[0] == '$' )
    {
      const auto ref = ov.substr( 1 );
      const auto pkg = this->_from->root()->package();
      auto       os  = pkg->devDependencies().find( ref );

      if ( os != pkg->devDependencies().end() )
        {
          return os->second;
        }

      os = pkg->optionalDependencies().find( ref );
      if ( os != pkg->optionalDependencies().end() )
        {
          return os->second;
        }

      os = pkg->dependencies().find( ref );
      if ( os != pkg->dependencies().end() )
        {
          return os->second;
        }

      os = pkg->peerDependencies().find( ref );
      if ( os != pkg->peerDependencies().end() )
        {
          return os->second;
        }

      throw std::runtime_error( "Unable to resolve reference " + ov );
    }

  return ov;
}



/* -------------------------------------------------------------------------- */

  bool
Edge::bundled() const
{
  if ( this->_from == nullptr )
    {
      return false;
    }
  return this->_from->package()->bundledDependencies().find( this->_name ) !=
         this->_from->package()->bundledDependencies().end();
}


/* -------------------------------------------------------------------------- */

  bool
Edge::satisfiedBy( const Node * node ) const
{
  if ( node->name() != this->_name )
    {
      return false;
    }
  const auto spec =
    ( node->hasShrinkwrap() || node->inShrinkwrap() || node->inBundle() ) ?
    this->_spec : this->spec();
  return depValid( node, spec, this->_accept, this->_from );
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

  if ( this->peer() &&
       ( this->_from == this->_to->parent() ) &&
       ( ! this->_from->isTop() )
     )
    {
      return EdgeError::peer_local;
    }

  return this->satisfiedBy( this->_to ) ? EdgeError::ok : EdgeError::invalid;
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
