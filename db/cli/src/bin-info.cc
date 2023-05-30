/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include "bin-info.hh"
#include <cstdio>                                         // for snprintf
#include <filesystem>                                     // for path
#include <fstream>                                        // for ifstream
#include <initializer_list>                               // for initializer...
#include <nlohmann/detail/iterators/iter_impl.hpp>        // for iter_impl
#include <nlohmann/detail/iterators/iteration_proxy.hpp>  // for iteration_p...
#include <nlohmann/detail/json_ref.hpp>                   // for json_ref
#include <nlohmann/detail/value_t.hpp>                    // for value_t
#include <nlohmann/json.hpp>                              // for basic_json
#include <stdexcept>                                      // for invalid_arg...
#include <string>                                         // for string, bas...
#include <utility>                                        // for make_pair
#include <vector>                                         // for vector


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace db {

/* -------------------------------------------------------------------------- */

/* `BinInfo' Implementations */

BinInfo::BinInfo( std::string_view name, std::string_view s )
{
  initByStrings( name, s );
}

BinInfo::BinInfo( const nlohmann::json & j )
{
  if ( j.type() != nlohmann::json::value_t::object )
    {
      throw std::invalid_argument(
        "BinInfo JSON without a name must be an object of strings"
      );
    }
  this->initByObject( j );
}

BinInfo::BinInfo( std::string_view name, const nlohmann::json & j )
{
  nlohmann::json::value_t t = j.type();
  if ( t == nlohmann::json::value_t::object )
    {
      this->initByObject( j );
    }
  else if ( t == nlohmann::json::value_t::string )
    {
      this->initByStrings( name, j.get<std::string_view>() );
    }
  else
    {
      throw std::invalid_argument(
        "BinInfo JSON must be a string or object of strings"
      );
    }
}

  void
BinInfo::initByStrings( std::string_view name, std::string_view s )
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

  void
BinInfo::initByObject( const nlohmann::json & j )
{
  for ( auto & [bname, path] : j.items() )
    {
      this->_binPairs.emplace( std::make_pair( bname, path ) );
    }
  this->_isPairs = true;
}


  nlohmann::json
BinInfo::toJSON() const
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
BinInfo::toSQLValue() const
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


/* -------------------------------------------------------------------------- */

/* `BinInfo' <--> JSON */

void to_json( nlohmann::json & j, const BinInfo & b ) { j = b.toJSON(); }

  void
from_json( const nlohmann::json & j, BinInfo & b )
{
  if ( j.contains( "name" ) )
    {
      if ( j.contains( "bin" ) )
        {
          b = BinInfo( j["name"].get<std::string_view>(), j["bin"] );
        }
      else
        {
          b = BinInfo();
        }
    }
  else
    {
      if ( j.contains( "bin" ) )
        {
          b = BinInfo( j["bin"] );
        }
      else
        {
          b = BinInfo( j );
        }
    }
}


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::db' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
