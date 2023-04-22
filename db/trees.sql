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

CREATE VIEW IF NOT EXISTS v_TreeEntJSONV ( path, JSON ) AS
SELECT path, json_object(
  'key',      e.key
, 'dev',      iif( e.dev,      json( 'true' ), json( 'false' ) )
, 'optional', iif( e.optional, json( 'true' ), json( 'false' ) )
, 'link',     iif( e.link,     json( 'true' ), json( 'false' ) )
) FROM treeInfoEnts e ORDER BY e.path;


-- -------------------------------------------------------------------------- --

INSERT OR REPLACE INTO treeInfo( parent ) VALUES ( 'pacote/13.3.0' );

INSERT OR REPLACE INTO treeInfoEnts( treeId, path, key ) VALUES
( ( SELECT treeId FROM treeInfo LIMIT 1 ), '', 'lodash/4.17.21' );


-- -------------------------------------------------------------------------- --
--
--
--
-- ========================================================================== --
