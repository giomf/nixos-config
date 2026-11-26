---
name: ssh
description: Rules for connecting to remote machines. Use before running any command that opens a connection to another host: ssh, scp, sftp, rsync over ssh, sshfs, mosh, nixos-rebuild/deploy with --target-host or --build-host, nix copy --to ssh://, git over ssh to a non-GitHub host, or any script/just recipe that does one of these.
---

# SSH: ask before connecting

Before connecting to any remote host, ask the user first and wait for an explicit yes. Every time: approval for one connection does not cover the next, another host, or a different command on the same host.

When asking, state:

- the host (e.g. `moon.guif.dev`)
- the exact command to be run there
- whether it changes anything (writes, restarts, deploys) or is read-only

This includes indirect connections: `just` recipes, scripts in `scripts/`, or deploy tools that SSH under the hood. Read the recipe/script first to know whether it connects.

Not covered: `localhost` and pushes/fetches to GitHub (those follow the git skill).
