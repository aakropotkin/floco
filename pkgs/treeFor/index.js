const Arborist = require( '@npmcli/arborist' );
let opts = {
  lockfileVersion: 3,
  nodeVersion: process.version,
  path: process.argv[2],
  cache: `${process.env.HOME}/.npm/_cacache`,
  packumentCache: new Map(),
  workspacesEnabled: true,
  logLevel: 'silent',
  colors: false,
  // Install strategies: 'shallow'|'hoisted'|'nested'
  //   Sets the strategy for installing packages in node_modules.
  //   - hoisted (default): Install non-duplicated in top-level, and duplicated
  //                        as necessary within directory structure.
  //   - nested: (formerly --legacy-bundling) install in place, no hoisting.
  //   - shallow (formerly --global-style) only install direct deps
  //              at top-level.
  //   - linked: (coming soon) install in node_modules/.store, link in place,
  //             unhoisted.
  installStrategy: 'nested',
};
( new Arborist( opts ) ).buildIdealTree( opts ).then( (result) => {
  console.log( result.meta.toString() );
} );
