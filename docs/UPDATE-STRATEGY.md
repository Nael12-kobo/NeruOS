# NeruOS Update Strategy

## Update layers

NeruOS will eventually need two separate update mechanisms.

### 1. Arch base and system packages

The Arch Linux base is updated through pacman and trusted Arch repositories.

The current prototype uses pacman-contrib's checkupdates command to list packages whose repository version differs from the installed version.

The check:
- Uses the current pacman repository configuration.
- Lists package names and old/new versions.
- Does not install or upgrade packages.
- Does not run pacman with elevated privileges from the NeruOS UI.
- Reports an error when repository metadata or network access is unavailable.

The NeruBar update control opens the System Updates panel. The panel also refreshes automatically after the initial desktop startup delay.

### 2. NeruOS project releases

NeruOS itself needs a separate release channel. It does not exist yet.

Planned design:
- Publish signed NeruOS version metadata with every stable release.
- Host NeruOS packages in a dedicated pacman repository.
- Sign repository databases and packages with a NeruOS project signing key.
- Let the update service compare the installed NeruOS version with the latest stable release.
- Show release notes, compatibility warnings, and available version information before applying an update.
- Offer a user-confirmed upgrade action rather than silently replacing the desktop shell.
- Keep a rollback / recovery path for failed updates.

The project release check must not treat an ordinary upstream Arch package update as a NeruOS release.

## Current VM Alpha limitation

The first VM Alpha is a live ISO. Its writable changes are temporary and are lost when the VM shuts down. checkupdates can report repository updates for the live session, but it cannot make those changes persistent across reboots.

There is no NeruOS pacman repository, signed project release feed, persistent installer, or automatic NeruOS updater in this alpha.

## Proposed future upgrade flow

1. NeruOS checks the signed release metadata.
2. The user sees the installed version, available version, and release notes.
3. NeruOS downloads signed packages from the project repository.
4. The package manager verifies signatures and dependencies.
5. The user confirms the upgrade.
6. The system applies it in a controlled transaction.
7. The system verifies the new shell and keeps a recoverable previous version.

A future immutable or snapshot-based base may provide stronger rollback, but the implementation strategy must be chosen and tested before stable releases.

## Security requirements

- Never run downloaded update scripts directly.
- Never disable package signature verification to make updates succeed.
- Keep the signing key separate from the public source repository.
- Do not require a root-running UI process.
- Do not silently apply major system upgrades.
- Document downgrade compatibility and recovery procedures.
