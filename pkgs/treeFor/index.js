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
  // 'shallow'|'hoisted'
  installStrategy: 'shallow'
};
( new Arborist( opts ) ).buildIdealTree( opts ).then( (result) => {
  console.log( result.meta.toString() );
} );
