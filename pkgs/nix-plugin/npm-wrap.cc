/* ========================================================================== *
 *
 * Wraps NPM exposing certain routines to Nix as builtins.
 *
 * -------------------------------------------------------------------------- */

#include <regex>
#include <nix/util.hh>
#include <nix/primops.hh>
#include <nix/json-to-value.hh>
#include <nix/eval-inline.hh>

#include "progs.hh"

using namespace nix;

/* -------------------------------------------------------------------------- */

  std::string
nix::npmResolve( const std::string spec )
{
  static const std::regex patt = std::regex( "^.*'(https://[^']+)'.*$" );

  std::string uri   = chomp( runNpm( { "show", spec, "dist.tarball" } ) );
  auto        lines = tokenizeString<Strings>( uri, "\n" );

  if ( 1 < lines.size() )
    {
      std::smatch match;
      std::regex_match( lines.back(), match, patt );
      return match[1].str();
    }
  else if ( hasPrefix( uri, "file:" ) )
    {
      return uri.substr( 5 );
    }
  else
    {
      return uri;
    }
}


/* -------------------------------------------------------------------------- */

  static void
prim_npmResolve(
  EvalState & state, const PosIdx pos, Value ** args, Value & v
)
{
  const std::string spec( state.forceStringNoCtx( * args[0], pos ) );
  v.mkString( npmResolve( spec ) );
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
  auto result = runTreeFor( { path } );
  try
    {
      parseJSON( state, result, v );
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


/* -------------------------------------------------------------------------- */

  static void
prim_semverSat(
  EvalState & state, const PosIdx pos, Value ** args, Value & v
)
{
  std::string range ( state.forceStringNoCtx( * args[0], pos ) );
  std::string version ( state.forceStringNoCtx( * args[1], pos ) );
  std::string rsl = runSemver( { "-r", range, version } );
  v.mkBool( ! rsl.empty() );
}

static RegisterPrimOp primop_semver_sat( {
  .name = "semverSat",
  .args = { "range", "version" },
  .doc  = R"(
    Does *version* fall within the semver *range*?
  )",
  .fun = prim_semverSat,
} );


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
