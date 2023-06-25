/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include <regex>
#include <stddef.h>               // for NULL
#include <iostream>               // for operator<<, endl, basic_ostream
#include <map>                    // for operator!=
#include <nlohmann/json.hpp>      // for basic_json
#include <nlohmann/json_fwd.hpp>  // for json
#include <string>                 // for allocator, basic_string, string
#include <argparse/argparse.hpp>  // for ArgumentParser, Argument, operator<<
#include <optional>
#include "date.hh"
#include "floco-sql.hh"           // for pjsCoreSchemaSQL
#include "pjs-core.hh"            // for pjsJsonToSQL, db
#include "sqlite3pp.h"
#include "floco-registry.hh"
#include "registry-db.hh"


/* -------------------------------------------------------------------------- */

using namespace floco;
using namespace floco::db;
using namespace floco::registry;


/* -------------------------------------------------------------------------- */

  int
main( int argc, char * argv[], char ** envp )
{

/* -------------------------------------------------------------------------- */

  /* Top level args */

  argparse::ArgumentParser prog( "db", "0.1.0" );
  prog.add_description( "Operate on `floco' databases" );

  prog.add_argument( "-r", "--registry" )
    .help( "Registry to query from" )
    .metavar( "URL" )
    .default_value( std::string( "https://registry.npmjs.org" ) );


/* -------------------------------------------------------------------------- */

  /* `db pack' subcommand */

  argparse::ArgumentParser pack_cmd( "pack" );
  pack_cmd.add_description( "Operate on a packument cache" );
  pack_cmd.add_argument( "descriptor" )
    .required()
    .metavar( "IDENT[@VERSION]" )
    .help( "Package descriptor ( name + optional version ) to lookup" );
  prog.add_subparser( pack_cmd );


/* -------------------------------------------------------------------------- */

  /* `db versions' subcommand */

  argparse::ArgumentParser vers_cmd( "versions" );
  vers_cmd.add_description( "List all module versions" );
  vers_cmd.add_argument( "ident" )
    .required()
    .metavar( "IDENT" )
    .help( "Package identifier ( name ) to lookup" );
  prog.add_subparser( vers_cmd );


/* -------------------------------------------------------------------------- */

  try
    {
      prog.parse_args( argc, argv );
    }
  catch ( const std::runtime_error & err )
    {
      std::cerr << err.what() << std::endl;
      std::cerr << prog;
      return EXIT_FAILURE;
    }


/* -------------------------------------------------------------------------- */

  /* Parse registry URL */

  auto url = prog.get<std::string>( "-r" );
  const std::regex regURL( "((https?)://)?(.*)"
                         , std::regex_constants::ECMAScript
                         );
  std::smatch reg_match;
  std::regex_match( url, reg_match, regURL );
  std::string proto;
  if ( reg_match[2].matched ) { proto = reg_match[2]; }
  else                        { proto = "https";      }
  RegistryDb reg( (std::string) reg_match[3], proto );


/* -------------------------------------------------------------------------- */

  if ( prog.is_subcommand_used( "pack" ) )
    {
      auto desc = pack_cmd.get<std::string>( "descriptor" );

      const std::regex descRE( "((@[^@/]+/)?([^@/]*))(@([^@]+))?"
                             , std::regex_constants::ECMAScript
                             );

      std::regex_match( desc, reg_match, descRE );
      std::string                ident   = reg_match[1];
      std::optional<std::string> version = std::nullopt;

      if ( reg_match[5].matched ) { version = reg_match[5]; }

      if ( version.has_value() )
        {
          PackumentVInfo pv = reg.get( ident, version.value() );
          std::cout << pv.toJSON().dump() << std::endl;
        }
      else
        {
          Packument p = reg.get( ident );
          std::cout << p.toJSON().dump() << std::endl;
        }
    }
  else if ( prog.is_subcommand_used( "versions" ) )
    {
      std::string ident = vers_cmd.get<std::string>( "ident" );
      Packument p = reg.get( ident );
      nlohmann::json vs( p.time );
      if ( auto search = vs.find( "created" ); search != vs.end() )
        {
          vs.erase( search );
        }
      if ( auto search = vs.find( "modified" ); search != vs.end() )
        {
          vs.erase( search );
        }
      std::cout << vs.dump() << std::endl;
    }


/* -------------------------------------------------------------------------- */

  return EXIT_SUCCESS;

}  /* End `main' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
