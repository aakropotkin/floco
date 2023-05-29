/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include <cmath>
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

  unsigned long
parseDateTimeToEpoch( std::string_view timestamp )
{
  std::tm t = parseDateTime( timestamp );
  double  s = std::mktime( & t );
  return std::floor( s );
}


/* -------------------------------------------------------------------------- */

  bool
dateBefore( const std::tm & before, const std::tm & time )
{
  std::tm b = before;
  std::tm t = time;
  return std::mktime( & t ) <= std::mktime( & b );
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

  bool
compareDateTime( const std::tm & a, const std::tm & b )
{
  std::tm _a = a;
  std::tm _b = b;
  return std::mktime( & _a ) < std::mktime( & _b );
}

  bool
compareDateTime( std::string_view a, std::string_view b )
{
  return compareDateTime( parseDateTime( a ), parseDateTime( b ) );
}

  bool
compareDateTime( const std::tm & a, std::string_view b )
{
  return compareDateTime( a, parseDateTime( b ) );
}

  bool
compareDateTime( std::string_view a, const std::tm & b )
{
  return compareDateTime( parseDateTime( a ), b );
}


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::util' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
