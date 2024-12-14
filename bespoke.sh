#!/bin/bash

# -----------------------------------------------
#                     BESPOKE
# Customizing Fedora Linux or Atomic Fedora Spins
# -----------------------------------------------
#     Sean Galie - https://www.seangalie.com/
# -----------------------------------------------

# bespoke-install updates Fedora and installs common packages
bespoke-install() {
    echo -e  "\nUpdating your repositories and default packages...\n"
    if [ "$ATOMICFEDORA" = true ]; then
        sudo rpm-ostree status
        sudo rpm-ostree upgrade --check
        sudo rpm-ostree upgrade
    elif [ "$ATOMICFEDORA" = false ]; then
        sudo dnf clean all
        sudo dnf update
        sudo dnf upgrade --refresh
        sudo dnf autoremove -y
        sudo dnf group upgrade core
    else
        echo -e "\nERROR at bespoke-install - Updating repositories and default packages"
        echo -e "Script was not sure if this installation is Atomic... script stopped.\n"
        exit 1
    fi
    echo -e "\nUpdating your firmware...\n"
    sudo fwupdmgr get-devices
    sudo fwupdmgr refresh --force
    sudo fwupdmgr get-updates
    sudo fwupdmgr update -y
    echo -e "\Installing RPM Fusion and useful base packages...\n"
    if [ "$ATOMICFEDORA" = true ]; then
        sudo rpm-ostree install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
        sudo rpm-ostree update --uninstall $(rpm -q rpmfusion-free-release) --uninstall $(rpm -q rpmfusion-nonfree-release) --install rpmfusion-free-release --install rpmfusion-nonfree-release
        sudo rpm-ostree install -y distrobox stacer rclone lm_sensors unzip p7zip p7zip-plugins unrar timeshift ffmpegthumbnailer gnome-tweak-tool adw-gtk3-theme heif-pixbuf-loader libheif-freeworld libheif-tools pipewire-codec-aptx fastfetch make automake gcc gcc-c++ kernel-devel bwm-ng curl git htop iftop iotop nano net-tools redhat-rpm-config ruby ruby-devel sysbench sysstat util-linux-user vnstat wget zsh libavcodec-freeworld grubby julietaula-montserrat-fonts
        sudo rpm-ostree install -y 'google-roboto*' 'mozilla-fira*' fira-code-fonts fontawesome-fonts rsms-inter-fonts julietaula-montserrat-fonts aajohan-comfortaa-fonts adobe-source-sans-pro-fonts astigmatic-grand-hotel-fonts campivisivi-titillium-fonts lato-fonts open-sans-fonts overpass-fonts redhat-display-fonts redhat-text-fonts typetype-molot-fonts
    else
        sudo rpm -Uvh http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
        sudo rpm -Uvh http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
        sudo dnf install -y distrobox stacer rclone lm_sensors unzip p7zip p7zip-plugins unrar timeshift ffmpegthumbnailer gnome-tweak-tool adw-gtk3-theme heif-pixbuf-loader libheif-freeworld libheif-tools pipewire-codec-aptx fastfetch make automake gcc gcc-c++ kernel-devel bwm-ng curl git htop iftop iotop nano net-tools redhat-rpm-config ruby ruby-devel sysbench sysstat util-linux-user vnstat wget zsh libavcodec-freeworld grubby julietaula-montserrat-fonts
        sudo dnf install -y 'google-roboto*' 'mozilla-fira*' fira-code-fonts fontawesome-fonts rsms-inter-fonts julietaula-montserrat-fonts aajohan-comfortaa-fonts adobe-source-sans-pro-fonts astigmatic-grand-hotel-fonts campivisivi-titillium-fonts lato-fonts open-sans-fonts overpass-fonts redhat-display-fonts redhat-text-fonts typetype-molot-fonts
        sudo dnf copr enable kwizart/fedy
        sudo dnf install -y fedy
    fi
    echo -e "\Adding some kernel arguments...\n"
    if [ "$ATOMICFEDORA" = true ]; then
        sudo rpm-ostree kargs --append=mem_sleep_default=s2idle
        if [ "$DISABLEMITIGATIONS" = true ]; then
            sudo rpm-ostree kargs --append=mitigations=off
        fi
    else
        sudo grubby --update-kernel=ALL --args="mem_sleep_default=s2idle"
        if [ "$DISABLEMITIGATIONS" = true ]; then
            sudo grubby --update-kernel=ALL --args="mitigations=off"
        fi
    fi
    echo -e "\nConfiguring GPU drivers and other hardware...\n"
    if [ "$INTELGPU" = true ]; then
        echo -e "\nConfiguring Intel drivers...\n"
        if [ "$ATOMICFEDORA" = true ]; then
            rpm-ostree override remove libva-intel-media-driver --install intel-media-driver
        else
            sudo dnf swap libva-intel-media-driver intel-media-driver --allowerasing
        fi
    fi
    if [ "$AMDGPU" = true ]; then
        echo -e "\nConfiguring AMD drivers...\n"
        if [ "$ATOMICFEDORA" = true ]; then
            rpm-ostree override remove mesa-va-drivers --install mesa-va-drivers-freeworld
            rpm-ostree override remove mesa-vdpau-drivers --install mesa-vdpau-drivers-freeworld
        else
            sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld
            sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
        fi
    fi
    if [ "$NVIDIAGPU" = true ]; then
        echo -e "\nConfiguring Nvidia drivers...\n"
        if [ "$ATOMICFEDORA" = true ]; then
            sudo rpm-ostree install --apply-live akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-cuda
            sudo rpm-ostree kargs --append=rd.driver.blacklist=nouveau --append=modprobe.blacklist=nouveau --append=nvidia-drm.modeset=1
        else
            sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-cuda
            echo -e "\nBuilding Graphics Driver Support (waiting 5 minutes)...\n"
            sleep 300
            echo -e "\nGraphics Driver Support has been built.\n"
            modinfo -F version nvidia
            sudo grubby --update-kernel=ALL --args="nvidia-drm.modeset=1"
        fi
    fi
    echo -e "\nUpdating Flatpak applications and Flathub repositories...\n"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak remote-modify --enable flathub
    flatpak install -y --reinstall flathub $(flatpak list --app-runtime=org.fedoraproject.Platform --columns=application | tail -n +1 )
    flatpak remote-add --user flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
    flatpak update
    flatpak install -y flathub com.mattjakeman.ExtensionManager
    echo -e "\nInstalling Google Chrome and core GNOME applications...\n"
    if [ "$ATOMICFEDORA" = true ]; then
        flatpak install -y flathub com.google.Chrome org.gnome.DejaDup
        sudo rpm-ostree install gnome-tweaks gnome-extensions-app flatseal
    else
        sudo dnf install -y fedora-workstation-repositories
        sudo dnf config-manager --set-enabled google-chrome
        sudo dnf install -y google-chrome-stable
        sudo dnf install -y gnome-tweaks gnome-extensions-app flatseal deja-dup
    fi
}

# Add additional application groups and packages based on interactive questions
bespoke-appinstalls() {
    if [ "$INSTALLOFFICE" = true ]; then
        echo -e "\nInstalling office and productivity applications...\n"
        flatpak install -y flathub eu.betterbird.Betterbird us.zoom.Zoom com.discordapp.Discord com.slack.Slack org.gnome.World.Iotas md.obsidian.Obsidian
        if [ "$ATOMICFEDORA" = true ]; then
            flatpak install -y flathub org.libreoffice.LibreOffice org.gnome.Evolution org.gnome.Geary org.gnucash.GnuCash org.kde.okular com.calibre_ebook.calibre
        else
            sudo dnf install -y libreoffice geary evolution gnucash okular calibre
        fi
    fi
    if [ "$INSTALLMEDIA" = true ]; then
        echo -e "\nInstalling personal multimedia applications...\n"
        flatpak install -y flathub io.bassi.Amberol com.github.iwalton3.jellyfin-media-player org.nickvision.tubeconverter
        if [ "$ATOMICFEDORA" = true ]; then
            flatpak install -y flathub io.github.celluloid_player.Celluloid org.videolan.VLC com.github.johnfactotum.Foliate org.gnome.Rhythmbox3 org.gnome.Totem
        else
            sudo dnf install -y celluloid vlc yt-dlp foliate rhythmbox totem
        fi
    fi
    if [ "$INSTALLCREATIVE" = true ]; then
        echo -e "\nInstalling creative design applications...\n"
        flatpak install -y flathub io.github.nate_xyz.Conjure io.gitlab.theevilskeleton.Upscaler
        if [ "$ATOMICFEDORA" = true ]; then
            flatpak install -y flathub org.gimp.GIMP org.inkscape.Inkscape org.kde.krita org.darktable.Darktable net.scribus.Scribus org.fontforge.FontForge org.gnome.Shotwell org.entangle_photo.Manager nl.hjdskes.gcolor3 net.sourceforge.Hugin com.github.jeromerobert.pdfarranger
        else
            sudo dnf install -y darktable gimp inkscape krita scribus fontforge shotwell entangle gcolor3 hugin pdfarranger
        fi
    fi
    if [ "$INSTALLVIDEO" = true ]; then
        echo -e "\nInstalling 3D and video production applications...\n"
        if [ "$ATOMICFEDORA" = true ]; then
            flatpak install -y flathub org.blender.Blender org.kde.kdenlive com.obsproject.Studio org.openshot.OpenShot org.pitivi.Pitivi org.synfig.SynfigStudio
        else
            sudo dnf install -y blender kdenlive obs-studio openshot pitivi synfigstudio
        fi
    fi
    if [ "$INSTALLAUDIO" = true ]; then
        echo -e "\nInstalling audio production applications...\n"
        flatpak install -y flathub org.tenacityaudio.Tenacity
        if [ "$ATOMICFEDORA" = true ]; then
            flatpak install -y flathub org.ardour.Ardour org.musescore.MuseScore org.soundconverter.SoundConverter org.denemo.Denemo
        else
            sudo dnf install -y ardour8 musescore soundconverter gnome-sound-recorder denemo
        fi
    fi
    if [ "$INSTALLDEVELOPMENT" = true ]; then
        echo -e "\nInstalling coding tools and developer applications...\n"
        flatpak install -y flathub com.google.AndroidStudio dev.pulsar_edit.Pulsar
        if [ "$ATOMICFEDORA" = true ]; then
            flatpak install -y flathub com.visualstudio.code org.gnome.meld org.gnome.gitlab.somas.Apostrophe
        else
            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
            sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo' && \
            sudo dnf check-update && \
            sudo dnf install -y code meld apostrophe
        fi
    fi
    if [ "$INSTALLGIS" = true ]; then
        echo -e "\nInstalling GIS and weather data applications...\n"
        if [ "$ATOMICFEDORA" = true ]; then
            flatpak install -y flathub org.qgis.qgis com.gitlab.bitseater.meteo
        else
            sudo dnf install -y qgis meteo
        fi
    fi
    if [ "$INSTALLLLM" = true ]; then
        echo -e "\nInstalling LLM front-end applications...\n"
        flatpak install -y flathub com.jeffser.Alpaca io.gpt4all.gpt4all
    fi
    if [ "$INSTALLGAMING" = true ]; then
        echo -e "\nInstalling gaming platforms and packages...\n"
        if [ "$ATOMICFEDORA" = true ]; then
            flatpak install -Y flathub com.valvesoftware.Steam io.github.sharkwouter.Minigalaxy net.lutris.Lutris org.winehq.Wine com.usebottles.bottles
        else
            sudo dnf install -y steam minigalaxy lutris wine bottles gamemode gamescope
        fi
    fi
    if [ "$INSTALLSHARING" = true ]; then
        echo -e "\nInstalling file sharing platform packages...\n"
        if [ "$ATOMICFEDORA" = true ]; then
            rpm-ostree install https://www.dropbox.com/download?dl=packages/fedora/nautilus-dropbox-2024.04.17-1.fc39.x86_64.rpm
            flatpak install -y flathub org.sparkleshare.SparkleShare
        else
            sudo dnf install -y https://www.dropbox.com/download?dl=packages/fedora/nautilus-dropbox-2024.04.17-1.fc39.x86_64.rpm
            sudo dnf install -y sparkleshare
        fi
    fi
    if [ "$INSTALLTAILSCALE" = true ]; then
        echo -e "\nInstalling Tailscale...\n"
        if [ "$ATOMICFEDORA" = true ]; then
            sudo curl -s https://pkgs.tailscale.com/stable/fedora/tailscale.repo -o /etc/yum.repos.d/tailscale.repo > /dev/null
            sudo wget https://pkgs.tailscale.com/stable/fedora/repo.gpg -O /etc/pki/rpm-gpg/tailscale.gpg
            sudo sed -i 's\"https://pkgs.tailscale.com/stable/fedora/repo.gpg"\file:///etc/pki/rpm-gpg/tailscale.gpg\' /etc/yum.repos.d/tailscale.repo
            rpm-ostree install --apply-live tailscale
            sudo systemctl enable --now tailscaled
            sudo tailscale up
            sudo tailscale set --operator=$USER
        else
            sudo dnf config-manager --add-repo https://pkgs.tailscale.com/stable/fedora/tailscale.repo
            sudo dnf install -y tailscale
            sudo systemctl enable --now tailscaled
            sudo tailscale up
            sudo tailscale set --operator=$USER
        fi
    fi
}

# Start the script with a nice ASCII logo and an 'are you sure?' prompt
bespoke-start() {
    ASCIILOGO='
        ++----------------------------------------------++
        ++----------------------------------------------++
        ||                                              ||
        ||    ___   ____  __   ___   ___   _     ____   ||
        ||   | |_) | |_  ( (` | |_) / / \ | |_/ | |_    ||
        ||   |_|_) |_|__ _)_) |_|   \_\_/ |_| \ |_|__   ||
        ||                                              ||
        ||                                              ||
        ++----------------------------------------------++
        ++----------------------------------------------++
        '
    sudo clear
    echo -e "$ASCIILOGO"
    echo -e "The BESPOKE script is for a fresh Fedora Workstation 40 or 41 installs only!"
    echo -e "\nIf you don't want to continue, press Control-C now to exit the script."
    echo -e "\nA few questions before we begin - this will help the script customize your installation."
}

bespoke-options() {
    echo -e "\nThere are built-in fixes for the CPU Meltdown/Sceptre vulnerabilities that are\nbuilt-into the Linux kernel. If you do not believe you need these fixes, which\ncan negatively affect performance - this script can disable those mitagations.\n"
    echo -e "\nShould mitigations for Intel 5th-9th Gen CPUs be disabled?"
    read -n 1 -p "If you are unsure of what this means, choose N for no. (y/n) " answer
    case ${answer:0:1} in
        y|Y )
            DISABLEMITIGATIONS=true
        ;;
        * )
            DISABLEMITIGATIONS=false
        ;;
    esac

    echo -e "\nBy default, Fedora includes a free/open-source version for Intel iGPUs that can\nbe replaced with a higher performance, less-open driver.  It is recommended to\ninstall this package to increase performance for 5th gen platforms and later.\n"
    echo "\nIs this device an Intel 5th Gen or later with integrated Intel graphics?"
    read -n 1 -p "Choose Y (Yes) if you have a dedicated Intel GPU as well. (y/n) " answer
    case ${answer:0:1} in
        y|Y )
            INTELGPU=true
        ;;
        * )
            INTELGPU=false
        ;;
    esac

    echo -e "\nBy default, Fedora includes a free/open-source driver for AMD GPUs and iGPUs\nthat can be replaced with an updated package that may offer some increases in\nperformance.  It is recommended if you have AMD hardware to install these packages.\n"
    read -n 1 -p "\nDo you have integrated AMD graphics or an AMD GPU? (y/n) " answer
    case ${answer:0:1} in
        y|Y )
            AMDGPU=true
        ;;
        * )
            AMDGPU=false
        ;;
    esac

    echo -e "\nBe default, Fedora includes only free/open-source software which excludes some\nproprietary packages released by Nvidia to enable their hardware or the best\nfeatures of their hardware.  It is recommended if you have Nvidia hardware to\ninstall these packages.  Additional setup prompts may appear during installation.\n"
    read -n 1 -p "\nDo you have integrated Nvidia graphics or a Nvidia GPU? (y/n) " answer
    case ${answer:0:1} in
        y|Y )
            NVIDIAGPU=true
        ;;
        * )
            NVIDIAGPU=false
        ;;
    esac

    echo -e "\nThis script includes prompts to install some common, popular packages from either\nthe Fedora/RPM Fusion repositories or Flathub - this is different than some of\nthe default behavior from tools like dnf groups to minimize extra packages.\n"
    read -n 1 -p "\nDo you want to choose apps to install? (y/n) " answer
    case ${answer:0:1} in
        y|Y )
            INSTALLAPPS=true
        ;;
        * )
            INSTALLAPPS=false
        ;;
    esac

    echo "\nDo you want to install file sharing platform packages?"
    read -n 1 -p "Dropbox, Sparkleshare, and more - (y/n) " answer
    case ${answer:0:1} in
        y|Y )
            INSTALLSHARING=true
        ;;
        * )
            INSTALLSHARING=false
        ;;
    esac

    echo -e "\nThis script includes the abiltiy to install the WireGuard-based networking suite\nfrom Tailscale that integrates with both the Linux shell and your desktop\nenvironment.  You will be prompted during the script to login and add the node.\n"
    read -n 1 -p "\nDo you want to install Tailscale? (y/n) " answer
    case ${answer:0:1} in
        y|Y )
            INSTALLTAILSCALE=true
        ;;
        * )
            INSTALLTAILSCALE=false
        ;;
    esac
}

bespoke-appoptions() {
    if [ "$INSTALLAPPS" = true ]; then
        echo -e "\nDo you want to install office and productivity applications?"
        read -n 1 -p "LibreOffice, Email, GnuCash, Okular, and more - (y/n) " answer
        case ${answer:0:1} in
            y|Y )
                INSTALLOFFICE=true
            ;;
            * )
                INSTALLOFFICE=false
            ;;
        esac

        echo -e "\nDo you want to install personal multimedia applications?"
        read -n 1 -p "Amberol, Calibre, Celluloid, VLC, and more - (y/n) " answer
        case ${answer:0:1} in
            y|Y )
                INSTALLMEDIA=true
            ;;
            * )
                INSTALLMEDIA=false
            ;;
        esac

        echo -e "\nDo you want to install creative design applications?"
        read -n 1 -p "Darktable, GIMP, Inkscape, Krita, and more - (y/n) " answer
        case ${answer:0:1} in
            y|Y )
                INSTALLCREATIVE=true
            ;;
            * )
                INSTALLCREATIVE=false
            ;;
        esac

        echo -e "\nDo you want to install 3D and video production applications?"
        read -n 1 -p "Blender, Kdenlive, OBS, OpenShot, Pitivi, and more - (y/n) " answer
        case ${answer:0:1} in
            y|Y )
                INSTALLVIDEO=true
            ;;
            * )
                INSTALLVIDEO=false
            ;;
        esac

        echo -e "\nDo you want to install audio production applications?"
        read -n 1 -p "Ardour, MuseScore, Tenacity, and more - (y/n) " answer
        case ${answer:0:1} in
            y|Y )
                INSTALLAUDIO=true
            ;;
            * )
                INSTALLAUDIO=false
            ;;
        esac

        echo -e "\nDo you want to install coding tools and developer applications?"
        read -n 1 -p "Android Studio, Pulsar, Obsidian, and Visual Studio Code (y/n) " answer
        case ${answer:0:1} in
            y|Y )
                INSTALLDEVELOPMENT=true
            ;;
            * )
                INSTALLDEVELOPMENT=false
            ;;
        esac

        echo -e "\nDo you want to install GIS and weather data applications?"
        read -n 1 -p "Meteo and QGIS (y/n) " answer
        case ${answer:0:1} in
            y|Y )
                INSTALLGIS=true
            ;;
            * )
                INSTALLGIS=false
            ;;
        esac

        echo -e "\nDo you want to install LLM front-end applications?"
        read -n 1 -p "Alpaca and GPT4All (y/n) " answer
        case ${answer:0:1} in
            y|Y )
                INSTALLLLM=true
            ;;
            * )
                INSTALLLLM=false
            ;;
        esac

        echo -e "\nDo you want to install gaming platforms and packages?"
        read -n 1 -p "Steam, Lutris, Wine, Bottles, and more (y/n) " answer
        case ${answer:0:1} in
            y|Y )
                INSTALLGAMING=true
            ;;
            * )
                INSTALLGAMING=false
            ;;
        esac
    else
        INSTALLOFFICE=false
        INSTALLMEDIA=false
        INSTALLCREATIVE=false
        INSTALLVIDEO=false
        INSTALLDAVINCI=false
        INSTALLAUDIO=false
        INSTALLDEVELOPMENT=false
        INSTALLGIS=false
        INSTALLLLM=false
        INSTALLGAMING=false
    fi
}

bespoke-atomic() {
    if [ ! -f /run/ostree-booted ]; then
        ATOMICFEDORA=false
    else
        ATOMICFEDORA=true
    fi
}

bespoke-distro() {
    echo -e "\nChecking if you are running Fedora...\n"
    if [ ! -f /etc/os-release ]; then
        echo -e "\nERROR at bespoke-distro - Checking if you are running Fedora"
        echo -e "Script was not able to determine distribution or read /etc/os-release... script stopped.\n"
        exit 1
    fi
    . /etc/os-release
    if [ "$ID" = "fedora" ]; then
        bespoke-version;
    else
        echo -e "\nThis script is not compatible with your distribution."
        echo -e "\nYour computer is is currently running: $ID $VERSION_ID"
        echo -e "\nThis script is for Fedora 40, 41, or higher - installation stopped."
        exit 1
    fi
}

bespoke-version() {
    echo "\nChecking your version of Fedora...\n"
    . /etc/os-release
    if [ "$VERSION_ID" -ge "40" ]; then
        bespoke-atomic;
    else
        echo -e "\nThis script is not compatible with your distribution version."
        echo -e "\nYour computer is is currently running: $ID $VERSION_ID"
        echo -e "\nThis script is for Fedora 40, 41, or higher - installation stopped."
        exit 1
    fi
}

RUNNING_GNOME=$([[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]] && echo true || echo false)
if $RUNNING_GNOME; then
    gsettings set org.gnome.desktop.screensaver lock-enabled false
    gsettings set org.gnome.desktop.session idle-delay 0
    gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
    gsettings set org.gnome.desktop.interface show-battery-percentage true
    bespoke-start
    bespoke-distro
    bespoke-options
    bespoke-appoptions
    bespoke-install
    bespoke-appinstalls
    gsettings set org.gnome.desktop.screensaver lock-enabled true
    gsettings set org.gnome.desktop.session idle-delay 300
else
    bespoke-start
    bespoke-distro
    bespoke-options
    bespoke-appoptions
    bespoke-install
    bespoke-appinstalls
fi

echo -e "\nThe script has now completed and it is recommended to reboot the device."
read -n 1 -p "Do you want to restart now? (y/n) " answer
case ${answer:0:1} in
    y|Y )
        sudo systemctl reboot
    ;;
    * )
        exit 0
    ;;
esac
