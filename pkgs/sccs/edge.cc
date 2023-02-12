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
  const Node   * child
, const spec_t & requested
, const Node   * requestor
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
  if ( this->_accept.has_value() )
    {
      return depValid( node, this->_accept.value(), this->_from );
    }

  const auto spec =
    ( node->hasShrinkwrap() || node->inShrinkwrap() || node->inBundle() ) ?
    this->_spec : this->spec();
  return depValid( node, spec, this->_from );
}


/* -------------------------------------------------------------------------- */

  void
Edge::reload( bool hard )
{
  auto ov = this->_from->overrides().find( this->_name );
  if ( ov != this->_from->overrides().end() )
    {
      this->_overrides = std::make_pair( ov->first, ov->second );
    }
  else
    {
      this->_overrides = std::nullopt;
    }

  auto newTo = this->_from->resolve( this->_name );
  if ( newTo != ( * this->_to ) )
    {
      if ( this->_to != nullptr )
        {
          this->_to->edgesIn().erase( this );
        }
      this->_to    = & newTo;
      this->_error = this->loadError();
      if ( this->_to != nullptr )
        {
          this->_to->addEdgeIn( this );
        }
      else if ( hard )
        {
          this->_error = this->loadError();
        }
    }
}


/* -------------------------------------------------------------------------- */

  void
Edge::detach()
{
  if ( this->_to != nullptr )
    {
      this->_to->edgesIn().erase( this );
    }
  this->_from->edgesOut().erase( this->_name );
  this->_to    = nullptr;
  this->_error = EdgeError::detached;
  this->_from  = nullptr;
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
Edge::setFrom( Node * node )
{
  this->_from = node;
  auto sref = node->edgesOut().find( this->_name );
  if ( sref != node->edgesOut().end() )
    {
      sref->second->detach();
    }
  node->addEdgeOut( this );
  this->reload();
}


/* -------------------------------------------------------------------------- */

  };
};


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
