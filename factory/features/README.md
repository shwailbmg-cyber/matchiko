# Features

One file per feature: `<ID>-<slug>.md`. This folder is the factory's queue.
Format: `_template.md`. How the factory uses it: `docs/FACTORY.md`.

- **draft**: not ready to build (rules or decisions missing).
- **ready**: fully specified; the factory builds it once its
  `depends_on` are merged. A feature is approved by merging the PR that
  sets it to `ready`.
- **done**: built; set by the factory on the feature's branch, true on
  `main` once the PR is merged.
- **blocked**: waits for something outside the repo.

`python3 factory/bin/factory status` shows the whole queue.
