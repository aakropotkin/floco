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


/* -------------------------------------------------------------------------- */

bool dateBefore( const std::tm & before, const std::tm & time );
bool dateBefore( std::string_view before, std::string_view timestamp );
bool dateBefore( const std::tm & before, std::string_view timestamp );
bool dateBefore( std::string_view before, const std::tm & time );


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::util' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
