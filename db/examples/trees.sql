-- ========================================================================== --
--
-- NOTE: For relative paths to work PWD must be the `examples/' directory.
--
-- -------------------------------------------------------------------------- --

.read ../trees.sql

-- -------------------------------------------------------------------------- --

INSERT OR REPLACE INTO treeInfo( parent ) VALUES ( 'pacote/13.3.0' );

INSERT OR REPLACE INTO treeInfoEnts( treeId, path, key ) VALUES
  ( ( SELECT treeId FROM treeInfo LIMIT 1 ), '', 'pacote/13.3.0' )
, ( ( SELECT treeId FROM treeInfo LIMIT 1 )
  , 'node_modules/lodash', 'lodash/4.17.21' )
;


-- -------------------------------------------------------------------------- --
--
--
--
-- ========================================================================== --
