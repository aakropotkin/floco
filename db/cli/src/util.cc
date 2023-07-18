/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include <cstdlib>
#include <cstring>
#include <stdexcept>
#include <filesystem>
#include "util.hh"
#include <nix/fetchers.hh>
#include <nix/store-api.hh>
#include <nix/shared.hh>
#include <nix/eval-inline.hh>
#include "floco-registry.hh"


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace util {

/* -------------------------------------------------------------------------- */

  std::string_view
Env::getHome()
{
  if ( this->_home.empty() )
    {
      if ( const char * v = std::getenv( "HOME" ) )
        {
          this->_home = std::string( v );
        }
      else
        {
          throw std::invalid_argument( "Env variable `HOME' is unset" );
        }
    }
  return this->_home;
}


/* -------------------------------------------------------------------------- */

  std::string_view
Env::getTmpDir()
{
  if ( this->_tmp_dir.empty() )
    {
      this->_tmp_dir = std::filesystem::temp_directory_path();
    }
  return this->_tmp_dir;
}


/* -------------------------------------------------------------------------- */

  std::string_view
Env::getCacheHome()
{
  if ( this->_xdg_cache_home.empty() )
    {
      if ( const char * v = std::getenv( "XDG_CACHE_HOME" ) )
        {
          this->_xdg_cache_home = std::string( v );
        }
      else
        {
          this->_xdg_cache_home =  this->getHome();
          this->_xdg_cache_home += "/.cache";
        }
    }
  return this->_xdg_cache_home;
}


/* -------------------------------------------------------------------------- */

  std::string_view
Env::getConfigHome()
{
  if ( this->_xdg_config_home.empty() )
    {
      if ( const char * v = std::getenv( "XDG_CONFIG_HOME" ) )
        {
          this->_xdg_config_home = std::string( v );
        }
      else
        {
          this->_xdg_config_home =  this->getHome();
          this->_xdg_config_home += "/.config";
        }
    }
  return this->_xdg_config_home;
}


/* -------------------------------------------------------------------------- */

  std::string_view
Env::getCacheDir()
{
  if ( this->_floco_cache_dir.empty() )
    {
      if ( const char * v = std::getenv( "FLOCO_CACHE_DIR" ) )
        {
          this->_floco_cache_dir = std::string( v );
        }
      else
        {
          this->_floco_cache_dir =  this->getCacheHome();
          this->_floco_cache_dir += "/floco";
        }
    }
  return this->_floco_cache_dir;
}


/* -------------------------------------------------------------------------- */

  std::string_view
Env::getRegistryCacheDir()
{
  if ( this->_registry_cache_dir.empty() )
    {
      this->_registry_cache_dir =  this->getCacheDir();
      this->_registry_cache_dir += "/registry-cache-v0";
    }
  return this->_registry_cache_dir;
}


/* -------------------------------------------------------------------------- */

  std::string_view
Env::getConfigDir()
{
  if ( this->_floco_config_dir.empty() )
    {
      if ( const char * v = std::getenv( "FLOCO_CONFIG_DIR" ) )
        {
          this->_floco_config_dir = std::string( v );
        }
      else
        {
          this->_floco_config_dir =  this->getConfigHome();
          this->_floco_config_dir += "/floco";
        }
    }
  return this->_floco_config_dir;
}


/* -------------------------------------------------------------------------- */

Env globalEnv;


/* -------------------------------------------------------------------------- */

  std::string
sizeTypeTo16bitString( size_t x )
{
  static char buffer [64];
  memset( buffer, '\0', sizeof( buffer ) );
  snprintf( buffer, sizeof( buffer ), "%zx", x );
  return std::string( buffer );
}


/* -------------------------------------------------------------------------- */

  std::string
getStrFingerprint( std::string_view s )
{
  return sizeTypeTo16bitString( std::hash<std::string_view>{}( s ) );
}


/* -------------------------------------------------------------------------- */

  std::string
getRegistryDbPath( std::string_view host )
{
  std::string path( globalEnv.getRegistryCacheDir() );
  path += "/" + getStrFingerprint( host ) + ".sqlite";
  return path;
}


/* -------------------------------------------------------------------------- */

static bool didInitNix = false;

  void
initNix()
{
  if ( didInitNix ) { return; }
  nix::initNix();
  nix::initGC();

  /* NOTE: Store settings use `nix::settings' not `nix::globalConfig'. */
  nix::evalSettings.pureEval = false;
  nix::settings.tarballTtl   = floco::registry::registryTTL;

  didInitNix = true;
}



/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::util' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
