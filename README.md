# Nutri Slayer

A turn-based collapse puzzle RPG built with [Odin](https://odin-lang.org/) and [Raylib](https://www.raylib.com/). Match and pop nutritional blocks to fuel your attacks, feed yourself new blocks by searching for meals, and defeat enemies before they wear you down.

## Game Concept

Nutri Slayer combines a **collapse-style block puzzle** with **turn-based combat**. The board is not a traditional match-3 refill: blocks only appear when you deliberately search for food. Popping connected groups triggers combat actions whose strength depends on what you cleared and how many blocks were in the group.

### Core Loop

1. **Search for food** — type a meal name (e.g. `salad`, `burger`, `sandwich`) in the search bar and press Enter or click **Eat**.
2. **Blocks spawn** — new blocks appear in empty board slots, typed according to that food's nutritional profile.
3. **Pop blocks** — click a group of 2+ adjacent same-color blocks to collapse them.
4. **Attack** — each pop currently triggers a player **attack** (defence and spell actions are planned for later).
5. **Enemy retaliation** — after a set number of player turns, the enemy attacks back.
6. **Win / lose** — reduce the enemy to 0 HP to win; if your HP reaches 0, you lose.

## Screen Layout

```
┌──────────────┬─────────────────────────────┬──────────────┐
│   PLAYER     │            GAME             │    ENEMY     │
│  [sprite]    │   collapse block grid       │  [sprite]    │
│  HP bar      │                             │  HP bar      │
├──────────────┼─────────────────────────────┼──────────────┤
│ player stats │                             │ enemy stats  │
│  / info      │                             │              │
├──────────────┴─────────────────────────────┴──────────────┤
│  Search food: [________________________]  [Eat / Enter]   │
└───────────────────────────────────────────────────────────┘
```

| Region | Purpose |
|--------|---------|
| **Game** | Collapse puzzle grid. Blocks fall with gravity after pops; **no automatic respawn**. |
| **Player** | Player sprite (placeholder) and current / max HP bar. |
| **Enemy** | Enemy sprite (placeholder) and HP bar. Shows turns until next enemy attack. |
| **Player stats / info** | Active buffs and debuffs — **placeholder** for now. |
| **Enemy stats** | Enemy buffs / debuffs — **placeholder** for now. |
| **Search bar** | Enter a food name to spawn blocks based on that item's nutrition profile. |

## Block Types & Colors

Each block represents a macronutrient category. Colors are fixed:

| Type | RGB | Role (planned) |
|------|-----|----------------|
| Protein | 156, 23, 23 | Strong attacks |
| Carbohydrates | 207, 200, 105 | Balanced attacks |
| Fiber | 232, 144, 44 | Weaker attacks (defence planned) |
| Unsaturated fat | 31, 163, 35 | Moderate attacks |
| Saturated fat | 201, 145, 40 | Moderately strong attacks |
| Sugar | 212, 211, 205 | Weak attacks (spells planned) |

## Food & Block Spawning

Food items map to a **probability array** of length 6:

```
[protein, carbohydrates, fiber, unsaturated fat, saturated fat, sugar]
```

All values must sum to **1.0**. When a food is searched, empty cells receive new blocks sampled from that distribution.

### Example foods (current database)

| Food | Probability array |
|------|-------------------|
| green salad | `[0.12, 0.22, 0.30, 0.28, 0.03, 0.05]` |
| burger | `[0.28, 0.22, 0.04, 0.18, 0.22, 0.06]` |
| sandwich | `[0.22, 0.30, 0.08, 0.15, 0.12, 0.13]` |
| apple | `[0.02, 0.18, 0.28, 0.02, 0.00, 0.50]` |
| chicken breast | `[0.72, 0.00, 0.00, 0.18, 0.08, 0.02]` |
| pasta | `[0.14, 0.58, 0.06, 0.06, 0.08, 0.08]` |
| avocado toast | `[0.08, 0.32, 0.18, 0.38, 0.02, 0.02]` |
| donut | `[0.06, 0.38, 0.02, 0.10, 0.18, 0.26]` |

Aliases are supported (e.g. `salad` → green salad, `hamburger` → burger).

Add or edit entries in `food.odin`.

## Combat (Current Implementation)

### Player actions

When a connected group is popped:

- **Action type** — determined by block type (attack / defence / spell — **only attack is implemented**).
- **Strength** — scales with the number of blocks popped in that action and a per-type multiplier.

```
damage = base_damage × pop_count × type_multiplier
```

### Enemy actions

- Each enemy defines `turns_per_attack` (default enemy: every **3** player turns).
- When the counter reaches 0, the enemy deals random damage and the counter resets.

### Turn definition

Each successful block pop counts as **one player turn** for enemy attack timing.

## Design Notes & Future Plans

These are intentional placeholders you can evolve:

- **No auto-respawn** — the board only gains blocks via the search bar.
- **Sprites** — colored rectangles with P/E labels; replace with real art.
- **Buffs / debuffs** — UI panels exist but show placeholder text.
- **Defence & spells** — block types will eventually map to different action types.
- **Enemy variety** — different enemies can have unique `turns_per_attack`, damage, and stats.
- **Food database** — expand with real nutritional data or an API later.

## Controls

| Input | Action |
|-------|--------|
| Type in search bar | Enter food name |
| Enter / Eat button | Spawn blocks from food |
| Click block group (2+) | Pop group and attack |
| R | Restart after game over |

## Build & Run

Requires Odin with Raylib vendor bindings.

```bash
odin run .
```

Or build a binary:

```bash
odin build . -out:nutri-slayer
```

Run tests:

```bash
odin test tests
```

## Project Structure

```
main.odin         — entry point
src/              — game library (package game)
tests/            — unit tests (one file per module)
```

## Modifying Game Design

This README is the living design document. When you change mechanics, update the relevant sections here and adjust the corresponding `.odin` files:

- **Food items** → `food.odin` (`FOOD_DATABASE`)
- **Block colors / types** → `types.odin`
- **Combat formulas** → `combat.odin`
- **UI layout** → `types.odin` (dimensions) and `ui.odin` (drawing)
- **Enemy behavior** → `combat.odin` (`reset_game`, `try_enemy_attack`)
