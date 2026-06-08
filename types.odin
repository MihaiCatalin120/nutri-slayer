package main

import rl "vendor:raylib"

// Block types match the probability array order:
// [protein, carbohydrates, fiber, unsaturated fat, saturated fat, sugar]
Block_Type :: enum u8 {
	Protein,
	Carbohydrates,
	Fiber,
	Unsaturated_Fat,
	Saturated_Fat,
	Sugar,
}

NUM_BLOCK_TYPES :: int(Block_Type.Sugar) + 1

Block_Colors: [NUM_BLOCK_TYPES]rl.Color = {
	{156, 23, 23, 255}, // protein
	{207, 200, 105, 255}, // carbohydrates
	{44, 66, 44, 255}, // fiber
	{31, 163, 35, 255}, // unsaturated fat
	{201, 145, 40, 255}, // saturated fat
	{212, 211, 205, 255}, // sugar
}

Block_Names: [NUM_BLOCK_TYPES]string = {
	"Protein",
	"Carbs",
	"Fiber",
	"Unsat. Fat",
	"Sat. Fat",
	"Sugar",
}

Block_Full_Names: [NUM_BLOCK_TYPES]string = {
	"Protein",
	"Carbohydrates",
	"Fiber",
	"Unsaturated Fat",
	"Saturated Fat",
	"Sugar",
}

// Attack multiplier per block type (attacks only for now).
Block_Attack_Multiplier: [NUM_BLOCK_TYPES]f32 = {
	1.4, // protein — strong attack
	1.0, // carbohydrates
	1.2, // fiber
	1.3, // unsaturated fat
	0.8, // saturated fat
	0.7, // sugar
}

GRID_COLS :: 9
GRID_ROWS :: 9
MIN_POP_SIZE :: 2

// Design resolution — all layout and input use these logical pixels.
WINDOW_W: i32 : 1280
WINDOW_H: i32 : 720

PANEL_W: i32 : 220
SEARCH_H: i32 : 56
HEADER_H: i32 : 200
STATS_H: i32 : 80
BLOCK_INFO_H: i32 : 100

ARENA_X: i32 : 0
ARENA_Y: i32 : 0
ARENA_W: i32 : WINDOW_W
ARENA_H: i32 : WINDOW_H - SEARCH_H

GAME_X: i32 : PANEL_W
GAME_Y: i32 : HEADER_H
GAME_W: i32 : WINDOW_W - 2 * PANEL_W
GAME_H: i32 : ARENA_H - HEADER_H

FALL_ANIM_DURATION: f32 : 0.45
POP_ANIM_DURATION: f32 : 0.22
MAX_FALL_ANIMS :: GRID_ROWS * GRID_COLS
MAX_POP_ANIMS :: GRID_ROWS * GRID_COLS

Fall_Anim :: struct {
	active:   bool,
	col:      int,
	from_row: f32,
	to_row:   int,
	block:    Block_Type,
	t:        f32,
}

Pop_Anim :: struct {
	active: bool,
	col:    int,
	row:    int,
	block:  Block_Type,
	t:      f32,
}

Anim_State :: struct {
	falls:           [MAX_FALL_ANIMS]Fall_Anim,
	pops:            [MAX_POP_ANIMS]Pop_Anim,
	pending_gravity: bool,
	locked:          bool,
}

Damage_Target :: enum u8 {
	Player,
	Enemy,
}

MAX_DAMAGE_ANIMS :: 4
MAX_SHIELD_ANIMS :: 4
DAMAGE_HOLD_DELAY: f32 : 0.45
DAMAGE_FLY_DURATION: f32 : 0.35
SHIELD_HOLD_DELAY: f32 : DAMAGE_HOLD_DELAY / 2
SHIELD_FLY_DURATION: f32 : DAMAGE_FLY_DURATION

Damage_Anim :: struct {
	active:     bool,
	damage:     i32,
	target:     Damage_Target,
	hold_timer: f32,
	fly_t:      f32,
	flying:     bool,
	start_x:    f32,
	start_y:    f32,
	end_x:      f32,
	end_y:      f32,
}

Shield_Anim :: struct {
	active:     bool,
	shield:     i32,
	hold_timer: f32,
	fly_t:      f32,
	flying:     bool,
	start_x:    f32,
	start_y:    f32,
	end_x:      f32,
	end_y:      f32,
}

Cell :: struct {
	active: bool,
	block:  Block_Type,
}

Board :: struct {
	cells: [GRID_ROWS][GRID_COLS]Cell,
}

Actor :: struct {
	name:               cstring,
	hp:                 i32,
	max_hp:             i32,
	shield:             i32,
	turns_per_attack:   i32,
	turns_until_attack: i32,
	color:              rl.Color,
}

Game_State :: struct {
	board:                Board,
	anims:                Anim_State,
	damage_anims:         [MAX_DAMAGE_ANIMS]Damage_Anim,
	shield_anims:         [MAX_SHIELD_ANIMS]Shield_Anim,
	player:               Actor,
	enemy:                Actor,
	player_turns:         i32,
	search_buffer:        [64]u8,
	search_len:           int,
	last_meal:            [64]u8,
	last_meal_len:        int,
	status_message:       [128]u8,
	status_timer:         f32,
	hover_col, hover_row: int,
	selected_count:       int,
}

Food_Item :: struct {
	name:  string,
	terms: []string,
	probs: [NUM_BLOCK_TYPES]f32,
}
