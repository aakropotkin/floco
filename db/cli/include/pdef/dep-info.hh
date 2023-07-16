/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <list>
#include <bitset>
#include <nlohmann/json.hpp>      // for basic_json
#include <string>                 // for string, basic_string, hash, allocator
#include "sqlite3pp.h"
#include "pjs-core.hh"


/* -------------------------------------------------------------------------- */

namespace floco {

/* -------------------------------------------------------------------------- */

class DepInfo {

  private:
    void init( const nlohmann::json & j );

  public:

/* -------------------------------------------------------------------------- */

    class Ent {
      friend class DepInfo;
      private:
        /** runtime, dev, optional, bundled */
        std::bitset<4> _flags = 0b0100;
        void initFlags(
          bool runtime  = false
        , bool dev      = true
        , bool optional = false
        , bool bundled  = false
        )
        {
          this->_flags.set( 0, runtime  );
          this->_flags.set( 1, dev      );
          this->_flags.set( 2, optional );
          this->_flags.set( 3, bundled  );
        }
        void init( const nlohmann::json & j );

      public:
        floco::descriptor descriptor = "*";

        Ent() = default;

        Ent( floco::descriptor_view descriptor
           , bool                   runtime    = false
           , bool                   dev        = true
           , bool                   optional   = false
           , bool                   bundled    = false
           )
          : descriptor( descriptor )
        {
          this->initFlags( runtime, dev, optional, bundled );
        }

        Ent( const nlohmann::json & j ) { this->init( j ); }

        Ent( sqlite3pp::database & db
           , floco::ident_view     parent_ident
           , floco::version_view   parent_version
           , floco::ident_view     ident
           );

        bool runtime()  const { return this->_flags[0]; }
        bool dev()      const { return this->_flags[1]; }
        bool optional() const { return this->_flags[2]; }
        bool bundled()  const { return this->_flags[3]; }

        nlohmann::json toJSON() const;
        void           sqlite3Write( sqlite3pp::database & db
                                   , floco::ident_view     parent_ident
                                   , floco::version_view   parent_version
                                   , floco::ident_view     ident
                                   ) const;

        friend void from_json( const nlohmann::json & j, Ent & e );

    };  /* End class `DepInfo::Ent' */


/* -------------------------------------------------------------------------- */

    std::unordered_map<floco::ident, Ent> deps;

    DepInfo() = default;
    DepInfo( sqlite3pp::database & db
           , floco::ident_view     parent_ident
           , floco::version_view   parent_version
           );
    DepInfo( const db::PjsCore & pjs );

    explicit DepInfo( const nlohmann::json & j ) { this->init( j ); }

    DepInfo & operator=( const db::PjsCore & pjs );

    nlohmann::json toJSON() const;
    void           sqlite3Write( sqlite3pp::database & db
                               , floco::ident_view     parent_ident
                               , floco::version_view   parent_version
                               ) const;

    void reset()        { this->deps = {};            }
    auto size()   const { return this->deps.size();   }
    auto empty()  const { return this->deps.empty();  }
    auto begin()        { return this->deps.begin();  }
    auto begin()  const { return this->deps.begin();  }
    auto cbegin()       { return this->deps.cbegin(); }
    auto end()          { return this->deps.end();    }
    auto end()    const { return this->deps.end();    }
    auto cend()         { return this->deps.cend();   }


    friend void from_json( const nlohmann::json & j, DepInfo & d );

    friend class db::PjsCore;

};  /* End class `DepInfo' */


/* -------------------------------------------------------------------------- */

/* `DepInfo' <--> JSON */
void to_json(         nlohmann::json & j, const DepInfo & d );
void from_json( const nlohmann::json & j,       DepInfo & d );

/* `DepInfo::Ent' <--> JSON */
void to_json(         nlohmann::json & j, const DepInfo::Ent & e );
void from_json( const nlohmann::json & j,       DepInfo::Ent & e );


/* -------------------------------------------------------------------------- */

}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
