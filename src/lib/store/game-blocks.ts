import { type GameBlock } from '../../models/block';

const blockStyle = ' border cursor-pointer hover:scale-[1.1]';

const protein = {
  name: 'Protein',
  style: 'bg-red-500' + blockStyle,
  baseDamage: 2,
  damageMultiplier: 1.1,
  description: 'Building block of the organism',
  id: 1
};

const saturatedFat = {
  name: 'Saturated fat',
  style: 'bg-yellow-500' + blockStyle,
  baseDamage: 0,
  damageMultiplier: 0,
  description:
    'Unhealthy fat, solid at room temperature, responsible for building up bad cholesterol',
  id: 2
};

const carbohydrate = {
  name: 'Complex carbohydrate',
  style: 'bg-yellow-900' + blockStyle,
  baseDamage: 1,
  damageMultiplier: 1,
  description: 'Main source of body energy, less likely to spike blood sugar',
  id: 3
};

const unsaturatedFat = {
  name: 'Unsaturated fat',
  style: 'bg-green-600' + blockStyle,
  baseDamage: 2,
  damageMultiplier: 1.2,
  description:
    'Healthy fat, liquid at room temperatures, can ease inflammations and aid heart rhythm',
  id: 4
};

export const air = {
  name: 'Air',
  style: 'bg-white',
  baseDamage: 0,
  damageMultiplier: 0,
  description: 'Nothing here',
  id: 0
};

export const all: Array<GameBlock> = [protein, saturatedFat, unsaturatedFat, carbohydrate, air];
