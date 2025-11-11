import { type Enemy } from '../../models/enemy';

const frygon = {
  id: 1,
  name: 'Frygon',
  baseHp: 300,
  baseDamage: 5,
  turnsPerAttack: 3,
  imageUrl: '/images/fry-gon.png',
  // minStage: 3,
};

const c_andy = {
  id: 1,
  name: 'C-Andy',
  baseHp: 100,
  baseDamage: 2,
  turnsPerAttack: 3,
  imageUrl: '/images/c_andy.png',
  maxStage: 3,
};

export const all: Array<Enemy> = [frygon, c_andy];
