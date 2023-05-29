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

/* -------------------------------------------------------------------------- */

namespace floco {
  namespace db {

/* -------------------------------------------------------------------------- */

struct Packument {

  //std::string url;

  std::string _id;   /* I think this is always the same as `name' */
  std::string _rev;  /* "24-3aa1e8e9698a86126ecb287c637ef0fc */
  std::string name;
  /**
   * {
   *   "modified": "2022-06-29T06:45:35.755Z",
   *   "created": "...",
   *   "1.0.0": "..."
   *   ...
   *   "4.0.0": "..."
   * }
   */
  std::map<std::string, std::string> time;
  /**
   * {
   *   "latest": "4.0.0",
   *   "pre": "4.1.0-pre",
   *   ...
   * }
   */
  std::map<std::string, std::string>    dist_tags;
  std::map<std::string, nlohmann::json> versions;


  Packument( const nlohmann::json & j );
  Packument( std::string_view url );
  Packument() {}

    std::map<std::string_view, std::string_view>
  versionsBefore( std::string_view before );

};


/* -------------------------------------------------------------------------- */

void to_json( nlohmann::json & j, const Packument & p );
void from_json( const nlohmann::json & j, Packument & p );


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::db' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
