-- ========================================================================== --
--
--
--
-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS SchemaVersion( version TEXT NOT NULL );
INSERT OR IGNORE INTO SchemaVersion ( version ) VALUES ( '0.1.0' );


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS Tarballs(
  url        TEXT    PRIMARY KEY
, timestamp  INTEGER NOT NULL
, safePerms  BOOLEAN
, narHash    TEXT
);


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_TarballsJSON ( url, JSON ) AS
  SELECT url, json_object(
    'url',       t.url
  , 'timestamp', t.timestamp
  , 'safePerms', iif( t.safePersm, json( 'true' ), json( 'false' ) )
  , 'narHash',   t.narHash
  ) FROM Tarballs t;


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_TarballsFetchInfoJSON ( url, fetchInfo ) AS
SELECT url, json_object( 'type', 'tarball', 'url', t.url, 'narHash', t.narHash )
FROM Tarballs t;


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS Files(
  url        TEXT    PRIMARY KEY
, timestamp  INTEGER NOT NULL
, narHash    TEXT
);


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_FilesJSON ( url, JSON ) AS
  SELECT url, json_object(
    'url',       f.url
  , 'timestamp', f.timestamp
  , 'narHash',   f.narHash
  ) FROM Files f;


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_FilesFetchInfoJSON ( url, fetchInfo ) AS
SELECT url, json_object( 'type', 'file', 'url', f.url, 'narHash', f.narHash )
FROM Files f;


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_TarballFull (
  url, timestamp, safePerms, tarballNarHash, fileNarHash
) AS SELECT t.url, t.timestamp, t.safePerms, t.narHash, f.narHash
FROM Tarballs t LEFT JOIN Files f ON
( t.url = f.url ) AND ( t.timestamp = f.timestamp )
GROUP BY t.url;


-- -------------------------------------------------------------------------- --
--
--
--
-- ========================================================================== --
