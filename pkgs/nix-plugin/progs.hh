/* ========================================================================== *
 *
 * Wraps executables allowing them to be run with captured outputs.
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include "nix/util.hh"

/* -------------------------------------------------------------------------- */

namespace nix {

/* -------------------------------------------------------------------------- */

std::string runNpm(
  const Strings & args, const std::optional<std::string> & input = {}
);


std::string runTreeFor(
  const Strings & args, const std::optional<std::string> & input = {}
);


std::string runSemver(
  const Strings & args, const std::optional<std::string> & input = {}
);


/* -------------------------------------------------------------------------- */

}  /* End Namespace `nix' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
