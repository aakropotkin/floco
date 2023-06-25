/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <cstdlib>
#include <string>
#include "pjs-core.hh"
#include <optional>


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace registry {

/* -------------------------------------------------------------------------- */

// TODO: create `floco-config.h' configurable header.

/**
 * Number of seconds before cached lookups are invalidated.
 * Default is 3,600s ( 1hr ), but this may be overridden globally;
 */
#ifdef FLOCO_REGISTRY_TTL
  static unsigned long registryTTL = FLOCO_REGISTRY_TTL;
#else
  static unsigned long registryTTL = 3600;
#endif


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

extern PkgRegistry defaultRegistry;


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::registry' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
