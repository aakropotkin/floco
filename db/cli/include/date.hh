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

  }  /* End Namespace `floco::util' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
