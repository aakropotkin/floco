/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <string>
#include <nlohmann/json.hpp>
#include <optional>


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace util {

/* -------------------------------------------------------------------------- */

template <typename ValueType>
  static inline ValueType &
tryGetJSONTo( const nlohmann::json & j, std::string_view key, ValueType & t )
{
  try
    {
      j.at( key ).get_to( t );
    }
  catch ( ... )
    {}
  return t;
}


/* -------------------------------------------------------------------------- */

template <typename ValueType>
  static inline std::optional<ValueType>
maybeGetJSON( const nlohmann::json & j, std::string_view key )
{
  ValueType v;
  try
    {
      j.at( key ).get_to( v );
      return v;
    }
  catch ( ... )
    {}
  return std::nullopt;
}


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::util' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
