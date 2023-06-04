-- ========================================================================== --
--
--
--
-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS SchemaVersion( version TEXT NOT NULL );
INSERT OR IGNORE INTO SchemaVersion ( version ) VALUES ( '1.0.0' );


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS PjsCore (
  name                 TEXT    NOT NULL
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
, PRIMARY KEY ( name, version )
);


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_PjsCoreJSON ( _id, json ) AS
  SELECT ( name || '@' || version ), json_object(
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
  ) FROM PjsCore ORDER BY name;


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_PkgVersions ( name, versions ) AS
  SELECT name, json_group_array( version )
  FROM PjsCore GROUP BY name;


-- -------------------------------------------------------------------------- --
--
--
--
-- ========================================================================== --
