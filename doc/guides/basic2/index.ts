// index.ts
import {
  VERSION, flatten, isEqual, last, omit, pick, pickBy, uniq
} from 'lodash';

const f : Array<number> = flatten( [[1, 2], [3, 4]] );
console.log( f );
const l : number = last( [1, 2, 3, 4] )
console.log( l );
const u : Array<number> = uniq( [1, 2, 3, 1, 2, 3, 2] );
console.log( u );
console.log( VERSION );
