import type { GameBlock } from "./block";
import type { CurrentEnemy } from "./enemy";

export type GameState = {
  nextAttackDamage: number,
  attackMultiplier: number,
  hoveredBlock: GameBlock | null,
  currentEnemy: CurrentEnemy | null,
  stage: number,
  seed: string,
  rand: () => number,
}
