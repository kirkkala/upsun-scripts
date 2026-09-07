# Kirkkala's Upsun commands

Unofficial CLI helpers for [Upsun](https://upsun.com/) projects, by [kirkkala](https://github.com/kirkkala). Not affiliated with Upsun.

## Install

Install from GitHub:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/kirkkala/upsun-scripts/main/install.sh)"
```

To work on the scripts (when contributing):

```bash
git clone https://github.com/kirkkala/upsun-scripts.git
cd upsun-scripts
./install.sh
```

Scripts are installed to `/usr/local/lib/kirkkala-upsun`, with `upsun-db-dump` and `upsun-check-traffic` linked onto `/usr/local/bin`. After that you can run them from any Upsun project repo.

```bash
upsun-db-dump
upsun-check-traffic
```

Use `--help` or `--version` on either command.

## upsun-db-dump

Dump database for the **current git branch environment** into a dated SQL file.

### What it does

Runs `upsun db:dump` for the environment that matches your current git branch, and writes:

```text
YYYY-MM-DD-HHMM-<project>-<branch>.sql
```

into:

- `<repo>/drupal/db_dumps/` if that directory already exists
- `<repo>/db_dumps/` otherwise (created if needed)

## upsun-check-traffic

Print the top IP addresses hitting **origin** on the **main** environment.

Run it from the Upsun project you want to inspect:

```bash
upsun-check-traffic
upsun-check-traffic 11
upsun-check-traffic 20/Nov/2025:07
```

### What it does

SSHs into the linked project's `main` environment, greps `/var/log/access.log` for a UTC time window, and prints the top IPs with [AbuseIPDB](https://www.abuseipdb.com/) links. Useful for spotting abusive traffic before blocking it on the CDN.

Time window:

- no argument — current hour minus 3 hours (server is UTC)
- `11` — that hour of today (UTC)
- `20/Nov/2025:07` — that hour (shorter prefixes widen the window)
- `20/Nov/2025` — the whole day (slower)

## Requirements

- macOS or Linux
- [git](https://git-scm.com/)
- [Upsun CLI](https://docs.upsun.com/administration/cli/) (`upsun`)
- A local clone of an Upsun project, linked with `upsun project:set-remote` (run the commands from inside it)

## Uninstall

```bash
/usr/local/lib/kirkkala-upsun/uninstall.sh
```

From a local checkout, just use `./uninstall.sh`.

## Releasing

`VERSION` lives in `src/upsun-scripts-common.sh`.

When cutting a GitHub release, bump version, commit and create the tag/release as usual.
