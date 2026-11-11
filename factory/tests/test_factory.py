"""Tests for the factory's deterministic parts: the state machine in
factory/bin/factory and the lint rules. Run by factory/checks.sh:
    python3 -m unittest discover -s factory/tests
"""
import importlib.machinery
import importlib.util
import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
CLI = REPO / "factory/bin/factory"

sys.path.insert(0, str(REPO / "factory/lints"))
import diff_lint  # noqa: E402
import l10n_check  # noqa: E402

FEATURE = """---
id: T1
title: Test feature
release: R1
order: 1
kind: build
status: ready
risk: medium
surfaces: [security]
depends_on: []
---

# T1 Test feature

## Steps

- [ ] 1. **db** A migration
- [ ] 2. **ui** A screen

## Acceptance criteria

- AC1 (step 1, pgTAP): it works
"""


class FactoryCli(unittest.TestCase):
    def setUp(self):
        self.root = Path(tempfile.mkdtemp())
        (self.root / "factory/features").mkdir(parents=True)
        shutil.copy(REPO / "factory/config.json", self.root / "factory/config.json")
        (self.root / "factory/features/T1-test.md").write_text(FEATURE)
        self.env = dict(os.environ, FACTORY_ROOT=str(self.root), FACTORY_NO_GIT="1")

    def tearDown(self):
        shutil.rmtree(self.root)

    def run_cli(self, *args, ok=True, stdin=None):
        r = subprocess.run([sys.executable, str(CLI), *args], capture_output=True, text=True,
                           env=self.env, input=stdin)
        if ok:
            self.assertEqual(r.returncode, 0, r.stderr)
        else:
            self.assertNotEqual(r.returncode, 0, r.stdout)
        return r.stdout + r.stderr

    def state(self):
        return json.loads((self.root / "factory/runs/T1/state.json").read_text())

    def write(self, rel, text):
        p = self.root / "factory/runs/T1" / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(text)

    def test_start_routes_reviewers_from_tag_risk_and_surfaces(self):
        self.assertIn("START T1 step 1", self.run_cli("start", "T1"))
        st = self.state()
        self.assertEqual(st["stage"], "spec")
        # db step → code + db + security; medium risk → security on opus
        self.assertEqual(st["reviewers"], {"code": "sonnet", "db": "sonnet", "security": "opus"})

    def test_illegal_moves_are_refused(self):
        self.run_cli("start", "T1")
        self.assertIn("illegal move", self.run_cli("advance", "T1", "review", ok=False))
        self.assertIn("spec.md is missing", self.run_cli("advance", "T1", "build", ok=False))

    def walk_step(self, reviewers):
        self.write(f"step-{self.state()['step']}/spec.md", "spec")
        self.run_cli("advance", "T1", "build")
        self.write(f"step-{self.state()['step']}/build.md", "STATUS: READY\n")
        self.run_cli("advance", "T1", "gate")
        st = self.state()
        self.write(f"step-{st['step']}/round-{st['round']}/checks.md", "GATE: PASS\n")
        self.run_cli("advance", "T1", "review")
        for r in reviewers:
            self.write(f"step-{st['step']}/round-{st['round']}/review-{r}.md", "VERDICT: PASS\n")
        self.run_cli("advance", "T1", "approve")
        self.write(f"step-{st['step']}/decision.md", "APPROVE\n")
        self.run_cli("advance", "T1", "step-done")

    def test_full_run_ticks_steps_and_marks_done_only_with_a_pr(self):
        self.run_cli("start", "T1")
        self.walk_step(["code", "db", "security"])
        text = (self.root / "factory/features/T1-test.md").read_text()
        self.assertIn("- [x] 1. **db**", text)
        self.assertIn("open steps remain", self.run_cli("advance", "T1", "pr-ready", ok=False))
        self.run_cli("advance", "T1", "spec")
        self.assertEqual(self.state()["reviewers"], {"code": "sonnet", "design": "sonnet", "security": "opus"})
        self.walk_step(["code", "design", "security"])
        self.assertIn("no PR number", self.run_cli("advance", "T1", "pr-ready", ok=False))
        self.run_cli("set", "T1", "pr", "12")
        self.run_cli("advance", "T1", "pr-ready")
        self.assertIn("status: done", (self.root / "factory/features/T1-test.md").read_text())
        self.assertEqual(self.state()["stage"], "pr-ready")
        self.assertEqual(self.state()["pr"], 12)
        # Nothing may move after pr-ready: merging the PR is the approval.
        self.assertIn("illegal move", self.run_cli("advance", "T1", "spec", ok=False))

    def test_review_needs_every_reviewer_to_pass(self):
        self.run_cli("start", "T1")
        self.write("step-1/spec.md", "spec")
        self.run_cli("advance", "T1", "build")
        self.write("step-1/build.md", "STATUS: READY\n")
        self.run_cli("advance", "T1", "gate")
        self.write("step-1/round-1/checks.md", "GATE: PASS\n")
        self.run_cli("advance", "T1", "review")
        self.write("step-1/round-1/review-code.md", "VERDICT: PASS\n")
        self.write("step-1/round-1/review-db.md", "VERDICT: CHANGES\n")
        self.write("step-1/round-1/review-security.md", "VERDICT: PASS\n")
        self.assertIn("must start with 'VERDICT: PASS'", self.run_cli("advance", "T1", "approve", ok=False))
        self.run_cli("advance", "T1", "build")
        self.assertEqual(self.state()["round"], 2)

    def test_rounds_are_capped_then_a_human_decides(self):
        self.run_cli("start", "T1")
        self.write("step-1/spec.md", "spec")
        self.run_cli("advance", "T1", "build")
        for rnd in (1, 2, 3):
            self.write("step-1/build.md", "STATUS: READY\n")
            self.run_cli("advance", "T1", "gate")
            self.write(f"step-1/round-{rnd}/checks.md", "GATE: FAIL\n")
            if rnd < 3:
                self.run_cli("advance", "T1", "build")
        self.assertIn("last one", self.run_cli("advance", "T1", "build", ok=False))
        self.run_cli("advance", "T1", "needs-human")
        self.assertIn("WAIT T1 needs you", self.run_cli("next"))
        out = self.run_cli("feedback", "T1", stdin="Use a smaller migration.")
        self.assertIn("feedback-1.md", out)
        self.run_cli("advance", "T1", "build")
        self.assertEqual(self.state()["round"], 1)

    def test_a_blocked_spec_goes_to_the_owner_and_back(self):
        self.run_cli("start", "T1")
        self.write("step-1/spec.md", "BLOCKED: which price?\n")
        self.assertIn("spec.md is BLOCKED", self.run_cli("advance", "T1", "build", ok=False))
        self.run_cli("advance", "T1", "needs-human")
        self.run_cli("feedback", "T1", stdin="The default price.")
        self.run_cli("advance", "T1", "spec")
        self.assertEqual(self.state()["stage"], "spec")

    def test_gate_cannot_be_skipped_with_a_failing_checks_file(self):
        self.run_cli("start", "T1")
        self.write("step-1/spec.md", "spec")
        self.run_cli("advance", "T1", "build")
        self.write("step-1/build.md", "STATUS: READY\n")
        self.run_cli("advance", "T1", "gate")
        self.write("step-1/round-1/checks.md", "GATE: FAIL\n")
        self.assertIn("GATE: PASS", self.run_cli("advance", "T1", "review", ok=False))

    def test_draft_features_and_unmet_dependencies_do_not_run(self):
        f = self.root / "factory/features/T1-test.md"
        f.write_text(FEATURE.replace("status: ready", "status: draft"))
        self.assertIn("only 'ready' features start", self.run_cli("start", "T1", ok=False))
        (self.root / "factory/features/T2-second.md").write_text(
            FEATURE.replace("id: T1", "id: T2").replace("depends_on: []", "depends_on: [T1]"))
        f.write_text(FEATURE)
        self.assertIn("HOLD   T2", self.run_cli("status"))

    def test_validate_catches_bad_files(self):
        (self.root / "factory/features/T3-bad.md").write_text(
            FEATURE.replace("id: T1", "id: T3").replace("**db**", "**magic**").replace("depends_on: []", "depends_on: [ZZ]"))
        out = self.run_cli("validate", ok=False)
        self.assertIn("tag 'magic'", out)
        self.assertIn("unknown feature ZZ", out)

    def test_protected_paths(self):
        loader = importlib.machinery.SourceFileLoader("factory_cli", str(CLI))
        spec = importlib.util.spec_from_loader("factory_cli", loader)
        mod = importlib.util.module_from_spec(spec)
        os.environ.update(FACTORY_ROOT=str(self.root), FACTORY_NO_GIT="1")
        try:
            loader.exec_module(mod)
            cfg = json.loads((self.root / "factory/config.json").read_text())
            bad = mod.protected_violations("T1", [
                "factory/checks.sh", ".github/workflows/ci.yml", "factory/features/G9-other.md",
                "factory/features/T1-test.md", "factory/runs/T1/step-1/spec.md", "app/lib/main.dart",
            ], cfg)
        finally:
            os.environ.pop("FACTORY_ROOT"), os.environ.pop("FACTORY_NO_GIT")
        self.assertEqual(len(bad), 3)


class FactoryWithGit(unittest.TestCase):
    """The real path: features approved on origin/main, work on factory/<ID>."""

    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp())
        origin, self.root = self.tmp / "origin.git", self.tmp / "work"
        self.git(self.tmp, "init", "-q", "--bare", "-b", "main", str(origin))
        self.git(self.tmp, "clone", "-q", str(origin), str(self.root))
        (self.root / "factory/features").mkdir(parents=True)
        shutil.copy(REPO / "factory/config.json", self.root / "factory/config.json")
        (self.root / "factory/checks.sh").write_text("echo checks ran; test ! -f FAIL_ME\n")
        (self.root / "factory/features/T1-test.md").write_text(FEATURE)
        (self.root / "app.txt").write_text("v1\n")
        self.commit("base")
        self.git(self.root, "push", "-q", "-u", "origin", "HEAD:main")
        self.env = {k: v for k, v in os.environ.items() if k not in ("FACTORY_NO_GIT",)}
        self.env["FACTORY_ROOT"] = str(self.root)

    def tearDown(self):
        shutil.rmtree(self.tmp)

    def git(self, cwd, *args):
        subprocess.run(["git", "-c", "user.name=t", "-c", "user.email=t@t", *args], cwd=cwd,
                       check=True, capture_output=True)

    def commit(self, msg):
        self.git(self.root, "add", "-A")
        self.git(self.root, "commit", "-q", "-m", msg)

    def run_cli(self, *args, ok=True):
        env = dict(self.env, GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@t",
                   GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@t")
        r = subprocess.run([sys.executable, str(CLI), *args], capture_output=True, text=True, env=env)
        self.assertEqual(r.returncode == 0, ok, r.stdout + r.stderr)
        return r.stdout + r.stderr

    def to_gate(self):
        self.run_cli("start", "T1")
        run = self.root / "factory/runs/T1/step-1"
        (run / "spec.md").write_text("spec")
        self.commit("spec")
        self.run_cli("advance", "T1", "build")
        (run / "build.md").write_text("STATUS: READY\n")
        self.commit("build")
        self.run_cli("advance", "T1", "gate")

    def branch(self):
        return subprocess.run(["git", "branch", "--show-current"], cwd=self.root,
                              capture_output=True, text=True).stdout.strip()

    def test_start_creates_the_branch_and_gate_passes(self):
        self.assertIn("RUN T1 start step 1", self.run_cli("next"))
        self.to_gate()
        self.assertEqual(self.branch(), "factory/T1")
        self.assertIn("GATE: PASS", self.run_cli("gate", "T1"))
        self.run_cli("advance", "T1", "review")
        # From another branch the state is read from the feature branch.
        self.git(self.root, "checkout", "-q", "main")
        self.assertIn("RUN T1 resume step 1/2 review round 1", self.run_cli("next"))

    def test_gate_fails_on_a_failing_check(self):
        self.to_gate()
        (self.root / "FAIL_ME").write_text("x")
        self.commit("break")
        self.assertIn("GATE: FAIL", self.run_cli("gate", "T1"))
        self.run_cli("advance", "T1", "review", ok=False)

    def test_gate_fails_when_a_protected_file_changes(self):
        self.to_gate()
        (self.root / "factory/checks.sh").write_text("true\n")
        self.commit("weaken the checks")
        self.assertIn("GATE: FAIL", self.run_cli("gate", "T1"))
        self.assertIn("factory/checks.sh (protected)",
                      (self.root / "factory/runs/T1/step-1/round-1/checks.md").read_text())

    def test_a_feature_not_ready_on_main_cannot_start(self):
        (self.root / "factory/features/T2-new.md").write_text(FEATURE.replace("id: T1", "id: T2"))
        self.commit("a feature that exists only on a branch")
        self.assertIn("unknown feature T2", self.run_cli("start", "T2", ok=False))


class DiffLint(unittest.TestCase):
    def rules(self, path, line):
        return [r for r, _ in diff_lint.lint_line(path, line)]

    def test_design_rules(self):
        p = "app/lib/features/x/presentation/x_screen.dart"
        self.assertEqual(self.rules(p, "color: Color(0xFF112233),"), ["D1"])
        self.assertEqual(self.rules("app/lib/core/theme/mk_colors.dart", "static const a = Color(0xFF112233);"), [])
        self.assertEqual(self.rules(p, "padding: EdgeInsets.only(left: 8),"), ["D2"])
        self.assertEqual(self.rules(p, "alignment: Alignment.centerLeft,"), ["D2"])
        self.assertEqual(self.rules(p, "padding: EdgeInsets.fromLTRB(20, 6, 20, 28),"), [])
        self.assertEqual(self.rules(p, "padding: EdgeInsets.fromLTRB(20, 6, 8, 28),"), ["D2"])
        self.assertEqual(self.rules(p, "padding: EdgeInsetsDirectional.only(start: 8),"), [])
        self.assertEqual(self.rules(p, "child: Text('Book now'),"), ["D3"])
        self.assertEqual(self.rules(p, "child: Text(l.bookNow),"), [])
        self.assertEqual(self.rules(p, "Text('${g.perSide}v${g.perSide}'),"), [])
        self.assertEqual(self.rules(p, "Text('🪪', style: s),"), [])

    def test_security_rules(self):
        p = "app/lib/features/x/data/x.dart"
        self.assertEqual(self.rules(p, "print(user.phone);"), ["S1"])
        self.assertEqual(self.rules(p, "final u = 'http://example.com/api';"), ["S2"])
        self.assertEqual(self.rules(p, "final u = 'http://127.0.0.1:54321';"), [])
        self.assertEqual(self.rules("app/env/dev.json", '"KEY": "service_role"'), ["S3"])
        self.assertEqual(self.rules("docs/x.md", "sbp_" + "a" * 30), ["S3"])
        self.assertEqual(self.rules("app/android/app/src/main/AndroidManifest.xml", 'android:allowBackup="true"'), ["S4"])
        self.assertEqual(self.rules(p, "print(x); // factory-lint: ignore S1 dev tool only"), [])

    def test_migration_rules(self):
        good = """
        create table public.things (id uuid primary key);
        alter table public.things enable row level security;
        create function public.do_thing(p uuid) returns void language sql
          security definer set search_path = '' as $$ select 1 $$;
        revoke all on function public.do_thing(uuid) from public, anon;
        """
        self.assertEqual(diff_lint.lint_migration("m.sql", good), [])
        bad = """
        create table public.things (id uuid primary key);
        create function public.do_thing(p uuid) returns void language sql
          security definer as $$ select 1 $$;
        """
        self.assertEqual(sorted(r for r, _ in diff_lint.lint_migration("m.sql", bad)), ["Q2", "Q3", "Q4"])
        replaced = "create or replace function public.old(p uuid) returns void language sql security definer set search_path = '' as $$ select 1 $$;"
        self.assertEqual(diff_lint.lint_migration("m.sql", replaced), [])


class L10nCheck(unittest.TestCase):
    def test_keys_and_placeholders(self):
        files = {
            "en": {"hello": "Hello {name}", "bye": "Bye", "@hello": {}},
            "fr": {"hello": "Bonjour", "extra": "x"},
            "ar": {"hello": "مرحبا {name}", "bye": ""},
        }
        out = "\n".join(l10n_check.problems(files))
        self.assertIn("app_fr.arb: missing key 'bye'", out)
        self.assertIn("app_fr.arb: extra key 'extra'", out)
        self.assertIn("app_fr.arb: 'hello' placeholders differ", out)
        self.assertIn("app_ar.arb: 'bye' is empty", out)


if __name__ == "__main__":
    unittest.main()
