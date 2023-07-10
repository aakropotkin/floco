/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <list>
#include <nlohmann/json.hpp>
#include <string>
#include "sqlite3pp.h"
#include "pjs-core.hh"
#include <unordered_map>
#include <optional>
#include "pdef/dep-info.hh"
#include "pdef/peer-info.hh"
#include "pdef/sys-info.hh"


/* -------------------------------------------------------------------------- */

namespace floco {

/* -------------------------------------------------------------------------- */

enum ltype {
  LT_NONE = 0
, LT_FILE = 1
, LT_DIR  = 2
, LT_LINK = 3
};

ltype            parseLtype( std::string_view l );
std::string_view ltypeToString( const ltype & l );

NLOHMANN_JSON_SERIALIZE_ENUM( ltype, {
  { LT_NONE, nullptr }
, { LT_FILE, "file"  }
, { LT_DIR,  "dir"   }
, { LT_LINK, "link"  }
} )


/* -------------------------------------------------------------------------- */

class PdefCore {

  private:
    void reset();
    void init( const nlohmann::json & j );

  public:
    std::string    key;
    floco::ident   ident;
    floco::version version = "0.0.0-0";
    floco::ltype   ltype   = LT_NONE;

    std::string    fetcher   = "composed";
    nlohmann::json fetchInfo = nlohmann::json::object();

    struct {
      bool build   = false;
      bool install = false;
    } lifecycle;

    struct {
      std::optional<std::string>                                  binDir;
      std::optional<std::unordered_map<std::string, std::string>> binPairs;
    } binInfo;

    struct {
      std::string dir        = ".";
      bool        gypfile    = false;
      bool        shrinkwrap = false;
    } fsInfo;

    DepInfo  depInfo;
    PeerInfo peerInfo;
    SysInfo  sysInfo;

    PdefCore() = default;
    PdefCore( const nlohmann::json & j ) { this->init( j ); }
    PdefCore( sqlite3pp::database & db
            , floco::ident_view     ident
            , floco::version_view   version
            );

    PdefCore( const db::PjsCore & pjs  );
    PdefCore(       db::PjsCore && pjs );

    PdefCore & operator=(       db::PjsCore && pjs );
    PdefCore & operator=( const db::PjsCore &  pjs );

    nlohmann::json toJSON() const;

    void sqlite3WriteCore( sqlite3pp::database & db ) const;
    void sqlite3Write(     sqlite3pp::database & db ) const;

    friend void from_json( const nlohmann::json & j, PdefCore & p );

};  /* End class `PdefCore' */


void from_json( const nlohmann::json & j,       PdefCore & p );
void to_json(         nlohmann::json & j, const PdefCore & p );


/* -------------------------------------------------------------------------- */

}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
