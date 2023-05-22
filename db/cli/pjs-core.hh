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

#include <nlohmann/json.hpp>
#include <unordered_map>


/* -------------------------------------------------------------------------- */

  static inline bool
pathIsJSFile( std::string_view p )
{
  size_t l = p.length();
  return ( p[l - 3] == '.' ) && ( p[l - 2] == 'j' ) && ( p[l - 1] == 's' );
}



/* -------------------------------------------------------------------------- */

class BinInfo {

  bool                                         _isPairs;
  std::string                                  _binDir;
  std::unordered_map<std::string, std::string> _binPairs;

    void
  initByStrings( std::string_view name, std::string_view s )
  {
    if ( pathIsJSFile( s ) )
      {
        if ( name[0] == '@' )
          {
            std::filesystem::path bname( name );
            this->_binPairs.emplace( std::make_pair( bname.filename(), s ) );
          }
        else
          {
            this->_binPairs.emplace( std::make_pair( name, s ) );
          }
        this->_isPairs = true;
      }
    else
      {
        this->_binDir  = s;
        this->_isPairs = false;
      }
  }

  public:
    BinInfo( std::string_view name, std::string_view s )
    {
      initByStrings( name, s );
    }

    BinInfo( std::string_view dir ) : _binDir( dir ), _isPairs( false ) {}

    BinInfo( std::unordered_map<std::string, std::string> pairs )
      : _binPairs( pairs )
      , _isPairs( true )
    {}

    BinInfo( std::string_view name, const nlohmann::json & j )
    {
      nlohmann::json::value_t t = j.type();
      if ( t == nlohmann::json::value_t::object )
        {
          for ( auto & [bname, path] : j.items() )
            {
              this->_binPairs.emplace( std::make_pair( bname, path ) );
            }
          this->_isPairs = true;
        }
      else if ( t == nlohmann::json::value_t::string )
        {
          initByStrings( name, j.get<std::string_view>() );
        }
      else
        {
          throw std::invalid_argument(
            "BinInfo JSON must be a string or object of strings"
          );
        }
    }

    bool isPairs() { return this->_isPairs; }
    bool isDir()   { return ! this->_isPairs; }

    std::string_view binDir() { return this->_binDir; }

      std::unordered_map<std::string, std::string>
    binPairs()
    {
      return this->_binPairs;
    }

      nlohmann::json
    toJSON()
    {
      nlohmann::json j;
      if ( this->_isPairs )
        {
          j = nlohmann::json::object();
          for ( auto & [bname, path] : this->_binPairs )
            {
              j[bname] = path;
            }
        }
      else
        {
          j = this->_binDir;
        }
      return j;
    }

      std::string
    toSQLValue()
    {
      std::string sql;
      if ( this->_isPairs )
        {
          sql = "'{";
          for ( auto & [bname, path] : this->_binPairs )
            {
              sql += "\"" + bname + "\":\"" + path + "\",";
            }
          sql[sql.length() - 1] = '}';
          sql += "'";
        }
      else
        {
          sql = "'" + this->_binDir + "'";
        }
      return sql;
    }

};


/* -------------------------------------------------------------------------- */

struct PjsCore {

  std::string    url;
  unsigned long  timestamp;
  std::string    name;
  std::string    version;
  nlohmann::json bin;
  nlohmann::json dependencies;
  nlohmann::json devDependencies;
  nlohmann::json devDependenciesMeta;
  nlohmann::json peerDependencies;
  nlohmann::json peerDependenciesMeta;
  nlohmann::json os;
  nlohmann::json cpu;
  nlohmann::json engines;

};


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
