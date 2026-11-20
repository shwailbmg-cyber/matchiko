---
id: G1
title: Play with friends (tag, accept, same side)
release: R1
order: 20
kind: build
status: ready
risk: medium
surfaces: [security]
depends_on: [Q2]
sources: [docs/GAMES.md#3 (F1 F2 F3 F8 F9), docs/BLUEPRINT.md#5.2, docs/BLUEPRINT.md#5.4]
---

# G1 Play with friends (tag, accept, same side)

## Goal

A player tags friends, they accept with one tap, and the whole group is
matched into the same side of one game. Today tagging exists only in the
demo data.

## Rules

1. A **group** is for one search. It has a leader and up to 10 tagged
   friends. Only accepted friends can be tagged; never someone blocked
   (either way) or banned.
2. A user is in at most one active group (as leader or member).
3. Each tagged friend gets a notification (`group_invite`) and answers
   **Accept** (with his position) or **Decline**. No answer after
   **15 minutes** = not in the group.
4. The leader can start the search at any time with those who accepted.
   A friend who accepts later can still join the game from its link if a
   spot is left on the group's side.
5. A game is offered to a group only if it has enough free spots **on one
   side** for every accepted member, no member is blocked by or blocks a
   player in it, and no member already plays within one hour of it.
6. Joining is one transaction: all members land on the same side, or
   nobody joins.
7. A member can leave the group before the game is joined. After the
   join, leaving is the normal "leave game" (GAMES § 3, F8).
8. All of this is enforced in Postgres; the app only shows it.

## Steps

- [ ] 1. **db** Migration: tables `groups` (leader, status forming/searching/joined/cancelled, created_at, expires_at) and `group_members` (user, status invited/accepted/declined/left, position); RLS (members read their own group; no direct writes); RPCs `create_group(p_handles text[], p_position)`, `answer_group_invite(p_group, p_accept, p_position)`, `leave_group(p_group)`, `my_group()` returning JSON; a `group_invite` notification per tagged friend; rules 1–4 and 7. pgTAP file with allow and deny cases.
- [ ] 2. **db** Migration: `find_match_for_group(p_group, p_positions)` (same score as `find_match`, rule 5) and `join_game_as_group(p_group, p_game)` (rule 6, row lock on the game like `join_open_game`). pgTAP: same side; not enough spots on one side → not offered; a blocked pair → not offered; a failed join changes nothing.
- [ ] 3. **app** Domain model `PlayGroup` (freezed, JSON from `my_group()`), `GameRepository` methods (`createGroup`, `answerGroupInvite`, `leaveGroup`, `myGroup`, `findGameForGroup`, `joinGameAsGroup`) in the interface, the demo repository and the Supabase repository; a fixture contract test from the real RPC output (`supabase/tests/local/dump_game_fixture.sh`); `NotificationKind.groupInvite`.
- [ ] 4. **ui** Play screen "With friends": the tag sheet shows each friend's state (invited, accepted, declined), the 15-minute countdown and "Start with those who accepted"; the search uses the group functions; the notification card for `group_invite` has Accept / Decline and a position picker. Texts in en/fr/ar. Widget tests for both sides of the flow.

## Acceptance criteria

- AC1 (step 1, pgTAP): GIVEN a and b are friends WHEN a creates a group tagging b THEN b has one `group_invite` notification and `my_group()` for b shows status invited.
- AC2 (step 1, pgTAP): tagging a non-friend, a blocked user, a banned user or a user already in an active group raises an error and creates nothing.
- AC3 (step 1, pgTAP): an invitation answered after `expires_at` is refused; a user outside the group cannot read it (RLS deny case).
- AC4 (step 2, pgTAP): GIVEN a group of 3 and an open 5v5 game with 2 free spots on side A and 3 on side B WHEN the group joins THEN all three are on side B.
- AC5 (step 2, pgTAP): a game with only 2 free spots per side is not offered to a group of 3; a game containing a player blocked by any member is not offered.
- AC6 (step 3, unit test): `PlayGroup.fromJson` reads the fixture dumped from `my_group()`.
- AC7 (step 4, widget test): the leader tags a friend, sees "invited", the friend accepts from the notification, the leader sees "accepted" and can start the search; all visible text comes from the ARB files in three languages.

## Out of scope

Inviting a friend who has no account (invite link, feature S29). One-day
teams and opponents for a group (G8). Server-held 30-second offers (S28).
