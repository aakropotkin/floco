/* ========================================================================== *
 *
 * Wraps NPM exposing certain routines to Nix as builtins.
 *
 * -------------------------------------------------------------------------- */

#include "nix/util.hh"
#include "nix/primops.hh"
#include "nix/json-to-value.hh"
#include "progs.hh"
#include <iostream>

using namespace nix;

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
  .name = "__npmResolve",
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
  .name = "__npmShow",
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
  .name = "__npmLock",
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
  state.forceValue( * args[1], pos );
  if ( args[1]->type() == nString )
    {
      std::string version ( state.forceStringNoCtx( * args[1], pos ) );
      std::string rsl = runSemver( { "-r", range, version } );
      v.mkBool( ! rsl.empty() );
    }
  else
    {
    state.forceList( *args[1], pos );
    auto elems = args[1]->listElems();
    Strings svArgs;
    svArgs.emplace_back( "-r" );
    svArgs.emplace_back( range );
    for ( unsigned int i = 0; i < args[1]->listSize(); ++i )
      {
        svArgs.emplace_back( state.forceStringNoCtx( *elems[i], pos ) );
      }
      std::string rsl = runSemver( svArgs );
      if ( rsl.empty() )
        {
          state.mkList( v, 0 );
        }
      else
        {
          Strings goods = tokenizeString<Strings>( rsl, "\n" );
          unsigned int k = goods.size();
          state.mkList( v, k );
          for ( const auto & [n, version] : enumerate( goods ) )
            {
              ( v.listElems()[n] = state.allocValue() )->mkString(
                std::move( version )
              );
            }
        }
    }
}

static RegisterPrimOp primop_semver_sat( {
  .name = "__semverSat",
  .args = { "range", "version(s)" },
  .doc  = R"(
    Does *version(s)* fall within the semver *range*?
    *version(s)* may be a string or list of strings.
    When *version(s)* is a string this function returns a bool.
    When *version(s)* is a list, this function returns a list of satisfactory
    versions from the input list.
  )",
  .fun = prim_semverSat,
} );


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
