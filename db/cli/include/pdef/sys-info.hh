/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <list>
#include <nlohmann/json.hpp>      // for basic_json
#include <string>                 // for string, basic_string, hash, allocator
#include "sqlite3pp.h"
#include "pjs-core.hh"


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace db {

/* -------------------------------------------------------------------------- */

class SysInfoEngineEnt {
  public:
    std::string            id;
    std::list<std::string> value;

    SysInfoEngineEnt() = default;

    SysInfoEngineEnt(
            std::string_view         id
    , const std::list<std::string> & value
    ) : id( id ), value( value )
    {}

    SysInfoEngineEnt(       std::string_view    id
                    , const nlohmann::json    & j
                    )
      : id( id ), value( j )
    {}

    SysInfoEngineEnt( sqlite3pp::database & db
                    , floco::ident_view     parent_ident
                    , floco::version_view   parent_version
                    , std::string_view      id
                    );

    nlohmann::json toJSON() const;
    void           sqlite3Write( sqlite3pp::database & db
                               , floco::ident_view     parent_ident
                               , floco::version_view   parent_version
                               ) const;

    friend void from_json( const  nlohmann::json & j, SysInfoEngineEnt & e );

};  /* End `SysInfoEngineEnt' */


/* `SysInfoEngineEnt' <--> JSON */
void to_json(         nlohmann::json & j, const SysInfoEngineEnt & e );
void from_json( const nlohmann::json & j,       SysInfoEngineEnt & e );


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::db' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
