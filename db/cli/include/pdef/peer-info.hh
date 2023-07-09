/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <bitset>
#include <nlohmann/json.hpp>
#include <string>
#include "sqlite3pp.h"
#include "pjs-core.hh"


/* -------------------------------------------------------------------------- */

namespace floco {

/* -------------------------------------------------------------------------- */

class PeerInfo {

  private:
    void init( const nlohmann::json & j );

  public:

/* -------------------------------------------------------------------------- */

    class Ent {
      private:
        void init( const nlohmann::json & j );

      public:
        floco::ident      ident;
        floco::descriptor descriptor = "*";
        bool              optional   = false;

        Ent() = default;

        Ent( std::string_view descriptor = "*"
           , bool optional               = false
           )
          : descriptor( descriptor ), optional( optional )
        {}

        Ent( const nlohmann::json & j ) { this->init( j ); }

        Ent( sqlite3pp::database & db
           , floco::ident_view     parent_ident
           , floco::version_view   parent_version
           , floco::ident_view     ident
           );

        nlohmann::json toJSON() const;
        void           sqlite3Write( sqlite3pp::database & db
                                   , floco::ident_view     parent_ident
                                   , floco::version_view   parent_version
                                   , floco::ident_view     ident
                                   ) const;

        friend void from_json( const nlohmann::json & j, Ent & e );

    };  /* End class `PeerInfo::Ent' */


/* -------------------------------------------------------------------------- */

    std::unordered_map<floco::ident, Ent> peers;

    PeerInfo() = default;
    PeerInfo( const nlohmann::json & j ) { this->init( j ); }
    PeerInfo( sqlite3pp::database & db
            , floco::ident_view     parent_ident
            , floco::version_view   parent_version
            );

    nlohmann::json toJSON() const;
    void           sqlite3Write( sqlite3pp::database & db
                               , floco::ident_view     parent_ident
                               , floco::version_view   parent_version
                               ) const;

    friend void from_json( const nlohmann::json & j, PeerInfo & d );

};  /* End class `PeerInfo' */


/* -------------------------------------------------------------------------- */

/* `PeerInfo' <--> JSON */
void to_json(         nlohmann::json & j, const PeerInfo & e );
void from_json( const nlohmann::json & j,       PeerInfo & e );

/* `PeerInfo::Ent' <--> JSON */
void to_json(         nlohmann::json & j, const PeerInfo::Ent & e );
void from_json( const nlohmann::json & j,       PeerInfo::Ent & e );


/* -------------------------------------------------------------------------- */

}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
