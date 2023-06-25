/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <cstdlib>
#include <string>
#include "pjs-core.hh"
#include <optional>
#include "packument.hh"
#include "util.hh"


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace registry {

/* -------------------------------------------------------------------------- */

  static std::string
sttb16s( size_t x )
{
  static char buffer [64];
  memset( buffer, '\0', sizeof( buffer ) );
  snprintf( buffer, sizeof( buffer ), "%zx", x );
  return std::string( buffer );
}


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
      , _dbPath( std::string( util::globalEnv.getCacheDir() ) +
                 "/registry-cache-v0/" +
                 sttb16s( std::hash<std::string_view>{}( host ) ) + ".sqlite"
               )
    {}

    RegistryDb( PkgRegistry && reg )
      : PkgRegistry( std::move( reg ) )
      , _dbPath( std::string( util::globalEnv.getCacheDir() ) +
                 "/registry-cache-v0/" +
                 sttb16s( std::hash<std::string_view>{}( reg.host ) ) +
                 ".sqlite"
               )
    {}

    RegistryDb( const PkgRegistry & reg )
      : PkgRegistry( reg )
      , _dbPath( std::string( util::globalEnv.getCacheDir() ) +
                 "/registry-cache-v0/" +
                 sttb16s( std::hash<std::string_view>{}( reg.host ) ) +
                 ".sqlite"
               )
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
