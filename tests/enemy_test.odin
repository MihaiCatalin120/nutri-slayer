package tests

import "core:testing"
import game "../src"

@(test)
test_enemy_database_not_empty :: proc(t: ^testing.T) {
	testing.expect(t, len(game.ENEMY_DATABASE) > 0, "enemy database should have entries")
}

@(test)
test_enemy_database_valid_stats :: proc(t: ^testing.T) {
	for enemy in game.ENEMY_DATABASE {
		testing.expect(t, enemy.hp > 0, "enemy hp should be positive")
		testing.expect(t, enemy.max_hp == enemy.hp, "database enemies should start at max hp")
		testing.expect(t, enemy.damage > 0, "enemy damage should be positive")
		testing.expect(t, enemy.turns_per_attack > 0, "enemy should attack on a timer")
		testing.expect(t, enemy.turns_until_attack == enemy.turns_per_attack, "attack timer should be primed")
	}
}

@(test)
test_stage_one_has_valid_enemies :: proc(t: ^testing.T) {
	count := 0
	for enemy in game.ENEMY_DATABASE {
		if game.enemy_valid_for_stage(enemy, 1) {
			count += 1
		}
	}
	testing.expect(t, count > 0, "stage 1 should have at least one valid enemy")
}

@(test)
test_frygon_only_late_stage :: proc(t: ^testing.T) {
	for enemy in game.ENEMY_DATABASE {
		if enemy.name == "Frygon" {
			testing.expect(t, !game.enemy_valid_for_stage(enemy, 1), "Frygon should not appear on stage 1")
			testing.expect(t, game.enemy_valid_for_stage(enemy, 3), "Frygon should appear on stage 3")
		}
	}
}
