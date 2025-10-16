export type Enemy = {
  id: number,
  name: string,
  baseHP: number,
  baseDamage: number,
  turnsPerAttack: number,
  imageUrl: string,
  saturatedFatMultiplier?: number,
  sugarMultiplier?: number,
  minStage?: number,
  maxStage?: number,
}

export interface CurrentEnemy extends Enemy {
  initialHP: number,
  currentDamage: number,
  currentHP: number,
  turnsUntilAttack: number,
}
