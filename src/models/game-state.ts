import type { GameBlock } from "./block";

export type GameState = {
  nextAttackDamage: number,
  attackMultiplier: number,
  hoveredBlock: GameBlock | null,
}
