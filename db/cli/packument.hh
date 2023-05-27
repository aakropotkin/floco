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
  std::map<std::string, std::string> dist_tags;

  //Packument( std::string_view url );
  Packument() {}

};


/* -------------------------------------------------------------------------- */

  void
to_json( nlohmann::json & j, const Packument & p )
{
  j = nlohmann::json {
    { "_id",       p._id }
  , { "_rev",      p._rev }
  , { "name",      p.name }
  , { "time",      p.time }
  , { "dist-tags", p.dist_tags }
  };
}

  void
from_json( const nlohmann::json & j, Packument & p )
{
  j.at( "_id" ).get_to( p._id );
  j.at( "_rev" ).get_to( p._rev );
  j.at( "name" ).get_to( p.name );
  j.at( "time" ).get_to( p.time );
  j.at( "dist-tags" ).get_to( p.dist_tags );
}


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::db' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
