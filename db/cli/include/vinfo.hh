/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include "pjs-core.hh"
#include <string>
#include <nlohmann/json.hpp>


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace db {

/* -------------------------------------------------------------------------- */

class VInfo : public PjsCore {

  protected:
    void init( const nlohmann::json & json );

  public:

    std::string    _id;           /* <name>@<version> */
    std::string    homepage;
    std::string    description;
    std::string    license        = "unlicensed";
    nlohmann::json repository     = nlohmann::json::object();
    nlohmann::json dist           = nlohmann::json::object();
    bool           _hasShrinkwrap = false;

    VInfo() {}

    /** Read a `VInfo' from a JSON file such as `package.json'. */
    VInfo( const nlohmann::json & json ) { this->init( json ); }

    /** Read a `VInfo' from an NPM registry URL. */
    VInfo( std::string_view url );

    /** Read a `VInfo' from `https://registry.npmjs.org'. */
    VInfo( floco::ident_view name, floco::version_view version );

    // /** Read a `VInfo' from a SQLite3 database. */
    // VInfo( sqlite3pp::database & db
    //      , std::string_view      name
    //      , std::string_view      version
    //      );

    // /** Write a `VInfo' to a SQLite3 database. */
    // void sqlite3Write( sqlite3pp::database & db );

    /** Convert a `VInfo' to a JSON representation. */
    nlohmann::json toJSON() const;

    /** Get the `<name>@<version>` identifier used by NPM registries. */
    std::string id() const { return this->_id; }

    bool operator==( const VInfo & other ) const;
    bool operator!=( const VInfo & other ) const;

};


/* -------------------------------------------------------------------------- */

void to_json(         nlohmann::json & j, const VInfo & v );
void from_json( const nlohmann::json & j,       VInfo & v );


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::db' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
