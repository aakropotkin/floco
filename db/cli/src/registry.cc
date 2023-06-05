/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include "floco-registry.hh"


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace registry {

/* -------------------------------------------------------------------------- */

  std::string
PkgRegistry::getPackumentURL( floco::ident_view ident ) const
{
  std::string s( this->protocol + "://" + this->host + "/" );
  s += ident;
  return s;
}


/* -------------------------------------------------------------------------- */

  std::string
PkgRegistry::getVInfoURL( floco::ident_view ident
                        , floco::version_view version
                        ) const
{
  std::string s( this->protocol + "://" + this->host + "/" );
  s += ident;
  s += "/";
  s += version;
  return s;
}


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::registry' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
