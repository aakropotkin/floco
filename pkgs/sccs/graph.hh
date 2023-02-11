/* ========================================================================== *
 *
 * Parse package specs, identifiers, descriptors, etc.
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <optional>
#include <string>
#include <unordered_map>
#include <unordered_set>

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


/* -------------------------------------------------------------------------- */

enum EdgeType {
  prod,
  dev,
  optional,
  peer,
  peerOptional,
  workspace
};

enum EdgeError {
  missing,
  invalid,
  peer_local,
  detached,
  ok
};


/* -------------------------------------------------------------------------- */

class Edge {

  /* Data */
  EdgeType      _type;
  ident_t       _name;
  spec_t        _spec;
  std::string   _accept;
  const Node  * _from;
  const Node  * _to;
  bool          _peerConflicted;
  bool          _overridden;

  std::optional<EdgeError> _error;

  std::unordered_map<ident_t, std::string> _overrides;


  public:
    /* Accessors */
    spec_t        spec()    const;
    EdgeType      type()    const { return this->_type; }
    ident_t       name()    const { return this->_name; }
    spec_t        rawSpec() const { return this->_spec; }
    std::string   accept()  const { return this->_accept; }
    const Node  * from()    const { return this->_from; }
    const Node  * to()      const { return this->_to; }


    /* Predicates */
    bool bundled()   const;
    bool workspace() const { return this->_type == EdgeType::workspace; }
    bool prod()      const { return this->_type == EdgeType::prod; }
    bool dev()       const { return this->_type == EdgeType::dev; }

      bool
    optional() const {
      return ( this->_type == EdgeType::optional ) ||
             ( this->_type == EdgeType::peerOptional );
    }

      bool
    peer() const {
      return ( this->_type == EdgeType::peer ) ||
             ( this->_type == EdgeType::peerOptional );
    }


    /* Error Checking */
    bool valid()     { return this->error() == EdgeError::ok; }
    bool missing()   { return this->error() == EdgeError::missing; }
    bool invalid()   { return this->error() == EdgeError::invalid; }
    bool peerLocal() { return this->error() == EdgeError::peer_local; }

      EdgeError
    error() {
      if ( ! this->_error.has_value() )
        {
          this->_error = this->loadError();
        }
      return this->_error.value();
    }


    /* Util */
    bool satisfiedBy( const Node * node ) const;
    void reload( bool hard = false );
    void detach();
    // ??? toJSON() const;


  private:
    EdgeError loadError() const;
    void      setFrom( const Node * node );

};


/* -------------------------------------------------------------------------- */

class Package {

  /* Data */
  ident_t   _name;
  version_t _version;
  dep_map_t _dependencies;
  dep_map_t _devDependencies;
  dep_map_t _peerDependencies;
  dep_map_t _optionalDependencies;
  dep_set_t _bundledDependencies;


  public:
    Package(
      ident_t   name                 = nullptr
    , version_t version              = nullptr
    , dep_map_t dependencies         = {}
    , dep_map_t devDependencies      = {}
    , dep_map_t peerDependencies     = {}
    , dep_map_t optionalDependencies = {}
    , dep_set_t bundledDependencies  = {}
    ) : _name( name )
      , _version( version )
      , _dependencies( dependencies )
      , _devDependencies( devDependencies )
      , _peerDependencies( peerDependencies )
      , _optionalDependencies( optionalDependencies )
      , _bundledDependencies( bundledDependencies )
    {}


    /* Accessors */
    ident_t   name()    const { return this->_name; }
    version_t version() const { return this->_version; }

    dep_map_t dependencies()     const { return this->_dependencies; };
    dep_map_t devDependencies()  const { return this->_devDependencies; };
    dep_map_t peerDependencies() const { return this->_peerDependencies; };

      dep_map_t
    optionalDependencies() const {
      return this->_optionalDependencies;
    };

      dep_set_t
    bundledDependencies() const {
      return this->_bundledDependencies;
    };

};


/* -------------------------------------------------------------------------- */

class Node {

  /* Data */
  const Package * _package;
  const Node    * _parent;


  public:
    const Package * package() const { return this->_package; }
    const Node    * parent()  const { return this->_parent; }

    bool isTop() const { return this->_parent == nullptr; }
};




/* -------------------------------------------------------------------------- */

  };
};


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
