import type { GameState } from "../../models/game-state";

export const gameState: GameState = $state({
  nextAttackDamage: 0,
  attackMultiplier: 0,
  turnsUntilAttack: 3,
  hoveredBlock: null,
});
