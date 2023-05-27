/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <string>
#include <vector>
#include <filesystem>
#include <utility>
#include <stdexcept>
#include <chrono>
#include <cstdio>
#include <fstream>

#include <nlohmann/json.hpp>
#include <unordered_map>

#include "fetch.hh"


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace db {

/* -------------------------------------------------------------------------- */

  static inline bool
pathIsJSFile( std::string_view p )
{
  size_t l = p.length();
  return ( p[l - 3] == '.' ) && ( p[l - 2] == 'j' ) && ( p[l - 1] == 's' );
}


/* -------------------------------------------------------------------------- */

typedef std::unordered_map<std::string, std::string>  bin_pairs;


class BinInfo {

  bool        _isPairs;
  std::string _binDir;
  bin_pairs   _binPairs;

  void initByStrings( std::string_view name, std::string_view s );
  void initByObject( const nlohmann::json & j );

  public:

    BinInfo()                       : _binPairs( {} ),    _isPairs( true )  {}
    BinInfo( std::string_view dir ) : _binDir( dir ),     _isPairs( false ) {}
    BinInfo( bin_pairs pairs )      : _binPairs( pairs ), _isPairs( true )  {}
    BinInfo( std::string_view name, std::string_view s );
    BinInfo( const nlohmann::json & j );
    BinInfo( std::string_view name, const nlohmann::json & j );

    bool             isPairs()    const { return this->_isPairs; }
    bool             isDir()      const { return ! this->_isPairs; }
    std::string_view binDir()     const { return this->_binDir; }
    bin_pairs        binPairs()   const { return this->_binPairs; }
    nlohmann::json   toJSON()     const;
    std::string      toSQLValue() const;

};  /* End `BinInfo' */


/* `BinInfo' <--> JSON */
void to_json( nlohmann::json & j, const BinInfo & b );
void from_json( const nlohmann::json & j, BinInfo & b );


/* -------------------------------------------------------------------------- */

class PjsCore {

  void init(       std::string_view   url
           , const nlohmann::json   & json
           ,       unsigned long      timestamp = std::time( nullptr )
           );

  public:

    std::string    url;
    unsigned long  timestamp;
    std::string    name;
    std::string    version              = "0.0.0-0";
    nlohmann::json bin                  = nlohmann::json::object();
    nlohmann::json dependencies         = nlohmann::json::object();
    nlohmann::json devDependencies      = nlohmann::json::object();
    nlohmann::json devDependenciesMeta  = nlohmann::json::object();
    nlohmann::json peerDependencies     = nlohmann::json::object();
    nlohmann::json peerDependenciesMeta = nlohmann::json::object();
    nlohmann::json os                   = nlohmann::json::array( { "*" } );
    nlohmann::json cpu                  = nlohmann::json::array( { "*" } );
    nlohmann::json engines              = nlohmann::json::object();

    PjsCore(       std::string_view   url
           , const nlohmann::json   & json
           ,       unsigned long      timestamp = std::time( nullptr )
           )
    {
      this->init( url, json, timestamp );
    }

    PjsCore( std::string_view url )
    {
      std::string   tmp = std::tmpnam( nullptr );
      std::string   _url( url );
      unsigned long timestamp = std::time( nullptr );
      floco::fetch::curlFile( _url.c_str(), tmp.c_str() );
      std::ifstream f( tmp );
      nlohmann::json json = nlohmann::json::parse( f );
      f.close();
      remove( tmp.c_str() );
      this->init( url, json, timestamp );
    }

};


/* -------------------------------------------------------------------------- */

const std::string pjsJsonToSQL( const std::string   url
                              , nlohmann::json    & pjs
                              , unsigned long       timestamp = 0 );



/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::db' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
