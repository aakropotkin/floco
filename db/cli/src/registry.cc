/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include <cstdio>
#include <filesystem>
#include "floco-registry.hh"
#include "registry-db.hh"
#include "floco-sql.hh"


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace registry {

/* -------------------------------------------------------------------------- */

PkgRegistry defaultRegistry = PkgRegistry();


/* -------------------------------------------------------------------------- */

  std::string
PkgRegistry::getPackumentURL( floco::ident_view ident ) const
{
  std::string s( this->protocol + "://" + this->host + "/" );
  s += ident;
  return s;
}


/* -------------------------------------------------------------------------- */

  std::string
PkgRegistry::getVInfoURL( floco::ident_view   ident
                        , floco::version_view version
                        ) const
{
  std::string s( this->protocol + "://" + this->host + "/" );
  s += ident;
  s += "/";
  s += version;
  return s;
}


/* -------------------------------------------------------------------------- */

  bool
RegistryDb::exists() const
{
  return ( this->_db != nullptr ) || std::filesystem::exists( this->_dbPath );
}


/* -------------------------------------------------------------------------- */

  bool
RegistryDb::create( bool recreate )
{
  bool exists = this->exists();
  if ( exists )
    {
      if ( ! recreate )
        {
          this->_db = std::make_unique<sqlite3pp::database>(
            this->_dbPath.c_str()
          );
          return false;
        }
      if ( this->_db != nullptr ) { this->_db.reset(); }
      std::remove( this->_dbPath.c_str() );
    }
  if ( std::filesystem::path pdir =
         std::filesystem::path( this->_dbPath ).parent_path();
       ! std::filesystem::exists( pdir )
     )
    {
      std::filesystem::create_directories( pdir );
    }
  this->_db = std::make_unique<sqlite3pp::database>( this->_dbPath.c_str() );
  this->_db->execute( pjsCoreSchemaSQL );
  this->_db->execute( packumentsSchemaSQL );
  return true;
}


/* -------------------------------------------------------------------------- */

  std::reference_wrapper<sqlite3pp::database>
RegistryDb::getDb( bool create )
{
  if ( ( ! create ) && ( ! this->exists() ) )
    {
      std::string msg = "no such database: " + this->_dbPath;
      throw sqlite3pp::database_error( msg.c_str() );
    }
  if ( this->_db == nullptr ) { this->create( false ); }
  assert( this->_db != nullptr );
  return std::ref( * this->_db );
}


/* -------------------------------------------------------------------------- */

 db::Packument
RegistryDb::get( floco::ident_view ident )
{
  if ( db::db_stale( this->getDb( true ), ident ) )
    {
      db::Packument p( (std::string_view) this->getPackumentURL( ident ) );
      p.sqlite3Write( this->getDb( true ) );
      return p;
    }
  else
    {
      return db::Packument( this->getDb( true ), ident );
    }
}


/* -------------------------------------------------------------------------- */

 db::PackumentVInfo
RegistryDb::get( floco::ident_view ident, floco::version_view version )
{
  if ( db::db_has( this->getDb( true ), ident ) )
    {
      db::Packument p( this->getDb( true  ), ident );
      if ( auto search = p.versions.find( floco::version( version ) );
           search != p.versions.end()
         )
        {
          return search->second;
        }
    }
  db::Packument p( (std::string_view) this->getPackumentURL( ident ) );
  p.sqlite3Write( this->getDb( true ) );
  return p.versions.at( (std::string) version );
}


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::registry' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
