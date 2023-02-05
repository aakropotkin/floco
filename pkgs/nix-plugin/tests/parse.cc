
#include "../parse.hh"
#include <iostream>

  int
main( int argc, char * argv[], char ** envp )
{

  floco::parse::ParsedSpec( std::nullopt, "lodash", "4.2.17" ).show();
  std::cerr << "\n";
  //floco::parse::ParsedSpec( "lodash@4.2.17" ).show();
  //std::cerr << "\n";
  floco::parse::ParsedSpec( "lodash", "4.2.17" ).show();
  std::cerr << "\n";
  floco::parse::ParsedSpec( "@foo/lodash", "4.2.17" ).show();
  std::cerr << "\n";
  floco::parse::ParsedSpec( "@foo/lodash", "~4.2.17" ).show();
  std::cerr << "\n";
  floco::parse::ParsedSpec( "@foo/lodash@4.2.17" ).show();
  std::cerr << "\n";
  floco::parse::ParsedSpec( "@foo/lodash/4.2.17" ).show();
  std::cerr << "\n";
  floco::parse::ParsedSpec( "lodash/4.2.17" ).show();
  std::cerr << "\n";
  floco::parse::ParsedSpec( "lodash/~4.2.17" ).show();
  std::cerr << "\n";
  floco::parse::ParsedSpec( "lodash@~4.2.17" ).show();

  return 0;
}
