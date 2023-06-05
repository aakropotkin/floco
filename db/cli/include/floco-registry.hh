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
    std::string                  protocol = "https";
    std::string                  host     = "registry.npmjs.org";
    std::optional<PkgRegistry *> fallback = std::nullopt;

    PkgRegistry(
      std::string_view             host     = "registry.npmjs.org"
    , std::string_view             protocol = "https"
    , std::optional<PkgRegistry *> fallback = std::nullopt
    ) : host( host ), protocol( protocol ), fallback( fallback )
    {}

    std::string getPackumentURL( floco::ident_view ident ) const;
    std::string getVInfoURL( floco::ident_view ident
                           , floco::version_view version
                           ) const;
};


/* -------------------------------------------------------------------------- */

static const PkgRegistry defaultRegistry = PkgRegistry();


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::registry' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
