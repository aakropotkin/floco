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


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace registry {

/* -------------------------------------------------------------------------- */

// TODO: create `floco-config.h' configurable header.

/**
 * Number of seconds before cached lookups are invalidated.
 * Default is 3,600s ( 1hr ), but this may be overridden globally;
 */
#ifdef FLOCO_REGISTRY_TTL
  static unsigned long registryTTL = FLOCO_REGISTRY_TTL;
#else
  static unsigned long registryTTL = 3600;
#endif


/* -------------------------------------------------------------------------- */

class PkgRegistry {
  public:
    std::string                  protocol = "https";
    std::string                  host     = "registry.npmjs.org";
    std::optional<PkgRegistry *> fallback = std::nullopt;

    PkgRegistry(
      std::string_view             host     = "registry.npmjs.org"
    , std::string_view             protocol = "https"
    , std::optional<PkgRegistry *> fallback = std::nullopt
    ) : host( host ), protocol( protocol ), fallback( fallback )
    {}

    std::string getPackumentURL( floco::ident_view ident ) const;
    std::string getVInfoURL( floco::ident_view ident
                           , floco::version_view version
                           ) const;
};


/* -------------------------------------------------------------------------- */

extern PkgRegistry defaultRegistry;


/* -------------------------------------------------------------------------- */

  static std::string
getCacheDir()
{
  if ( const char * xdg = std::getenv( "XDG_CACHE_HOME" ) )
    {
      std::string path( xdg );
      path += "/floco";
      return path;
    }
  else if ( const char * home = std::getenv( "HOME" ) )
    {
      std::string path( home );
      path += ".cache/floco";
      return path;
    }
  else if ( const char * tmp = std::getenv( "TMP" ) )
    {
      std::string path( tmp );
      path += "floco-cache";
      return path;
    }
  else
    {
      return "/tmp/floco-cache";
    }
}

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
      , _dbPath( getCacheDir() + "/registry-cache-v0/" +
                 sttb16s( std::hash<std::string_view>{}( host ) ) + ".sqlite"
               )
    {}

    RegistryDb( PkgRegistry && reg )
      : PkgRegistry( std::move( reg ) )
      , _dbPath( getCacheDir() + "/registry-cache-v0/" +
                 sttb16s( std::hash<std::string_view>{}( reg.host ) ) +
                 ".sqlite"
               )
    {}

    RegistryDb( const PkgRegistry & reg )
      : PkgRegistry( reg )
      , _dbPath( getCacheDir() + "/registry-cache-v0/" +
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
