/* ========================================================================== *
 *
 * Wraps NPM exposing certain routines to Nix as builtins.
 *
 * -------------------------------------------------------------------------- */

#include "nix/util.hh"
#include "nix/primops.hh"
#include "nix/json-to-value.hh"

using namespace nix;

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

  static std::string
runNpm( const Strings & args, const std::optional<std::string> & input = {} )
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

  static std::string
runTreeFor(
  const Strings & args, const std::optional<std::string> & input = {}
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

  static void
prim_npmResolve(
  EvalState & state, const PosIdx pos, Value ** args, Value & v
)
{
  std::string spec( state.forceStringNoCtx( * args[0], pos ) );
  std::string uri = chomp( runNpm( { "show", spec, "dist.tarball" } ) );
  if ( hasPrefix( uri, "file:" ) )
    {
      uri = uri.substr( 5 );
    }
  v.mkString( uri );
}

static RegisterPrimOp primop_npm_resolve( {
  .name = "npmResolve",
  .args = { "spec" },
  .doc  = R"(
    Resolve a package specifier <IDENT>[@<DESCRIPTOR>] to a URI.
  )",
  .fun = prim_npmResolve,
} );


/* -------------------------------------------------------------------------- */

  static void
prim_npmShow(
  EvalState & state, const PosIdx pos, Value ** args, Value & v
)
{
  std::string spec( state.forceStringNoCtx( * args[0], pos ) );
  try {
    parseJSON( state, runNpm( { "show", "--json", spec } ), v );
  } catch( JSONParseError & e ) {
    e.addTrace(state.positions[pos], "while decoding a JSON string");
    throw;
  }
}

static RegisterPrimOp primop_npm_show( {
  .name = "npmShow",
  .args = { "spec" },
  .doc  = R"(
    Resolve a package specifier <IDENT>[@<DESCRIPTOR>] to a package metadata.
  )",
  .fun = prim_npmShow,
} );


/* -------------------------------------------------------------------------- */

  static void
prim_npmLock(
  EvalState & state, const PosIdx pos, Value ** args, Value & v
)
{
  PathSet context;
  std::string path(
    * state.coerceToString( pos, * args[0], context, false, false )
  );
  try
    {
      parseJSON( state, runTreeFor( { path } ), v );
    }
  catch( JSONParseError & e )
    {
      e.addTrace( state.positions[pos], "while decoding a JSON string" );
      throw;
    }
}

static RegisterPrimOp primop_npm_lock( {
  .name = "npmLock",
  .args = { "path" },
  .doc  = R"(
    Produce a virtual package-lock.json for package at *path*.
  )",
  .fun = prim_npmLock,
} );


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
