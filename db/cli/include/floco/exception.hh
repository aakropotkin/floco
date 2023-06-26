/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <stdexcept>


/* -------------------------------------------------------------------------- */

namespace floco {

/* -------------------------------------------------------------------------- */

class FlocoException : public std::exception {
  private:
    std::string msg;
  public:
    FlocoException( std::string_view msg ) : msg( msg ) {}
    const char * what() const noexcept { return this->msg.c_str(); }
};


/* -------------------------------------------------------------------------- */

struct FlocoDbException : public FlocoException {
    FlocoDbException( std::string_view msg ) : FlocoException( msg ) {}
};

struct FlocoFetchException : public FlocoException {
    FlocoFetchException( std::string_view msg ) : FlocoException( msg ) {}
};


/* -------------------------------------------------------------------------- */

}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
