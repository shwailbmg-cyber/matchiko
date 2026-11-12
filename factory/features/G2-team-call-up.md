---
id: G2
title: Team call-up (In / Out, reminders, substitutes)
release: R1
order: 30
kind: build
status: ready
risk: medium
surfaces: [security]
depends_on: [Q2]
sources: [docs/GAMES.md#2, docs/GAMES.md#3 (T4 T5 T12), docs/GAMES.md#10]
---

# G2 Team call-up (In / Out, reminders, substitutes)

## Goal

A captain asks his team "Thursday 21:00, are you in?" and sees a clear
count. It replaces the WhatsApp thumbs-up: only In or Out, with automatic
reminders to those who did not answer.

## Rules

1. A team has one captain and may have one **co-captain** (set by the
   captain). Both can create and close call-ups.
2. A **call-up** has a date and hour, a size (players per side) and an
   optional pitch and note. Every team member gets a `callup` notification.
3. A member answers **In** or **Out** and can change his answer until the
   call-up is closed. There is no "maybe".
4. Members who have not answered get one reminder 48 h before and one
   24 h before (through the existing `send_reminders` job).
5. The first `size` players who said In are **starters**; later ones are
   **substitutes**, in the order they answered.
6. A call-up closes when the captain closes it or when its hour has
   passed. Closed call-ups are read-only.
7. Only members of the team can read its call-ups and answers.

## Steps

- [ ] 1. **db** Migration: `team_members.role` (member / co_captain), `set_co_captain(p_team, p_handle)`; tables `team_callups` and `callup_answers` with RLS (team members read; no direct writes); RPCs `create_callup(p_team, p_starts_at, p_per_side, p_pitch, p_note)`, `answer_callup(p_callup, p_in)`, `close_callup(p_callup)`, `team_callups(p_team)` returning JSON with counts, starters and substitutes; `callup` notifications; reminders added to `send_reminders` (once each, like the "still coming" reminder). pgTAP allow and deny cases.
- [ ] 2. **app** Domain models `Callup` and `CallupAnswer` (freezed, JSON), repository methods in the interface, demo and Supabase repositories, fixture contract test, `NotificationKind.callup`.
- [ ] 3. **ui** Team page: "Call-up" card with the count ("5 in · 2 out · 3 no answer"), starters and substitutes, In / Out buttons for members, create and close for the captain and co-captain; create sheet (date, hour, size, pitch, note); notification card with In / Out. Texts in en/fr/ar using the word "Call-up / Convocation / استدعاء" (GAMES § 10). Widget tests.

## Acceptance criteria

- AC1 (step 1, pgTAP): the captain creates a call-up → one `callup` notification per other member; a plain member cannot create one (deny).
- AC2 (step 1, pgTAP): a member answers In then Out → one answer row, last value kept; a non-member cannot answer or read (deny).
- AC3 (step 1, pgTAP): with size 5 and 7 players In, `team_callups` lists 5 starters then 2 substitutes in answer order.
- AC4 (step 1, pgTAP): `send_reminders()` notifies each non-responder once at 48 h and once at 24 h, never twice.
- AC5 (step 1, pgTAP): answering a closed or past call-up raises an error.
- AC6 (step 2, unit test): `Callup.fromJson` reads the fixture dumped from `team_callups`.
- AC7 (step 3, widget test): a member taps In and the count changes; the captain sees create and close, a member does not; RTL layout has no overflow.

## Out of scope

Finding loan players for the missing spots (G3). Creating the booking
from a call-up and finding an opponent (G5, G8).
