---
id: H1
title: Test the full loop on a real phone
release: R1
order: 1
kind: human
status: ready
sources: [docs/TESTING.md, docs/BLUEPRINT.md#9]
---

# H1 Test the full loop on a real phone

Only the owner can do this (two accounts, a phone, real emails). Follow
`docs/TESTING.md`: email code template, two accounts, book → confirm →
scan → check-in, push received. Report each failing step to Claude with
the step number and the message on screen; fixes become normal features.

Also needed before real users: Supabase Pro plan, SMTP for sign-in
emails, a domain for invite links (BLUEPRINT § 3.7).
