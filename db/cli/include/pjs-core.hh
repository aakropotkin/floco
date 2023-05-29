/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <ctime>                  // for time, size_t
#include <map>                    // for operator!=
#include <nlohmann/json.hpp>      // for basic_json
#include <nlohmann/json_fwd.hpp>  // for json
#include <string>                 // for string, basic_string, hash, allocator
#include <string_view>            // for string_view, basic_string_view
#include <unordered_map>          // for unordered_map


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

  protected:
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

    PjsCore() {}

    PjsCore(       std::string_view   url
           , const nlohmann::json   & json
           ,       unsigned long      timestamp = std::time( nullptr )
           )
    {
      this->init( url, json, timestamp );
    }

    PjsCore( std::string_view url );

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
