/* ========================================================================== *
 *
 * Parse package specs, identifiers, descriptors, etc.
 *
 * -------------------------------------------------------------------------- */

#include <nix/fetchers.hh>
#include <nix/url-parts.hh>
#include <stdexcept>
#include <optional>
#include <iostream>


/* -------------------------------------------------------------------------- */

namespace floco::parse {

/* -------------------------------------------------------------------------- */

  typedef enum { semver, version, url, nullspec } SpecKind;

    static std::string
  specKindToString( const SpecKind & kind )
  {
    switch ( kind )
    {
      case semver:   return "SemVer";  break;
      case version:  return "Version"; break;
      case url:      return "URL";     break;
      case nullspec: return "NULL";    break;
      default:
        throw std::invalid_argument( "Unrecognized SpecKind" );
        break;
    }
  }


/* -------------------------------------------------------------------------- */

  class ParsedSpec {

    private:
      void setKind();
      void initIdent( const std::string & ident );

    public:
      std::optional<std::string> scope;
      std::string                bname;
      std::optional<std::string> locator;
      SpecKind                   kind;

    ParsedSpec( const std::string & raw );
    ParsedSpec( const std::string & ident,
                const std::optional<std::string> & locator
              );
    ParsedSpec( const std::optional<std::string> & scope,
                const std::string                & bname,
                const std::optional<std::string> & locator
              );

    bool isScoped() const { return this->scope.has_value(); }

      std::string
    scopeDir() const
    {
      if ( this->isScoped() )
        {
          return "@" + this->scope.value() + "/";
        }
      else
        {
          return "";
        }
    }

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

    std::string toString() const {
      if ( this->locator.has_value() )
        {
          return this->ident() + "@" + this->locator.value();
        }
      else
        {
          return this->ident();
        }
    }

      void
    show() const
    {
      std::cerr << "{\n  scope:   " + this->scope.value_or( "NULL" ) +
                   ",\n  bname:   " + this->bname +
                   ",\n  locator: " + this->locator.value_or( "NULL" ) +
                   ",\n  kind:    " + specKindToString( this->kind ) + "\n}\n";
    }

  };  /* End `class ParsedSpec' */


/* -------------------------------------------------------------------------- */

};  /* End Namespace `floco::parse' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
