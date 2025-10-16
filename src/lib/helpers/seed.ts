// https://github.com/bryc/code/blob/master/jshash/PRNGs.md
//
// seedgen
export function xmur3a(str: string) {
  let h: number = 0;
  for (let k, i = 0, h = 2166136261 >>> 0; i < str.length; i++) {
    k = Math.imul(str.charCodeAt(i), 3432918353); k = k << 15 | k >>> 17;
    h ^= Math.imul(k, 461845907); h = h << 13 | h >>> 19;
    h = Math.imul(h, 5) + 3864292196 | 0;
  }
  h ^= str.length;
  return function () {
    h ^= h >>> 16; h = Math.imul(h, 2246822507);
    h ^= h >>> 13; h = Math.imul(h, 3266489909);
    h ^= h >>> 16;
    return h >>> 0;
  }
}

export function splitmix32(a: number) {
  return function () {
    a |= 0; a = a + 0x9e3779b9 | 0;
    let t = a ^ a >>> 16; t = Math.imul(t, 0x21f0aaad);
    t = t ^ t >>> 15; t = Math.imul(t, 0x735a2d97);
    return ((t = t ^ t >>> 15) >>> 0) / 4294967296;
  }
}
