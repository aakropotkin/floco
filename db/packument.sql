-- ========================================================================== --
--
--
--
-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS SchemaVersion( version TEXT NOT NULL );
INSERT OR IGNORE INTO SchemaVersion ( version ) VALUES ( '1.0.0' );


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS Packument (
  _id        TEXT  NOT NULL              -- `<name>'
, _rev       TEXT  NOT NULL DEFAULT '0'
, name       TEXT  NOT NULL
, time       JSON  DEFAULT '{}'
, distTags   JSON  DEFAULT '{}'
, PRIMARY KEY ( _id, _rev )
);


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS VInfo (
  _id             TEXT NOT NULL  PRIMARY KEY  -- `<name>@<version>'
, homepage        TEXT
, description     TEXT
, license         TEXT
, repository      JSON
, dist            JSON
, _hasShrinkwrap  BOOLEAN DEFAULT false
);


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS PackumentVInfo (
  _id       TEXT     NOT NULL  PRIMARY KEY  -- `<name>@<version>'
, time      INTEGER  NOT NULL
, distTags  JSON     DEFAULT '[]'
);


-- -------------------------------------------------------------------------- --

-- NOTE: `json_patch' omits `{ "foo": null }' fields in its second argument.
--       With this in mind we must make any nullable fields part of the first
--       argument instead.
--       We can "get away with" only declaring nullable fields from `VInfo' here
--       only because `null' is not a valid value for any `PjsCore' fields.
CREATE VIEW IF NOT EXISTS v_VInfoJSON ( _id, json ) AS
  SELECT v._id, json_patch( json_object(
    'homepage',       iif( v.homepage    = NULL, json( 'null' ), v.homepage )
  , 'description',    iif( v.description = NULL, json( 'null' ), v.description )
  , 'license',        iif( v.license     = NULL, json( 'null' ), v.license )
  , 'repository',     json( iif( v.repository  = NULL, 'null', v.repository ) )
  , 'dist',           json( iif( v.dist        = NULL, 'null', v.dist ) )
  , '_hasShrinkWrap', iif( v._hasShrinkwrap, json( 'true' ), json( 'false' ) )
  ), json( p.json ) )
  FROM VInfo v LEFT JOIN v_PjsCoreJSON p ON ( v._id = p._id );


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_PackumentJSON ( _id, json ) AS
  SELECT p._id, json_object(
    '_id',        p._id
  , '_rev',       p._rev
  , 'name',       iif( p.name = NULL, p._id, p.name )
  , 'time',       json( p.time )
  , 'dist-tags',  json( p.distTags )
  , 'versions',   json_group_object( json_extract( vi.json, '$.version' )
                                   , json( vi.json ) )
  )
  FROM Packument p
  LEFT JOIN v_VInfoJSON vi ON ( p._id = json_extract( vi.json, '$.name' ) )
  GROUP BY p._id;


-- -------------------------------------------------------------------------- --
--
--
--
-- ========================================================================== --
