/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <string>
#include "pjs-core.hh"
#include <optional>
#include "packument.hh"
#include "util.hh"


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace registry {

/* -------------------------------------------------------------------------- */

class RegistryDb : PkgRegistry {
  private:
    std::string                          _dbPath;
    std::unique_ptr<sqlite3pp::database> _db;

  public:
    RegistryDb(
      std::string_view             host     = "registry.npmjs.org"
    , std::string_view             protocol = "https"
    , std::optional<PkgRegistry *> fallback = std::nullopt
    ) : PkgRegistry( host, protocol, fallback )
      , _dbPath( util::getRegistryDbPath( host ) )
    {}

    RegistryDb( PkgRegistry && reg )
      : PkgRegistry( std::move( reg ) )
      , _dbPath( util::getRegistryDbPath( reg.host ) )
    {}

    RegistryDb( const PkgRegistry & reg )
      : PkgRegistry( reg ), _dbPath( util::getRegistryDbPath( reg.host ) )
    {}

    bool exists() const;
    bool create( bool recreate = false );

    std::string_view getDbPath() const { return this->_dbPath; }

    std::reference_wrapper<sqlite3pp::database> getDb( bool create = true );

      bool
    has( floco::ident_view ident )
    {
      return this->exists() && db::db_has( this->getDb().get(), ident );
    }

      bool
    stale( floco::ident_view ident )
    {
      return ( ! this->exists() ) || db::db_stale( this->getDb().get(), ident );
    }

    db::Packument      get( floco::ident_view ident );
    db::PackumentVInfo get( floco::ident_view   ident
                          , floco::version_view version
                          );


};  /* End class `RegistryDb' */


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::registry' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
