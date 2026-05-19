# homebrew-mister-companion

[![License](https://img.shields.io/github/license/Anime0t4ku/mister-companion)](https://github.com/Anime0t4ku/mister-companion)
[![GitHub stars](https://img.shields.io/github/stars/Anime0t4ku/mister-companion)](https://github.com/Anime0t4ku/mister-companion)

**Official Homebrew tap for MiSTer Companion** — the clean GUI companion for MiSTer FPGA.

## Installation

Install Homebrew (if you don't have it yet)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### macOS (Recommended)

```bash
brew tap Anime0t4ku/homebrew-mister-companion
brew install --cask mister-companion
```

***This installs:***

- A native **MiSTer Companion.app** in your `/Applications` folder
- The `mister-companion` command-line tool

**Launch it from:**

- **Spotlight** — Press `⌘ + Space` and type **MiSTer Companion**
- **Applications folder** — Open `/Applications/MiSTer Companion.app`
- **Terminal** — Just type `mister-companion`

### Linux (via Homebrew)

```bash
brew tap Anime0t4ku/homebrew-mister-companion
brew install mister-companion
```

### Updating
To get the latest version:

```bash
brew upgrade mister-companion
```

### Maintainer Release Process

This tap includes a manual workflow at `.github/workflows/update-cask-from-upstream-release.yml`.

Detailed guide (choices, pros/cons, and runbook): [RELEASE_PROCESS.md](./RELEASE_PROCESS.md)

Run it from GitHub Actions with **Run workflow** and choose:

- `apply_mode: pr` (recommended) to open or update a pull request with the cask version bump.
- `apply_mode: direct` to commit directly to the default branch.

Optional input:

- `release_tag` to force a specific tag (for example `v1.4.0`).

If `release_tag` is empty, the workflow reads the latest release from `Anime0t4ku/mister-companion` and updates `Casks/mister-companion.rb`.

### Uninstalling 

```bash
# macOS
brew uninstall --cask mister-companion

# Linux
brew uninstall mister-companion
```

### About MiSTer Companion
MiSTer Companion is a simple and beautiful GUI utility that makes managing your MiSTer FPGA device easy — whether you connect over SSH or work directly with the SD card.

Main Project Repository: Anime0t4ku/mister-companion

### Contributing

Bug reports, feature requests, and general discussion → main repo issues
Issues specific to the Homebrew tap → open an issue in this repository

### License
This tap follows the same license as the main MiSTer Companion project.


Made with ❤️ for the MiSTer FPGA community.