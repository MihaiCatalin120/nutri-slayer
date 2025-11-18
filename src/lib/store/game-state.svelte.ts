import type { GameState } from "../../models/game-state";

export const gameState: GameState = $state({
  maxHP: 100,
  currentHP: 100,
  nextAttackDamage: 0,
  attackMultiplier: 1,
  turnsUntilAttack: 3,
  stage: 1,
  hoveredBlock: null,
  currentEnemy: null,
});
