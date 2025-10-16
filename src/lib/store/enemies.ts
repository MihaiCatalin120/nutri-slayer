import type { Enemy } from "../../models/enemy";

const FryGon: Enemy = {
  id: 1,
  name: 'Fry-Gon',
  baseHP: 80,
  baseDamage: 5,
  turnsPerAttack: 4,
  imageUrl: '/images/fry-gon.png',
  saturatedFatMultiplier: 1.1,
}

const BurgerPrince: Enemy = {
  id: 2,
  name: 'Burger Prince',
  baseHP: 50,
  baseDamage: 3,
  turnsPerAttack: 2,
  imageUrl: '/images/burger-prince.png',
  saturatedFatMultiplier: 1.2,
}

const Candy: Enemy = {
  id: 3,
  name: 'Candy', // maybe find a better one
  baseHP: 20,
  baseDamage: 1,
  turnsPerAttack: 3,
  imageUrl: '/images/candy.png',
  sugarMultiplier: 1.3,
  maxStage: 3,
}

const HotDogCannon: Enemy = {
  id: 4,
  name: 'HDG-5000 KM',
  baseHP: 120,
  baseDamage: 5,
  turnsPerAttack: 5,
  imageUrl: '/images/hot-dog-cannon.png',
  minStage: 5,
}

const PepperoniGang: Enemy = {
  id: 5,
  name: 'Pep Gang',
  baseHP: 60,
  baseDamage: 2,
  turnsPerAttack: 1,
  imageUrl: '/images/hot-dog-cannon.png',
  saturatedFatMultiplier: 1.1,
}

export const enemies: Enemy[] =
  [
    FryGon,
    BurgerPrince,
    Candy,
    HotDogCannon,
    PepperoniGang,
  ];
