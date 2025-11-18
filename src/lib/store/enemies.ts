import { type Enemy } from '../../models/enemy';

const frygon = {
  id: 1,
  name: 'Frygon',
  baseHP: 300,
  baseDamage: 5,
  turnsPerAttack: 3,
  imageUrl: '/images/fry-gon.png',
  minStage: 3,
};

const c_andy = {
  id: 1,
  name: 'C-Andy',
  baseHP: 100,
  baseDamage: 2,
  turnsPerAttack: 3,
  imageUrl: '/images/c_andy.png',
  maxStage: 3,
};

const chocwall = {
  id: 1,
  name: 'Chocwall',
  baseHP: 500,
  baseDamage: 1,
  turnsPerAttack: 10,
  imageUrl: '/images/chocwall.png',
  minStage: 2,
};

const chipgang = {
  id: 1,
  name: 'Chip gang',
  baseHP: 80,
  baseDamage: 3,
  turnsPerAttack: 1,
  imageUrl: '/images/chip-gang.png',
  minStage: 2,
};

const turbofizz = {
  id: 1,
  name: 'Turbo Fizz',
  baseHP: 200,
  baseDamage: 5,
  turnsPerAttack: 5,
  imageUrl: '/images/turbo-fizz.png',
  minStage: 1,
};

const gingee = {
  id: 1,
  name: 'Gingee',
  baseHP: 100,
  baseDamage: 3,
  turnsPerAttack: 2,
  imageUrl: '/images/gingee.png',
  minStage: 1,
  maxStage: 5,
};

const bomblines = {
  id: 1,
  name: 'Bomblines',
  baseHP: 50,
  baseDamage: 10,
  turnsPerAttack: 10,
  imageUrl: '/images/bomblines.png',
  minStage: 1,
};

const hotdogannon = {
  id: 1,
  name: 'Hot Dogannon',
  baseHP: 300,
  baseDamage: 6,
  turnsPerAttack: 5,
  imageUrl: '/images/hot-dogannon.png',
  minStage: 3,
};

export const enemies: Array<Enemy> =
  [
    frygon,
    c_andy,
    chocwall,
    chipgang,
    turbofizz,
    gingee,
    bomblines,
    hotdogannon,
  ];
