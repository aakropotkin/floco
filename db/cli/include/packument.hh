/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <map>
#include <string>
#include <nlohmann/json.hpp>      // for basic_json
#include <nlohmann/json_fwd.hpp>  // for json
#include "pjs-core.hh"
#include "vinfo.hh"
#include "date.hh"
#include <unordered_set>
#include <functional>


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace db {

/* -------------------------------------------------------------------------- */

/**
 * Manifest data for a specific version of a module which has been extended to
 * include registry metadata concering "when a module was registered", and
 * info related to downloading and verifying the integrity of the tarball.
 */
class PackumentVInfo : public VInfo {
  public:
    floco::util::DateTime           time      = (unsigned long) 0;
    std::unordered_set<std::string> distTags;

    PackumentVInfo(
            floco::util::DateTime                  time
    , const nlohmann::json                       & j
    ,       std::unordered_set<std::string_view>   distTags = {}
    ) : time( time ), VInfo( j )
    {
      for ( auto t : distTags ) { this->distTags.emplace( t ); }
    }

    /** Read a `PackumentVInfo' from a SQLite3 database. */
    PackumentVInfo( sqlite3pp::database & db
                  , floco::ident_view     name
                  , floco::version_view   version
                  );

    /** Write a `PackumentVInfo' to a SQLite3 database. */
    void sqlite3Write( sqlite3pp::database & db ) const;

};



/* -------------------------------------------------------------------------- */

/**
 * A registry document containing all information about all versions of a
 * module, where to download it, when each version was created, etc.
 * `PackumentVInfo' records are sub-records of this document.
 */
class Packument {

  protected:
    void init( const nlohmann::json & json );

  public:

    std::string  _id;   /* I think this is always the same as `name' */
    std::string  _rev;  /* "24-3aa1e8e9698a86126ecb287c637ef0fc */
    floco::ident name;

    /**
     * Maps package versions to the time they were published.
     * Two additional entries `modified' and `created' also appear here
     * which express the first publish date, and the most recent publish date.
     *
     * Example:
     * @code
     * {
     *   "modified": "2022-06-29T06:45:35.755Z",
     *   "created": "...",
     *   "1.0.0": "..."
     *   ...
     *   "4.0.0": "..."
     * }
     * @endcode
     */
    std::map<floco::version, floco::timestamp> time;

    /**
     * Maps version aliases to real version numbers.
     * This is similar to a "tagged ref" in many other tools.
     *
     * Example:
     * @code
     * {
     *   "latest": "4.0.0",
     *   "pre": "4.1.0-pre",
     *   ...
     * }
     * @endcode
     */
    std::map<std::string, floco::version> distTags;

    std::map<floco::version, PackumentVInfo> versions;

    Packument() {}
    Packument( const nlohmann::json & j ) { this->init( j ); }
    Packument( std::string_view url );

      std::map<floco::version_view, floco::timestamp_view>
    versionsBefore( floco::timestamp_view before ) const;

    /** Read a `Packument' from a SQLite3 database. */
    Packument( sqlite3pp::database & db
             , floco::ident_view     ident
             );

    /** Write a `Packument' to a SQLite3 database. */
    void sqlite3Write( sqlite3pp::database & db ) const;

    /** Convert a `Packument' to a JSON representation. */
    nlohmann::json toJSON() const;

    /** Get the `<name>@<version>` identifier used by NPM registries. */
    std::string id() const { return this->_id; }

    bool operator==( const Packument & other ) const;
    bool operator!=( const Packument & other ) const;

};


/* -------------------------------------------------------------------------- */

void to_json(         nlohmann::json & j, const Packument & p );
void from_json( const nlohmann::json & j,       Packument & p );


/* -------------------------------------------------------------------------- */

bool db_has(   sqlite3pp::database & db, floco::ident_view ident );
bool db_stale( sqlite3pp::database & db, floco::ident_view ident );


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::db' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
