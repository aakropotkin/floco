/* ========================================================================== *
 *
 * Tests a trivial network of manually constructed nodes/edges.
 *
 * -------------------------------------------------------------------------- */

#include <cstddef>
#include <iostream>
#include <optional>

#include "../package.hh"
#include "../edge.hh"
#include "../node.hh"

/* -------------------------------------------------------------------------- */

using namespace floco::graph;

/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */

  int
main( int argc, char * argv[], char ** envp )
{
  Package p0( "lodash", "4.17.21" );
  Package p1( "@floco/phony", "0.0.0-0", { { "lodash", "^4.17.21" } } );

  Node n0( & p0 );
  Node n1( & p1, nullptr, nullptr, {}, {}, {}, { { "lodash", & n0 } } );

  Edge e0( EdgeType::prod, "lodash", "^4.17.21", std::nullopt, & n1, & n0 );

  std::cout << e0.from()->name() << " <- " << e0.to()->name() << "\n";

  return 0;
}


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
