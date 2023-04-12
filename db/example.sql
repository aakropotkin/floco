-- ========================================================================== --
--
-- Requires `pdefs.sql'
--
--
-- -------------------------------------------------------------------------- --

INSERT INTO pdefs (
  key
, ident
, version
, ltype
, fetcher
, fetchInfo
, lifecycle_build
, lifecycle_install
) VALUES
  ( 'lodash/4.17.21'  -- key
  , 'lodash'          -- ident
  , '4.17.21'         -- version
  , 'file'            -- ltype
  , 'composed'        -- fetcher
  -- fetchInfo
  , '{"narHash":"sha256-amyN064Yh6psvOfLgcpktd5dRNQStUYHHoIqiI6DMek=","type":"tarball","url":"https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz"}'
  , FALSE  -- lifecycle_build
  , FALSE  -- lifecycle_install
  )
, ( 'pacote/13.3.0'
  , 'pacote'
  , '13.3.0'
  , 'file'
  , 'composed'
  , '{"narHash":"sha256-RN8gBXHMJ9sekHLlVFBYhRf5iziJDFWmAxKw5mlAswA=","type":"tarball","url":"https://registry.npmjs.org/pacote/-/pacote-13.3.0.tgz"}'
  , FALSE
  , FALSE
  )
;


-- -------------------------------------------------------------------------- --

INSERT INTO depInfoEnts ( parent, ident, descriptor, runtime ) VALUES
  ( 'pacote/13.3.0', 'lodash', '^4.17.0', TRUE )
;


-- -------------------------------------------------------------------------- --

SELECT * FROM depInfoEnts;


-- -------------------------------------------------------------------------- --
--
--
--
-- ========================================================================== --
