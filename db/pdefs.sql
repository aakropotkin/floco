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

, depInfo   JSON
, peerInfo  JSON
, treeInfo  JSON

, fsInfo_dir         TEXT    DEFAULT '.'
, fsInfo_gypfile     BOOLEAN
, fsInfo_shrinkwrap  BOOLEAN

, sysInfo_cpu      JSON DEFAULT '["*"]'
, sysInfo_os       JSON DEFAULT '["*"]'
, sysInfo_engines  JSON DEFAULT '{"node":"*"}'
);


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS depInfoEnts (
  id         INTEGER PRIMARY KEY
, parent     TEXT                  NOT NULL
, ident      TEXT                  NOT NULL
, descriptor TEXT    DEFAULT '*'   NOT NULL
, runtime    BOOLEAN               NOT NULL
, dev        BOOLEAN DEFAULT TRUE  NOT NULL
, optional   BOOLEAN DEFAULT FALSE NOT NULL
, bundled    BOOLEAN DEFAULT FALSE NOT NULL
);



-- -------------------------------------------------------------------------- --




-- -------------------------------------------------------------------------- --
--
--
--
-- ========================================================================== --
