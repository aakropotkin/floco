/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <string>


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace util {

/* -------------------------------------------------------------------------- */

class Env {
  private:
    std::string _home;
    std::string _tmp_dir;
    std::string _xdg_cache_home;
    std::string _xdg_config_home;
    std::string _floco_cache_dir;
    std::string _registry_cache_dir;
    std::string _floco_config_dir;
  public:
    std::string_view getHome();
    std::string_view getTmpDir();
    std::string_view getCacheHome();
    std::string_view getConfigHome();
    std::string_view getCacheDir();
    std::string_view getRegistryCacheDir();
    std::string_view getConfigDir();
};


extern Env globalEnv;


/* -------------------------------------------------------------------------- */

std::string sizeTypeTo16bitString( size_t x );
std::string getStrFingerprint( std::string_view s );


/* -------------------------------------------------------------------------- */

std::string getRegistryDbPath( std::string_view host );


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::util' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
