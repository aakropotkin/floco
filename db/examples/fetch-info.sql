-- ========================================================================== --
--
-- NOTE: For relative paths to work PWD must be the `examples/' directory.
--
-- -------------------------------------------------------------------------- --

.read ../fetch-info.sql

-- -------------------------------------------------------------------------- --

INSERT OR REPLACE INTO Tarballs (
  url, timestamp, safePerms, narHash
) VALUES (
  'https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz'
, unixepoch()
, TRUE
, 'sha256-amyN064Yh6psvOfLgcpktd5dRNQStUYHHoIqiI6DMek='
);


-- -------------------------------------------------------------------------- --

INSERT OR REPLACE INTO Files ( url, timestamp, narHash ) VALUES (
  'https://registry.npmjs.org/lodash'
, unixepoch()
, 'sha256-jjvl1QMuGrmdocN37IroTxG0GbT+baazaS+kA3ghMgM='
), (
  'https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz'
, unixepoch()
, 'sha256-fn2qMkL7ePPYQyW/x9nvDOl05BDrC7VsfvyfW0xkQyE='
);


-- -------------------------------------------------------------------------- --
--
--
--
-- ========================================================================== --
