/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include "date.hh"
#include <string>
#include <ctime>

/* -------------------------------------------------------------------------- */

namespace floco {
  namespace util {

/* -------------------------------------------------------------------------- */

/* Example Date/Time:
 *   2022-06-29T06:45:35.755Z
 *   %Y-%m-%dT%T.<Ms>Z
 *
 * NOTE: There is no milliseconds support if `strptime', and frankly we don't
 * care about it.
 * While that in mind just parse until the `.' and toss the rest.
 */

  std::tm
parseDateTime( std::string_view timestamp )
{
  static const char fmt[] = "%Y-%m-%dT%T.";
  std::tm t;
  std::string s( timestamp );
  strptime( s.c_str(), fmt, & t );
  return t;
}


/* -------------------------------------------------------------------------- */

  bool
dateBefore( const std::tm & before, const std::tm & time )
{
  std::tm b = before;
  std::tm t = time;
  return ( std::mktime( & b ) <= std::mktime( & t ) );
}

  bool
dateBefore( std::string_view before, std::string_view timestamp )
{
  return dateBefore( parseDateTime( before ), parseDateTime( timestamp ) );
}

  bool
dateBefore( const std::tm & before, std::string_view timestamp )
{
  return dateBefore( before, parseDateTime( timestamp ) );
}

  bool
dateBefore( std::string_view before, const std::tm & time )
{
  return dateBefore( parseDateTime( before ), time );
}


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::util' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
