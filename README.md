# Bespoke

*Bespoke* is a simple helper script to configure a basic [Fedora Workstation](https://fedoraproject.org/workstation/) ([40](https://download.fedoraproject.org/pub/fedora/linux/releases/40/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-40-1.14.iso) or [41](https://download.fedoraproject.org/pub/fedora/linux/releases/41/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-41-1.4.iso)) installation post-install.

## About the Script

I wrote this as a quick and easy way to make *Fedora Workstation* or *Fedora Silverblue* setup for my own use quickly and easily.  The script will ask questions about which applications or packages to install, but it's much more trimmed down then using `dnf` groups.  For the Atomic users, I layer a number of packages into `rpm-ostree` to help the immutable distribution behave like the standard desktop.

## Why not ... (insert other option here)?

- Short answer - because it works and it's "old habit" for me.
- Long answer - because I don't want to get into making something like an Ansible playbook for simple setups, especially when I'm just playing with a hardware repair or refurbishing an old PC.

## How to use this script

- Clone the repository using the command `git clone https://github.com/seangalie/bespoke ~/.bespoke`
- Switch into the cloned directory using `cd ~/.bespoke/`
- Remember to make the script executable with `chmod +x bespoke.sh`
- Run the script `./bespoke.sh`

## Using Debian?

This script has a Debian-oriented version called [Bender](https://github.com/seangalie/bender) for Debian 12 installations.

## License

*Bespoke* is released under the [MIT License](https://opensource.org/licenses/MIT).
