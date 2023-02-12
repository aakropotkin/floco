/* ========================================================================== *
 *
 * Tests creation of a `Package' class.
 *
 * -------------------------------------------------------------------------- */

#include <cstddef>
#include <iostream>

#include "../package.hh"

/* -------------------------------------------------------------------------- */

using namespace floco::graph;

/* -------------------------------------------------------------------------- */

  void
show( const Package & p )
{
  std::cerr << "{\n  name: " << p.name() << "\n, version: " << p.version();

  std::cerr << "\n, dependencies: {";
  if ( p.dependencies().empty() )
    {
      std::cerr << "}\n";
    }
  else
    {
      for ( auto [name, spec] : p.dependencies() )
        {
          std::cerr << "\n    " << name << ": " << spec;
        }
      std::cerr << "\n  }\n";
    }

  std::cerr << "}\n";
}


/* -------------------------------------------------------------------------- */

  int
main( int argc, char * argv[], char ** envp )
{
  Package p0( "@floco/phony", "0.0.0-0" );
  std::cerr << R"(Package p0( "@floco/phony", "0.0.0-0" ):)" << "\n";
  show( p0 );
  std::cerr << "\n";

  Package p1( "@floco/phony", "0.0.0-0", { { "lodash", "^4.17.21" } } );
  std::cerr << R"(Package p1( "@floco/phony", "0.0.0-0", { { "lodash", "^4.17.21" } } );)" << "\n";
  show( p1 );
  std::cerr << "\n";

  /* Assumed to be running from the project root by `make check;' */
  Package p2 = loadPackage( "./tests/data/pjs0.json" );
  std::cerr << R"(Package p2 = loadPackage( "./tests/data/pjs0.json" );)" << "\n";
  show( p2 );
  std::cerr << "\n";

  return 0;
}


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
