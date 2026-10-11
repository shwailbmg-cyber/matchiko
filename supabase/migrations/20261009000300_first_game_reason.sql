-- One-time welcome XP after a player's first completed game. Kept in its own
-- migration: a new enum value can't be used in the transaction that adds it.
alter type public.reward_reason add value if not exists 'first_game';
