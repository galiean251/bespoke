# Bespoke

*Bespoke* is a simple helper script to configure a basic [Fedora Workstation](https://fedoraproject.org/workstation/) ([40](https://download.fedoraproject.org/pub/fedora/linux/releases/40/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-40-1.14.iso) or [41](https://download.fedoraproject.org/pub/fedora/linux/releases/41/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-41-1.4.iso)) installation post-install.

## About the Script

This script is a quick, easy, and lazy way to make *Fedora Workstation* or *Fedora Silverblue* a little more the way I like it - not a complete remodel like Ultramarine, Nobara, or uBlue... just a little bit of spice on top of the vanilla installation.  The script will ask questions about which applications or packages to install, but it's much more trimmed down then using `dnf` groups.  For the Atomic users, I layer a number of packages into `rpm-ostree` to help the immutable distribution behave like the standard desktop without the need for containers.

## Why not ... (insert other option here)?

- Short answer: because it works.
- Long answer: because making something like a playbook for simple setups, especially when I'm just playing around, seems like overkill.

## How I use this script

- First, clone the repository using the command `git clone https://github.com/seangalie/bespoke ~/.bespoke`
- Switch into the cloned directory using `cd ~/.bespoke/`
- Remember to make the script executable with `chmod +x bespoke.sh`
- Run the script `./bespoke.sh`
- When I'm done, I can deleted the `~/.bespoke` directory

## What does the script do?

- Updates Fedora (*Workstation* or *Silverblue*)
- Runs the Linux Firmware Update `fwupdmgr`
- Installs useful base packages including CLI Tools, Timeshift, and more (and layering them for *Silverblue* installations into `rpm-ostree`)
    - Installs font library packages from the distribution that aren't normally included with default installations
    - Replaces some free or open source multimedia packages with upgraded or closed-source versions
    - Installs `dnf5` for Fedora 40 installations
- Configures some optional Kernel Arguments
    - Offers to disable mitigations *(Intel 5th-9th Gen CPUs)*
- Configures various GPU packages
    - Offers to install `intel-media-driver` for 5th Gen or newer iGPUs (or supported dedicated Intel GPUs)
    - Offers to install upgraded AMD iGPU or dedicated GPU drivers
    - Offers to install and configure Nvidia drivers, builds the kernel support, and adds the required boot arguments
- Installs `flathub` and `flathub-beta` to replace the `fedora` flatpak repositories
- Adds the `topgrade` third party update tool and the `fedy` customization helper
- Installs Google Chrome and LocalSend
- Installs the GNOME Extension Manager and GNOME Tweaks *(if **GNOME** is the current environment)*
- Installs the 'kate' Advanced Text Editor *(if **KDE** is the current environment)*
- Offers to install batches of Applications or Useful Tools
    - Office and Messaging (LibreOffice, Geary, Evolution, Betterbird, Discord, Slack, and Zoom)
    - Creative Design (GIMP, Inkscape, Krita, Darktable, Scribus, FontForge, Shotwell, GColor, Hugin, PDF Arranger, Conjure, and Upscaler)
    - 3D and Video Production (Blender, Kdenlive, OBS Studio, and OpenShot)
    - Audio Production (Ardour, Tenacity, Sound Converter, and Sound Recorder)
    - Personal Multimedia (Jellyfin Player, Parabolic (YT-DLP Frontend), Celluloid, Foliate, and VLC)
    - Development and Coding Tools (VS Code, Android Studio, Apostrophe, Meld, Pulsar, and GitHub Desktop)
    - GIS and Weather (Meteo and QGIS)
    - LLM Front-Ends (Alpaca and GPT4All)
    - Gaming Platforms (Steam, MiniGalaxy, Lutris, Wine, and Bottles alongside the Gamemode and Gamescope packages)
    - Container Management (Podman, Podman Desktop, Pods, and Docker Utilities)
    - Dropbox (with the Nautilus/Files Integration)
    - Tailscale (and enabling it during setup)
- Option to install DisplayLink drivers from the `displaylink-rpm` project on [GitHub](https://github.com/displaylink-rpm/displaylink-rpm)
- Installs the [Dracula](https://draculatheme.com/) theme for GNOME Installations
- Installs the [Starship](https://starship.rs/) prompt customization tool and enables the [No Nerd Fonts](https://starship.rs/presets/no-nerd-font#no-nerd-fonts-preset) preset
	- **Note:** *I only did this to avoid loading up installations with massive downloads from [Nerd Fonts](https://www.nerdfonts.com/), but I'd encourage you add your favorite and then use a preset such as [Nerd Font Symbols](https://starship.rs/presets/nerd-font) or [Tokyo Night](https://starship.rs/presets/tokyo-night)*

## Using Debian?

This script has a Debian-oriented version called [Bender](https://github.com/seangalie/bender) for Debian 12 installations.

## License

*Bespoke* is released under the [MIT License](https://opensource.org/licenses/MIT).