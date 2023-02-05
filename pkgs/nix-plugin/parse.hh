/* ========================================================================== *
 *
 * Parse package specs, identifiers, descriptors, etc.
 *
 * -------------------------------------------------------------------------- */

#include <nix/fetchers.hh>
#include <nix/url-parts.hh>
#include <optional>
#include <iostream>


/* -------------------------------------------------------------------------- */

namespace floco::parse {

/* -------------------------------------------------------------------------- */

  typedef enum { semver, version, url } SpecKind;

  struct ParsedSpec {

    std::optional<std::string> scope;
    std::string                bname;
    std::string                locator;
    SpecKind                   kind;

    ParsedSpec( const std::string & raw );
    ParsedSpec( const std::string & ident, const std::string & locator );
    ParsedSpec( const std::optional<std::string> & scope,
                const std::string                & bname,
                const std::string                & locator
              );

    bool isScoped() const { return this->scope.has_value(); }

      std::string
    ident() const
    {
      if ( this->isScoped() )
        {
          return "@" + this->scope.value() + "/" + this->bname;
        }
      else
        {
          return this->bname;
        }
    }

    std::string toString() const { return this->ident() + "@" + this->locator; }

      void
    show() const
    {
      const std::string k(
        this->kind == SpecKind::version ? "Version" :
        this->kind == SpecKind::semver  ? "SemVer"  : "URL"
      );
      std::cerr << "{\n  scope:   " + this->scope.value_or( "NULL" ) +
                   ",\n  bname:   " + this->bname +
                   ",\n  locator: " + this->locator +
                   ",\n  kind:    " + k + "\n}\n";
    }

  };  /* End `struct ParsedSpec' */


/* -------------------------------------------------------------------------- */

};  /* End Namespace `floco::parse' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
