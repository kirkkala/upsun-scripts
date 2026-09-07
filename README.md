# upsun-scripts

Small CLI helpers for working with [Upsun](https://upsun.com/) projects.

## Install

```bash
./install.sh
```

Commands are installed to `/usr/local/bin`. After that you can run them from any Upsun project repo.

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
upsun-check-traffic --ignore-internal
```

### What it does

SSHs into the linked project's `main` environment, greps `/var/log/access.log` for a UTC time window, and prints the top IPs with [AbuseIPDB](https://www.abuseipdb.com/) links. Useful for spotting abusive traffic before blocking it on the CDN.

Time window:

- no argument — current hour minus 3 hours (server is UTC)
- `11` — that hour of today (UTC)
- `20/Nov/2025:07` — that hour (shorter prefixes widen the window)
- `20/Nov/2025` — the whole day (slower)

`--ignore-internal` skips the IP prefixes listed in the script (OPH Zscaler ranges).

## Requirements

- macOS or Linux
- [git](https://git-scm.com/)
- [Upsun CLI](https://docs.upsun.com/administration/cli/) (`upsun`)
- A local clone of an Upsun project, linked with `upsun project:set-remote` (run the commands from inside it)

## Uninstall

```bash
cd /path/to/upsun-scripts
./uninstall.sh
```

## Releasing

`VERSION` lives in `src/upsun-scripts-common.sh`.

When you cut a GitHub release, bump that value to match the tag, commit it, then create the tag/release as usual (`0.2.0`). Re-run `./install.sh` to update on local.
