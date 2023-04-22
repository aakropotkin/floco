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

, sysInfo_cpu      JSON DEFAULT '["*"]'
, sysInfo_os       JSON DEFAULT '["*"]'
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

CREATE INDEX depInfoIndex ON depInfoEnts( parent );


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS peerInfoEnts (
  parent     TEXT                  NOT NULL
, ident      TEXT                  NOT NULL
, descriptor TEXT    DEFAULT '*'   NOT NULL
, optional   BOOLEAN DEFAULT FALSE NOT NULL
, PRIMARY KEY ( parent, ident )
, FOREIGN KEY ( parent ) REFERENCES pdefs ( key )
);

CREATE INDEX peerInfoIndex ON peerInfoEnts( parent );


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS treeInfoEnts (
  treeId    INTEGER               NOT NULL
, path      TEXT                  NOT NULL
, key       TEXT                  NOT NULL
, link      BOOLEAN DEFAULT FALSE NOT NULL
, dev       BOOLEAN DEFAULT TRUE  NOT NULL
, optional  BOOLEAN DEFAULT FALSE NOT NULL
, PRIMARY KEY ( treeId, path )
);


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS sysInfoEngineEnts(
  parent TEXT NOT NULL
, id     TEXT NOT NULL
, value  JSON NOT NULL
, PRIMARY KEY ( parent, id )
, FOREIGN KEY ( parent ) REFERENCES pdefs ( key )
);


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_Pdefs (
  key, ident, version, ltype, fetcher, fetchInfo
, lifecycle_build, lifecycle_install
, binInfo_binDir, binInfo_binPairs
, depInfo, peerInfo, treeInfo
, fsInfo_dir, fsInfo_gypfile, fsInfo_shrinkwrap
, sysInfo_cpu, sysInfo_os, sysInfo_engines
) AS SELECT
  p.key, p.ident, p.version, p.ltype, p.fetcher, p.fetchInfo
, p.lifecycle_build, p.lifecycle_install, p.binInfo_binDir, p.binInfo_binPairs
  -- depInfo
, iif( ( COUNT( di.ident ) <= 0 ), '{}'
     , json_group_object( di.ident, json_object(
                                      'descriptor', di.descriptor
                                    , 'runtime',    di.runtime
                                    , 'dev',        di.dev
                                    , 'optional',   di.optional
                                    , 'bundled',    di.bundled
                                    ) ) )
  -- peerInfo
, iif( ( COUNT( pi.ident ) <= 0 ), '{}'
     , json_group_object( pi.ident, json_object(
                                      'descriptor', pi.descriptor
                                    , 'optional',   pi.optional
                                    ) ) )
  -- TODO: treeInfo
, '{}'
, p.fsInfo_dir, p.fsInfo_gypfile, p.fsInfo_shrinkwrap
, p.sysInfo_cpu, p.sysInfo_os
  -- sysInfo_engines
, json_group_object( sie.id, sie.value )
FROM pdefs p
LEFT JOIN depInfoEnts di        ON ( p.key = di.parent )
LEFT JOIN peerInfoEnts pi       ON ( p.key = pi.parent  )
LEFT JOIN sysInfoEngineEnts sie ON ( p.key = sie.parent )
GROUP BY p.key;



-- -------------------------------------------------------------------------- --
--
--
--
-- ========================================================================== --
