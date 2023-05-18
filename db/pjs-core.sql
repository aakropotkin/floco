-- ========================================================================== --
--
--
--
-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS SchemaVersion( version TEXT NOT NULL );
INSERT OR IGNORE INTO SchemaVersion ( version ) VALUES ( '0.1.0' );


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS PjsCores (
  url                  TEXT    NOT NULL
, timestamp            INTEGER NOT NULL
, name                 TEXT    NOT NULL
, version              TEXT    NOT NULL
, dependencies         JSON    DEFAULT '{}'
, devDependencies      JSON    DEFAULT '{}'
, devDependenciesMeta  JSON    DEFAULT '{}'
, peerDependencies     JSON    DEFAULT '{}'
, peerDependenciesMeta JSON    DEFAULT '{}'
, os                   JSON    DEFAULT '["*"]'
, cpu                  JSON    DEFAULT '["*"]'
, engines              JSON    DEFAULT '{}'
, bin                  JSON    DEFAULT NULL
, PRIMARY KEY ( url, timestamp )
);


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_PjsCoresJSON ( key, url, timestamp, json ) AS
  SELECT name || '/' || version, url, timestamp, json_object(
    'name',                 name
  , 'version',              version
  , 'dependencies',         json( dependencies )
  , 'devDependencies',      json( devDependencies )
  , 'devDependenciesMeta',  json( devDependenciesMeta )
  , 'peerDependencies',     json( peerDependencies )
  , 'peerDependenciesMeta', json( peerDependenciesMeta )
  , 'os',                   json( os )
  , 'cpu',                  json( cpu )
  , 'engines',              json( engines )
  , 'bin',                  json( bin )
  ) FROM PjsCores ORDER BY name;


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_PkgVersions ( name, versions ) AS
  SELECT name, json_group_array( version )
  FROM PjsCores GROUP BY name;


-- -------------------------------------------------------------------------- --
--
--
--
-- ========================================================================== --
