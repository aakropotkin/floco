/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

const Arborist = require( '@npmcli/arborist' );

/* -------------------------------------------------------------------------- */

let opts = {
  lockfileVersion:   3,
  nodeVersion:       process.version,
  path:              process.env.PWD,
  cache:             `${process.env.HOME}/.npm/_cacache`,
  packumentCache:    new Map(),
  workspacesEnabled: true,
  logLevel:          'silent',
  colors:            false,
  /* Install strategies: 'shallow'|'hoisted'|'nested'
   *   Sets the strategy for installing packages in node_modules.
   *   - hoisted (default): Install non-duplicated in top-level, and duplicated
   *                        as necessary within directory structure.
   *   - nested: (formerly --legacy-bundling) install in place, no hoisting.
   *   - shallow (formerly --global-style) only install direct deps
   *              at top-level.
   *   - linked: (coming soon) install in node_modules/.store, link in place,
   *             unhoisted.
   */
  packageLockOnly: true,
  installStrategy: 'shallow'
};

let skip = false;
process.argv.slice( 2 ).forEach( function( arg, i, array ) {
  if ( skip )
    {
      skip = false;
    }
  else
    {
      switch( arg )
        {
          case '--install-strategy=hoisted':
            opts['installStrategy'] = 'hoisted';
            break;
          case '--install-strategy=nested':
            opts['installStrategy'] = 'nested';
            break;
          case '--install-strategy=shallow':
            opts['installStrategy'] = 'shallow';
            break;
          case '--install-strategy':
            opts['installStrategy'] = args[i + 1];
            skip = true;
            break;
          default:
            opts['path'] = arg;
        }
    }
} );


/* -------------------------------------------------------------------------- */

( new Arborist( opts ) ).buildIdealTree( opts ).then( ( result ) => {
  console.log( result.meta.toString() );
} );


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
