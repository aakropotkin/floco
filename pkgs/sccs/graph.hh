/* ========================================================================== *
 *
 * Parse package specs, identifiers, descriptors, etc.
 *
 * -------------------------------------------------------------------------- */

#include <optional>
#include <list>
#include <string>
#include <unordered_map>

/* -------------------------------------------------------------------------- */

namespace floco::graph {

/* -------------------------------------------------------------------------- */

class Node;


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
  std::string   _name;
  std::string   _spec;
  std::string   _accept;
  Node        * _from;
  Node        * _to;
  bool          _peerConflicted;
  bool          _overridden;

  std::optional<EdgeError> _error;

  std::unordered_map<std::string, std::string> _overrides;


  public:
    /* Accessors */
    std::string   spec()    const;
    EdgeType      type()    const { return this->_type; }
    std::string   name()    const { return this->_name; }
    std::string   rawSpec() const { return this->_spec; }
    std::string   accept()  const { return this->_accept; }
    Node        * from()    const { return this->_from; }
    Node        * to()      const { return this->_to; }


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
    bool satisfiedBy( Node & node ) const;
    void reload( bool hard = false );
    void detach();
    // ??? toJSON() const;


  private:
    EdgeError loadError() const;
    void      setFrom( Node * n );

};


/* -------------------------------------------------------------------------- */

};


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
