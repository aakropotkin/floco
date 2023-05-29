/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <string>
#include <ctime>


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace util {

/* -------------------------------------------------------------------------- */

std::tm parseDateTime( std::string_view timestamp );
unsigned long parseDateTimeToEpoch( std::string_view timestamp );


/* -------------------------------------------------------------------------- */

bool dateBefore( const std::tm & before, const std::tm & time );
bool dateBefore( std::string_view before, std::string_view timestamp );
bool dateBefore( const std::tm & before, std::string_view timestamp );
bool dateBefore( std::string_view before, const std::tm & time );


/* -------------------------------------------------------------------------- */

bool compareDateTime( const std::tm & a, const std::tm & b );
bool compareDateTime( std::string_view a, std::string_view b );
bool compareDateTime( const std::tm & a, std::string_view b );
bool compareDateTime( std::string_view a, const std::tm & b );


/* -------------------------------------------------------------------------- */

class DateTime {

  std::tm _time;

  public:

    DateTime( std::string_view timestamp )
      : _time( parseDateTime( timestamp ) ) {}
    DateTime( const time_t secondsSinceEpoch )
      : _time( * gmtime( & secondsSinceEpoch ) ) {}
    DateTime( const unsigned long secondsSinceEpoch )
      : DateTime( (const time_t) secondsSinceEpoch ) {}
    DateTime( const std::tm & time ) : _time( time ) {};

    std::string   stamp() const;
    unsigned long epoch() const;
    std::tm       time()  const { return this->_time; }

    bool isBefore( const DateTime & before ) const;
    int  compare( const DateTime & other ) const;

    operator unsigned long() const { return this->epoch(); }
    operator std::time_t()   const;

};


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::util' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
