/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <ctime>                  // for time, size_t
#include <map>                    // for operator!=
#include <nlohmann/json.hpp>      // for basic_json
#include <nlohmann/json_fwd.hpp>  // for json
#include <string>                 // for string, basic_string, hash, allocator
#include <string_view>            // for string_view, basic_string_view
#include <unordered_map>          // for unordered_map
#include "sqlite3pp.h"


/* -------------------------------------------------------------------------- */

namespace floco {

/* -------------------------------------------------------------------------- */

typedef std::string       version;
typedef std::string_view  version_view;

typedef std::string       timestamp;
typedef std::string_view  timestamp_view;

typedef std::string       ident;
typedef std::string_view  ident_view;

typedef std::string       descriptor;
typedef std::string_view  descriptor_view;


/* -------------------------------------------------------------------------- */

  namespace db {

/* -------------------------------------------------------------------------- */

class PjsCore {

  protected:
    void init( const nlohmann::json & json );

  public:
    floco::ident   name;
    floco::version version              = "0.0.0-0";
    nlohmann::json bin                  = nlohmann::json::object();
    nlohmann::json dependencies         = nlohmann::json::object();
    nlohmann::json devDependencies      = nlohmann::json::object();
    nlohmann::json devDependenciesMeta  = nlohmann::json::object();
    nlohmann::json peerDependencies     = nlohmann::json::object();
    nlohmann::json peerDependenciesMeta = nlohmann::json::object();
    nlohmann::json optionalDependencies = nlohmann::json::object();
    nlohmann::json bundledDependencies  = nlohmann::json::array();
    nlohmann::json cpu                  = nlohmann::json::array( { "*" } );
    nlohmann::json os                   = nlohmann::json::array( { "*" } );
    nlohmann::json engines              = nlohmann::json::object();
    nlohmann::json scripts              = nlohmann::json::object();

    PjsCore() {}

    /** Read a `PjsCore' from a JSON file such as `package.json'. */
    PjsCore( const nlohmann::json & json ) { this->init( json ); }

    /** Read a `PjsCore' from an NPM registry URL. */
    PjsCore( std::string_view url );

    /** Read a `PjsCore' from `https://registry.npmjs.org'. */
    PjsCore( floco::ident_view name, floco::version_view version );

    /** Read a `PjsCore' from a SQLite3 database. */
    PjsCore( sqlite3pp::database & db
           , floco::ident_view     name
           , floco::version_view   version
           );

    /** Write a `PjsCore' to a SQLite3 database. */
    void sqlite3Write( sqlite3pp::database & db ) const;

    /** Convert a `PjsCore' to a JSON representation. */
    nlohmann::json toJSON() const;

    /** Get the `<name>@<version>` identifier used by NPM registries. */
    std::string id() const { return this->name + "@" + this->version; }

    bool operator==( const PjsCore & other ) const = default;
    bool operator!=( const PjsCore & other ) const = default;

    bool hasBuildScript()   const;
    bool hasInstallScript() const;

    friend void from_json( const nlohmann::json & j, PjsCore & p );

};


/* -------------------------------------------------------------------------- */

void to_json(         nlohmann::json & j, const PjsCore & p );
void from_json( const nlohmann::json & j,       PjsCore & p );


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::db' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
