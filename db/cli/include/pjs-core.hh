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


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace db {

/* -------------------------------------------------------------------------- */

class PjsCore {

  protected:
    void init( const nlohmann::json & json );

  public:
    std::string    name;
    std::string    version              = "0.0.0-0";
    nlohmann::json bin                  = nlohmann::json::object();
    nlohmann::json dependencies         = nlohmann::json::object();
    nlohmann::json devDependencies      = nlohmann::json::object();
    nlohmann::json devDependenciesMeta  = nlohmann::json::object();
    nlohmann::json peerDependencies     = nlohmann::json::object();
    nlohmann::json peerDependenciesMeta = nlohmann::json::object();
    nlohmann::json os                   = nlohmann::json::array( { "*" } );
    nlohmann::json cpu                  = nlohmann::json::array( { "*" } );
    nlohmann::json engines              = nlohmann::json::object();

    PjsCore() {}

    PjsCore( const nlohmann::json & json )
    {
      this->init( json );
    }

    PjsCore( std::string_view url );

};


/* -------------------------------------------------------------------------- */

const std::string pjsJsonToSQL( nlohmann::json & pjs );



/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::db' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
