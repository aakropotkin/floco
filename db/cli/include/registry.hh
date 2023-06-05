/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <string>
#include "pjs-core.hh"
#include <optional>


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace registry {

/* -------------------------------------------------------------------------- */

class PkgRegistry {
  public:
    std::string                  host     = "registry.npmjs.org";
    std::string                  protocol = "https";
    std::optional<PkgRegistry *> fallback = std::nullopt;

    std::string getPackumentURL( floco::ident_view ident );
    std::string getVInfoURL( floco::ident_view ident
                           , floco::version_view version
                           );
};


/* -------------------------------------------------------------------------- */

static const PkgRegistry defaultRegistry();


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::registry' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
