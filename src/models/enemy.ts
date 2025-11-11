export type CurrentEnemy = {
  name: string,
  baseHP: number,
  baseDamage: number,
  turnsPerAttack: number,
  imageUrl: string,
  minStage?: number,
  maxStage?: number,

  totalHP: number,
  currentHP: number,
  totalDamage: number,
  turnsUntilAttack: number,
}

export type Enemy = Omit<CurrentEnemy, "totalHP" | "currentHP" | "totalDamage" | "turnsUntilAttack">

