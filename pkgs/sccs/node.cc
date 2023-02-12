/* ========================================================================== *
 *
 * An edge in a dependency graph.
 *
 * -------------------------------------------------------------------------- */

#include <cstddef>
#include <stdexcept>
#include <utility>

#include "node.hh"
#include "edge.hh"

/* -------------------------------------------------------------------------- */

namespace floco {
  namespace graph {

/* -------------------------------------------------------------------------- */

  void
Node::addEdgeIn( Edge * edge )
{
  if ( edge->overrides().has_value() )
    {
      this->_overrides = {
        { edge->overrides().value().first, edge->overrides().value().second }
      };
    }

  this->_edgesIn.insert( edge );
}


/* -------------------------------------------------------------------------- */

  void
Node::addEdgeOut( Edge * edge )
{
  if ( this->_overrides.empty() )
    {
      edge->overrides() = std::nullopt;
    }
  else
    {
      auto ov = this->_overrides.find( edge->name() );
      if ( ov == this->_overrides.end() )
        {
          edge->overrides() = std::nullopt;
        }
      else
        {
          edge->overrides() = std::make_pair( ov->first, ov->second );
        }
    }
  this->_edgesOut[edge->name()] = edge;
}


/* -------------------------------------------------------------------------- */

  Node *
Node::resolve( const ident_t & name ) const
{
  auto mine = this->_children.find( name );
  if ( mine != this->_children.end() )
    {
      return mine->second;
    }

  if ( this->_parent == nullptr )
    {
      return nullptr;
    }

  return this->_parent->resolve( name );
}


/* -------------------------------------------------------------------------- */

  };  /* End `namespace floco::graph' */
};  /* End `namespace floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
