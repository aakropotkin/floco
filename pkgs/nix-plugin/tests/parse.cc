
#include "../parse.hh"
#include <iostream>

  int
main( int argc, char * argv[], char ** envp )
{

  std::cerr << "0: ";
  floco::parse::ParsedSpec( std::nullopt, "lodash", "4.2.17" ).show();
  std::cerr << "\n";

  std::cerr << "1: ";
  floco::parse::ParsedSpec( "lodash@4.2.17" ).show();
  std::cerr << "\n";

  std::cerr << "2: ";
  floco::parse::ParsedSpec( "lodash", "4.2.17" ).show();
  std::cerr << "\n";

  std::cerr << "3: ";
  floco::parse::ParsedSpec( "@foo/lodash", "4.2.17" ).show();
  std::cerr << "\n";

  std::cerr << "4: ";
  floco::parse::ParsedSpec( "@foo/lodash", "~4.2.17" ).show();
  std::cerr << "\n";

  std::cerr << "5: ";
  floco::parse::ParsedSpec( "@foo/lodash@4.2.17" ).show();
  std::cerr << "\n";

  std::cerr << "6: ";
  floco::parse::ParsedSpec( "@foo/lodash/4.2.17" ).show();
  std::cerr << "\n";

  std::cerr << "7: ";
  floco::parse::ParsedSpec( "lodash/4.2.17" ).show();
  std::cerr << "\n";

  std::cerr << "8: ";
  floco::parse::ParsedSpec( "lodash/~4.2.17" ).show();
  std::cerr << "\n";

  std::cerr << "9: ";
  floco::parse::ParsedSpec( "lodash@~4.2.17" ).show();
  std::cerr << "\n";

  std::cerr << "10: ";
  floco::parse::ParsedSpec( "%40foo%2flodash%404.2.17" ).show();
  std::cerr << "\n";

  std::cerr << "11: ";
  floco::parse::ParsedSpec( "lodash" ).show();
  std::cerr << "\n";

  std::cerr << "12: ";
  floco::parse::ParsedSpec( "@foo/lodash" ).show();
  std::cerr << "\n";

  return 0;
}
