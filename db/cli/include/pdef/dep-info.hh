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

class DepInfoEnt {
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
    floco::ident      ident;
    floco::descriptor descriptor = "*";

    DepInfoEnt() = default;

    DepInfoEnt(
      std::string_view ident
    , std::string_view descriptor = "*"
    , bool runtime                = false
    , bool dev                    = true
    , bool optional               = false
    , bool bundled                = false
    ) : ident( ident ), descriptor( descriptor )
    {
      this->initFlags( runtime, dev, optional, bundled );
    }

    DepInfoEnt(       floco::ident_view   ident
              , const nlohmann::json    & j
              )
      : ident( ident )
    {
      this->init( j );
    }

    DepInfoEnt( sqlite3pp::database & db
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
                               ) const;

    friend void from_json( const  nlohmann::json & j, DepInfoEnt & e );

};  /* End `DepInfoEnt' */


/* `DepInfoEnt' <--> JSON */
void to_json(         nlohmann::json & j, const DepInfoEnt & e );
void from_json( const nlohmann::json & j,       DepInfoEnt & e );


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::db' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
