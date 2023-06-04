-- ========================================================================== --
--
--
--
-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS SchemaVersion( version TEXT NOT NULL );
INSERT OR IGNORE INTO SchemaVersion ( version ) VALUES ( '0.1.0' );


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS Tarball(
  url        TEXT    PRIMARY KEY
, timestamp  INTEGER NOT NULL
, safePerms  BOOLEAN
, narHash    TEXT
);


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_TarballJSON ( url, JSON ) AS
  SELECT url, json_object(
    'url',       t.url
  , 'timestamp', t.timestamp
  , 'safePerms', iif( t.safePersm, json( 'true' ), json( 'false' ) )
  , 'narHash',   t.narHash
  ) FROM Tarball t;


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_TarballFetchInfoJSON ( url, fetchInfo ) AS
SELECT url, json_object( 'type', 'tarball', 'url', t.url, 'narHash', t.narHash )
FROM Tarball t;


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS File(
  url        TEXT    PRIMARY KEY
, timestamp  INTEGER NOT NULL
, narHash    TEXT
);


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_FileJSON ( url, JSON ) AS
  SELECT url, json_object(
    'url',       f.url
  , 'timestamp', f.timestamp
  , 'narHash',   f.narHash
  ) FROM File f;


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_FileFetchInfoJSON ( url, fetchInfo ) AS
SELECT url, json_object( 'type', 'file', 'url', f.url, 'narHash', f.narHash )
FROM File f;


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_TarballFull (
  url, timestamp, safePerms, tarballNarHash, fileNarHash
) AS SELECT t.url, t.timestamp, t.safePerms, t.narHash, f.narHash
FROM Tarball t LEFT JOIN File f ON
( t.url = f.url ) AND ( t.timestamp = f.timestamp )
GROUP BY t.url;


-- -------------------------------------------------------------------------- --
--
--
--
-- ========================================================================== --
