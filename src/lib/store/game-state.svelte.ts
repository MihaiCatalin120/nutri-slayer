import { splitmix32, xmur3a } from "$lib/helpers/seed";
import type { GameState } from "../../models/game-state";

// const seed = 'pop'
// TODO: find out why this line brings out always the same seed on refresh
const seed = crypto.randomUUID().split('-')[0];

export const gameState: GameState = $state({
  nextAttackDamage: 0,
  attackMultiplier: 0,
  turnsUntilAttack: 3,
  hoveredBlock: null,
  stage: 1,
  currentEnemy: null,
  seed: seed,
  rand: splitmix32(xmur3a(seed)()),
});
