/* ========================================================================== *
 *
 * Wraps executables allowing them to be run with captured outputs.
 *
 * -------------------------------------------------------------------------- */

#include "progs.hh"
#include <nix/eval-inline.hh>

/* -------------------------------------------------------------------------- */

namespace nix {

/* -------------------------------------------------------------------------- */

  static RunOptions
npmOptions( const Strings & args )
{
  auto env = getEnv();
  return {
    .program     = "npm",
    .searchPath  = true,
    .args        = args,
    .environment = env
  };
}

  std::string
runNpm( const Strings & args, const std::optional<std::string> & input )
{
  RunOptions opts = npmOptions( args );
  opts.input = input;

  auto res = runProgram( std::move( opts ) );

  if ( ! statusOk( res.first ) )
    {
      throw ExecError( res.first, "npm %1%", statusToString( res.first ) );
    }

  return res.second;
}


/* -------------------------------------------------------------------------- */

  static RunOptions
treeForOptions( const Strings & args )
{
  auto env = getEnv();
  return {
    .program     = "treeFor",
    .searchPath  = true,
    .args        = args,
    .environment = env
  };
}

  std::string
runTreeFor(
  const Strings & args, const std::optional<std::string> & input
)
{
  RunOptions opts = treeForOptions( args );
  opts.input = input;

  auto res = runProgram( std::move( opts ) );

  if ( ! statusOk( res.first ) )
    {
      throw ExecError( res.first, "treeFor %1%", statusToString( res.first ) );
    }

  return res.second;
}


/* -------------------------------------------------------------------------- */

  static RunOptions
semverOptions( const Strings & args )
{
  auto env = getEnv();
  return {
    .program     = "semver",
    .searchPath  = true,
    .args        = args,
    .environment = env
  };
}

  std::string
runSemver(
  const Strings & args, const std::optional<std::string> & input
)
{
  RunOptions opts = semverOptions( args );
  opts.input = input;

  auto res = runProgram( std::move( opts ) );

  if ( ! statusOk( res.first ) )
    {
      return "";
    }

  return res.second;
}


/* -------------------------------------------------------------------------- */

}  /* End Namespace `nix' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
