/* ========================================================================== *
 *
 * Types and constants
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <optional>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <utility>

/* -------------------------------------------------------------------------- */

namespace floco {
  namespace graph {

/* -------------------------------------------------------------------------- */

class Node;
class Edge;
class Package;


/* -------------------------------------------------------------------------- */

typedef std::string  ident_t;
typedef std::string  version_t;
typedef std::string  spec_t;

typedef std::unordered_map<ident_t, spec_t>  dep_map_t;
typedef std::unordered_set<ident_t>          dep_set_t;

typedef std::optional<std::pair<ident_t, std::string>>  overrides_elem_t;
typedef std::unordered_map<ident_t, std::string>        overrides_t;

typedef std::unordered_set<Edge *>           edge_set_t;
typedef std::unordered_map<ident_t, Edge *>  edge_map_t;


/* -------------------------------------------------------------------------- */

enum EdgeType {
  prod
, dev
, optional
, peer
, peerOptional
, workspace
};

enum EdgeError {
  missing
, invalid
, peer_local
, detached
, ok
};


/* -------------------------------------------------------------------------- */

  };
};


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
