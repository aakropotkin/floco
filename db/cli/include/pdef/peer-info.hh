/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <bitset>
#include <nlohmann/json.hpp>      // for basic_json
#include <string>                 // for string, basic_string, hash, allocator
#include "sqlite3pp.h"
#include "pjs-core.hh"


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace db {

/* -------------------------------------------------------------------------- */

class PeerInfoEnt {
  private:
    void init( const nlohmann::json & j );

  public:
    floco::ident      ident;
    floco::descriptor descriptor = "*";
    bool              optional   = false;

    PeerInfoEnt() = default;

    PeerInfoEnt(
      std::string_view ident
    , std::string_view descriptor = "*"
    , bool optional               = false
    ) : ident( ident ), descriptor( descriptor ), optional( optional )
    {}

    PeerInfoEnt(       floco::ident_view   ident
               , const nlohmann::json    & j
               )
      : ident( ident )
    {
      this->init( j );
    }

    PeerInfoEnt( sqlite3pp::database & db
               , floco::ident_view     parent_ident
               , floco::version_view   parent_version
               , floco::ident_view     ident
               );

    nlohmann::json toJSON() const;
    void           sqlite3Write( sqlite3pp::database & db
                               , floco::ident_view     parent_ident
                               , floco::version_view   parent_version
                               ) const;

    friend void from_json( const  nlohmann::json & j, PeerInfoEnt & e );

};  /* End `PeerInfoEnt' */


/* `PeerInfoEnt' <--> JSON */
void to_json(         nlohmann::json & j, const PeerInfoEnt & e );
void from_json( const nlohmann::json & j,       PeerInfoEnt & e );


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::db' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
