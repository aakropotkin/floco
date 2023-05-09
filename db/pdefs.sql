-- ========================================================================== --
--
--
--
-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS pdefs (
  key      TEXT PRIMARY KEY
, ident    TEXT NOT NULL
, version  TEXT NOT NULL
, ltype    TEXT DEFAULT 'file'

, fetcher    TEXT DEFAULT 'composed'
, fetchInfo  JSON

, lifecycle_build    BOOLEAN
, lifecycle_install  BOOLEAN

, binInfo_binDir    TEXT
, binInfo_binPairs  JSON

, fsInfo_dir         TEXT    DEFAULT '.'
, fsInfo_gypfile     BOOLEAN
, fsInfo_shrinkwrap  BOOLEAN

, sysInfo_cpu  JSON DEFAULT '["*"]'
, sysInfo_os   JSON DEFAULT '["*"]'
);


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS depInfoEnts (
  parent     TEXT                  NOT NULL
, ident      TEXT                  NOT NULL
, descriptor TEXT    DEFAULT '*'   NOT NULL
, runtime    BOOLEAN               NOT NULL
, dev        BOOLEAN DEFAULT TRUE  NOT NULL
, optional   BOOLEAN DEFAULT FALSE NOT NULL
, bundled    BOOLEAN DEFAULT FALSE NOT NULL
, PRIMARY KEY ( parent, ident )
, FOREIGN KEY ( parent ) REFERENCES pdefs ( key )
);

CREATE INDEX IF NOT EXISTS depInfoIndex ON depInfoEnts( parent );


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS peerInfoEnts (
  parent     TEXT                  NOT NULL
, ident      TEXT                  NOT NULL
, descriptor TEXT    DEFAULT '*'   NOT NULL
, optional   BOOLEAN DEFAULT FALSE NOT NULL
, PRIMARY KEY ( parent, ident )
, FOREIGN KEY ( parent ) REFERENCES pdefs ( key )
);

CREATE INDEX IF NOT EXISTS peerInfoIndex ON peerInfoEnts( parent );


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS sysInfoEngineEnts(
  parent TEXT NOT NULL
, id     TEXT NOT NULL
, value  JSON NOT NULL
, PRIMARY KEY ( parent, id )
, FOREIGN KEY ( parent ) REFERENCES pdefs ( key )
);


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_PdefsJSONV (
  key, ident, version, ltype, fetcher, fetchInfo
, lifecycle, binInfo, depInfo, peerInfo, fsInfo, sysInfo
) AS SELECT
  p.key, p.ident, p.version, p.ltype, p.fetcher, json( p.fetchInfo )
  -- lifecycle
, json_object(
    'build',   iif( p.lifecycle_build,   json( 'true' ), json( 'false' ) )
  , 'install', iif( p.lifecycle_install, json( 'true' ), json( 'false' ) ) )
  -- binInfo
, json_object( 'binDir',   p.binInfo_binDir
             , 'binPairs', json( p.binInfo_binPairs ) )
  -- depInfo
, iif( ( COUNT( di.ident ) <= 0 ), json_object()
     , json_group_object(
         di.ident
       , json_object(
           'descriptor', di.descriptor
         , 'runtime',    iif( di.runtime,  json( 'true' ), json( 'false' ) )
         , 'dev',        iif( di.dev,      json( 'true' ), json( 'false' ) )
         , 'optional',   iif( di.optional, json( 'true' ), json( 'false' ) )
         , 'bundled',    iif( di.bundled,  json( 'true' ), json( 'false' ) )
         ) ) )
  -- peerInfo
, iif( ( COUNT( pi.ident ) <= 0 ), json_object()
     , json_group_object(
         pi.ident
       , json_object(
           'descriptor', pi.descriptor
         , 'optional',   iif( pi.optional, json( 'true' ), json( 'false' ) )
         ) ) )
  -- fsInfo
, json_object(
    'dir',        p.fsInfo_dir
  , 'gypfile',    iif( p.fsInfo_gypfile,    json( 'true' ), json( 'false' ) )
  , 'shrinkwrap', iif( p.fsInfo_shrinkwrap, json( 'true' ), json( 'false' ) ) )
  -- sysInfo
, json_object(
    'cpu',     json( p.sysInfo_cpu )
  , 'os',      json( p.sysInfo_os )
  , 'engines', iif( ( COUNT( sie.id ) <= 0 ), json_object()
                  , json_group_object( sie.id, sie.value )
                  ) )
FROM pdefs p
LEFT JOIN depInfoEnts di        ON ( p.key = di.parent )
LEFT JOIN peerInfoEnts pi       ON ( p.key = pi.parent  )
LEFT JOIN sysInfoEngineEnts sie ON ( p.key = sie.parent )
GROUP BY p.key;


-- -------------------------------------------------------------------------- --

-- SQL -> JSON
-- sqlite3 <DB> 'SELECT JSON from v_PdefsJSONF'|jq [-s];
CREATE VIEW IF NOT EXISTS v_PdefsJSONF ( key, JSON ) AS SELECT key, json_object(
  'key',       p.key
, 'ident',     p.ident
, 'version',   p.version
, 'ltype',     p.ltype
, 'fetcher',   p.fetcher
, 'fetchInfo', json( p.fetchInfo )
, 'lifecycle', json( p.lifecycle )
, 'binInfo',   json( p.binInfo )
, 'depInfo',   json( p.depInfo )
, 'peerInfo',  json( p.peerInfo )
, 'fsInfo',    json( p.fsInfo )
, 'sysInfo',   json( p.sysInfo )
) FROM v_PdefsJSONV p ORDER BY p.key;


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_PdefMini(
  key, ltype, lifecycle, binInfo, depInfo, peerInfo
) AS SELECT
  p.key, p.ltype, j.lifecycle
, iif( json_extract( j.binInfo, '$.binPairs' ) = json_object()
     , iif( p.binInfo_binDir = NULL, json_object()
          , json_object( 'binDir', p.binInfo_binDir ) )
     , json_remove( j.binInfo, '$.binDir' ) )
, j.depInfo, j.peerInfo
FROM pdefs p
LEFT JOIN v_PdefsJSONV j ON ( p.key == j.key )
GROUP BY p.key;


-- -------------------------------------------------------------------------- --
--
--
--
-- ========================================================================== --
