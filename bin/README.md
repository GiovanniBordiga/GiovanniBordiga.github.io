# `bin/` scripts

## `update_scholar_citations.py`

Fetches citation counts from Google Scholar and writes them to
`_data/citations.yml`, which the site reads to display per-paper citation
numbers.

- Reads the Scholar user ID from `scholar_userid` in `_data/socials.yml`.
- Skips the fetch if `_data/citations.yml` was already updated today.
- Skips writing the file if the fetched data is identical to what's on disk.
- Requires the packages in [`requirements.txt`](../requirements.txt)
  (`scholarly`, `pyyaml`).

### Why not a GitHub Actions cron?

Google Scholar blocks requests from datacenter IP ranges, and GitHub-hosted
runners use exactly those ranges — so a CI cron gets served a CAPTCHA and
fails. The script has to run from an IP Scholar doesn't block: a personal
machine, or a Claude Code cloud session (whose managed-proxy egress has not
been blocked in practice). See the automation options below.

### Run it manually (local machine)

```bash
pip install -r requirements.txt
python bin/update_scholar_citations.py
```

Then commit and push the change to `_data/citations.yml`.

### Run it in a Claude Code cloud session

Cloud sessions install the dependencies automatically via the
`SessionStart` hook in [`.claude/settings.json`](../.claude/settings.json),
which runs [`../scripts/install_pkgs.sh`](../scripts/install_pkgs.sh) (cloud-only,
and a no-op once the packages are present). So you only need:

```bash
python bin/update_scholar_citations.py
```

The standard update flow used in this repo:

1. `git fetch origin main` and fast-forward the working branch to `origin/main`.
2. Run the script.
3. If `_data/citations.yml` changed, commit it, then fast-forward `main` and push.
   If the script reports no changes, don't commit.

### Automate it daily (Claude Code Routine)

A [Routine](https://code.claude.com/docs/en/routines) runs the flow on a
schedule from Anthropic-managed cloud infrastructure — the same kind of egress
that isn't Scholar-blocked. Create it at
[claude.ai/code/routines](https://claude.ai/code/routines) with:

- **Prompt**: the update flow above (fetch, run script, commit + merge to `main`
  only if `_data/citations.yml` changed, otherwise report no change; no PR).
- **Environment → Network access: Full** — required so the script can reach
  `scholar.google.com`. The default "Trusted" allowlist does **not** include it,
  so a Trusted-access run fails with `403 host_not_allowed`. (Dependency
  installation is already handled by the `SessionStart` hook, so no environment
  setup script is needed.)
- **Permissions → Allow unrestricted branch pushes** — so the routine can push
  to `main` rather than only `claude/`-prefixed branches.
- **Trigger → Schedule → Daily** (minimum interval is one hour).

Recurring routines run until paused or deleted — they do not expire on a fixed
timer.
