import type { GameBlock } from "./block";
import type { CurrentEnemy } from "./enemy"

export type GameState = {
  maxHP: number,
  currentHP: number,
  nextAttackDamage: number,
  attackMultiplier: number,
  hoveredBlock: GameBlock | null,
  currentEnemy: CurrentEnemy | null,
  seed: string,
  rand: () => number,
}
