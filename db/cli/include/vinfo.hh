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
    void init(       std::string_view   url
             , const nlohmann::json   & json
             ,       unsigned long      timestamp = std::time( nullptr )
             );

  public:

    std::string    _id;  /* <name>@<version> */
    std::string    homepage;
    std::string    description;
    std::string    license        = "unlicensed";
    nlohmann::json repository     = nlohmann::json::object();
    nlohmann::json dist           = nlohmann::json::object();
    bool           _hasShrinkwrap = false;

    VInfo(       std::string_view   url
         , const nlohmann::json   & json
         ,       unsigned long      timestamp = std::time( nullptr )
         )
    {
      this->init( url, json, timestamp );
    }

    VInfo( std::string_view url );

};


/* -------------------------------------------------------------------------- */

void to_json( nlohmann::json & j, const VInfo & v );
void from_json( const nlohmann::json & j, VInfo & v );


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::db' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
