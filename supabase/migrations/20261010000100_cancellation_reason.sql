-- Every cancellation by a player costs XP/coins (product decision: cancelling
-- always means someone isn't serious). Own migration: a new enum value can't
-- be used in the transaction that adds it.
alter type public.reward_reason add value if not exists 'cancellation';
