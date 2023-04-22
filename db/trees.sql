-- ========================================================================== --
--
--
--
-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS treeInfo(
  treeId   INTEGER PRIMARY KEY
, parent   TEXT                    NOT NULL  -- key
, dev      BOOLEAN DEFAULT TRUE    NOT NULL
, optional BOOLEAN DEFAULT FALSE   NOT NULL
, os       JSON    DEFAULT '["*"]' NOT NULL
, cpu      JSON    DEFAULT '["*"]' NOT NULL
, engines  JSON    DEFAULT '{}'    NOT NULL
);


-- -------------------------------------------------------------------------- --


CREATE TABLE IF NOT EXISTS treeInfoEnts (
  treeId    INTEGER               NOT NULL
, path      TEXT                  NOT NULL
, key       TEXT                  NOT NULL
, dev       BOOLEAN DEFAULT TRUE  NOT NULL
, optional  BOOLEAN DEFAULT FALSE NOT NULL
, link      BOOLEAN DEFAULT FALSE NOT NULL
, PRIMARY KEY ( treeId, path )
, FOREIGN KEY ( treeId ) REFERENCES treeInfo ( treeId )
);


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_TreeEntJSONF ( path, JSON ) AS
SELECT path, json_object(
  'key',      e.key
, 'dev',      iif( e.dev,      json( 'true' ), json( 'false' ) )
, 'optional', iif( e.optional, json( 'true' ), json( 'false' ) )
, 'link',     iif( e.link,     json( 'true' ), json( 'false' ) )
) FROM treeInfoEnts e ORDER BY e.path;


-- -------------------------------------------------------------------------- --

INSERT OR REPLACE INTO treeInfo( parent ) VALUES ( 'pacote/13.3.0' );

INSERT OR REPLACE INTO treeInfoEnts( treeId, path, key ) VALUES
  ( ( SELECT treeId FROM treeInfo LIMIT 1 ), '', 'pacote/13.3.0' )
, ( ( SELECT treeId FROM treeInfo LIMIT 1 )
  , 'node_modules/lodash', 'lodash/4.17.21' )
;


-- -------------------------------------------------------------------------- --

-- SQL -> JSON
-- -----------
-- Just the tree:
--   $ sqlite3 <DB> 'SELECT JSON from v_TreeInfoJSONV'|jq [-s];
--
-- With Info:
--   $ sqlite3 ./ti.db "SELECT json_object( 'id', treeId, 'info', json( info )
--                                        , 'tree', json( JSON ) )
--                      FROM v_TreeInfoJSONV"|jq [-s];
CREATE VIEW IF NOT EXISTS v_TreeInfoJSONV( treeId, info, JSON ) AS SELECT
  t.treeId
, json_object(
    'parent',   t.parent
  , 'dev',      iif( t.dev,      json( 'true' ), json( 'false' ) )
  , 'optional', iif( t.optional, json( 'true' ), json( 'false' ) )
  , 'os',       json( t.os )
  , 'cpu',      json( t.cpu )
  , 'engines',  json( t.engines )
  )
, json_group_object( e.path, (
  SELECT json( JSON ) FROM v_TreeEntJSONF ej
  WHERE e.path = ej.path
  ORDER BY ej.path
) ) FROM treeInfo t
    LEFT JOIN treeInfoEnts e
    ON t.treeId = e.treeId
    GROUP BY t.treeId;


-- -------------------------------------------------------------------------- --
--
--
--
-- ========================================================================== --
