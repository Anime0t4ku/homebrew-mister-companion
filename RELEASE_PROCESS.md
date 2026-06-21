# Release Process

This repository supports a **manual** release workflow to update the Homebrew cask version from upstream releases in `Anime0t4ku/mister-companion`.

Workflow files:

- `.github/workflows/update-cask-from-upstream-release.yml` (manual version bumps)
- `.github/workflows/cask-audit.yml` (automatic PR validation)

## PR Checks

All pull requests that modify `Casks/*.rb` run the **Cask Audit** workflow. It performs:

- `brew style --casks` (Homebrew Ruby style / RuboCop rules)
- `brew audit --casks --strict --online` (full cask linting, metadata, URLs, etc.)

The job must pass before the PR can be merged (configure as a required status check in repository branch protection rules for the `main` branch).

This prevents regressions in Homebrew compatibility, style violations, and common cask mistakes.

## Goal

When you run the workflow, it:

1. Resolves the upstream tag (latest release, or a tag you provide).
2. Computes SHA256 for `https://github.com/Anime0t4ku/mister-companion/archive/refs/tags/<tag>.tar.gz`.
3. Updates `Casks/mister-companion.rb` `version` and `sha256`.
4. Applies the change either by pull request or direct commit.

## Choices

### Option 1: Pull Request mode (`apply_mode: pr`) - Recommended

How it works:

1. Run the workflow manually from GitHub Actions.
2. Set `apply_mode` to `pr`.
3. Leave `release_tag` empty to use latest release, or set it explicitly.
4. Workflow creates/updates a PR with the cask version and checksum bump.

Pros:

- Safer: review before merge.
- Better audit trail for release and checksum changes.
- Easier rollback if something is wrong.
- Aligns with common tap maintenance practices.

Cons:

- One extra merge step.
- Slightly slower than direct commit.

### Option 2: Direct mode (`apply_mode: direct`)

How it works:

1. Run the workflow manually from GitHub Actions.
2. Set `apply_mode` to `direct`.
3. Leave `release_tag` empty to use latest release, or set it explicitly.
4. Workflow commits directly to the default branch.

Pros:

- Fastest path to publish cask update.
- Minimal operational overhead.

Cons:

- No review gate.
- Higher risk of publishing an incorrect version bump.
- Less change visibility than a PR-based flow.

### Option 3: Manual tag override (`release_tag` input)

How it works:

1. Use either `pr` or `direct` mode.
2. Set `release_tag` explicitly (example: `v1.4.0`).

Pros:

- Pin exact version for deterministic updates.
- Useful for reruns, skipped tags, or controlled rollout.

Cons:

- Human error risk if tag is mistyped.
- Requires maintainers to know the intended tag in advance.

## Recommendation

Use `apply_mode: pr` as the default process.

Keep `apply_mode: direct` for urgent situations where speed is more important than review.

## Quick Runbook

1. Open the repository on GitHub.
2. Go to **Actions** -> **Update Cask From Upstream Release**.
3. Click **Run workflow**.
4. Choose:
   - `apply_mode: pr` (recommended), and optionally set `release_tag`.
5. If using PR mode, review and merge.
6. Validate install path locally if needed:

```bash
brew tap Anime0t4ku/homebrew-mister-companion
brew reinstall --cask mister-companion
```

7. Validate nightly update behavior locally if needed:

```bash
brew update
brew upgrade --cask --greedy mister-companion-unstable-nightly
```

Optional forced refresh:

```bash
brew reinstall --cask mister-companion-unstable-nightly
```
