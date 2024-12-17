#!/bin/bash

# -----------------------------------------------
#                     BESPOKE
# Customizing Fedora Linux or Atomic Fedora Spins
# -----------------------------------------------
#     Sean Galie - https://www.seangalie.com/
# -----------------------------------------------

# Updates Fedora and install basic packages
bespoke-install() {
    echo -e  "\n\n\033[1mUpdating your repositories and default packages...\033[0m\n"
    sleep 1
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
        echo -e "\n\033[34mERROR at bespoke-install\033[0m - Updating repositories and default packages"
        echo -e "Script was not sure if this installation is Atomic... \033[34mscript stopped.\033[0m\n"
        exit 1
    fi
    echo -e "\n\033[1mUpdating your firmware...\033[0m\n"
    sleep 1
    echo -e "\n\033[91;1mWARNING: DO NOT REBOOT IF YOU ARE PROMPTED TO AFTER THE FIRMWARE UPDATE RUNS IN THE NEXT STEP!\033[0m\n"
    sleep 5
    sudo fwupdmgr get-devices
    sudo fwupdmgr refresh --force
    sudo fwupdmgr get-updates
    sudo fwupdmgr update -y
    echo -e "\n\033[1mInstalling RPM Fusion and useful base packages...\033[0m\n"
    sleep 1
    if [ "$ATOMICFEDORA" = true ]; then
        sudo rpm-ostree install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
        sudo rpm-ostree update --uninstall $(rpm -q rpmfusion-free-release) --uninstall $(rpm -q rpmfusion-nonfree-release) --install rpmfusion-free-release --install rpmfusion-nonfree-release
        sudo rpm-ostree install -y distrobox stacer rclone lm_sensors p7zip p7zip-plugins unrar timeshift ffmpegthumbnailer gnome-tweak-tool adw-gtk3-theme heif-pixbuf-loader libheif-freeworld libheif-tools pipewire-codec-aptx fastfetch make automake gcc gcc-c++ kernel-devel bwm-ng curl git htop iftop iotop nano net-tools redhat-rpm-config ruby ruby-devel sysbench sysstat util-linux-user vnstat wget zsh libavcodec-freeworld grubby julietaula-montserrat-fonts
        sudo rpm-ostree install -y pwgen 'google-roboto*' 'mozilla-fira*' fira-code-fonts fontawesome-fonts rsms-inter-fonts julietaula-montserrat-fonts aajohan-comfortaa-fonts adobe-source-sans-pro-fonts astigmatic-grand-hotel-fonts campivisivi-titillium-fonts lato-fonts open-sans-fonts overpass-fonts redhat-display-fonts redhat-text-fonts typetype-molot-fonts
    else
        sudo rpm -Uvh http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
        sudo rpm -Uvh http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
        sudo dnf install -y distrobox stacer rclone lm_sensors unzip p7zip p7zip-plugins unrar timeshift ffmpegthumbnailer gnome-tweak-tool adw-gtk3-theme heif-pixbuf-loader libheif-freeworld libheif-tools pipewire-codec-aptx fastfetch make automake gcc gcc-c++ kernel-devel bwm-ng curl git htop iftop iotop nano net-tools redhat-rpm-config ruby ruby-devel sysbench sysstat util-linux-user vnstat wget zsh libavcodec-freeworld grubby julietaula-montserrat-fonts
        sudo dnf install -y pwgen gpg 'google-roboto*' 'mozilla-fira*' fira-code-fonts fontawesome-fonts rsms-inter-fonts julietaula-montserrat-fonts aajohan-comfortaa-fonts adobe-source-sans-pro-fonts astigmatic-grand-hotel-fonts campivisivi-titillium-fonts lato-fonts open-sans-fonts overpass-fonts redhat-display-fonts redhat-text-fonts typetype-molot-fonts
        if [ "$VERSION_ID" = "40" ]; then
            sudo dnf install -y dnf5 dnf5-plugins
            sudo dnf group upgrade -y 'core' 'multimedia' 'sound-and-video' --setopt='install_weak_deps=False' --exclude='PackageKit-gstreamer-plugin' --allowerasing && sync
            sudo dnf swap 'ffmpeg-free' 'ffmpeg' --allowerasing
            sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg
            sudo dnf install -y lame\* --exclude=lame-devel
            sudo dnf group upgrade -y --with-optional Multimedia
            sudo dnf install -y ffmpeg ffmpeg-libs libva libva-utils
            sudo dnf config-manager --set-enabled fedora-cisco-openh264
            sudo dnf install -y openh264 gstreamer1-plugin-openh264 mozilla-openh264
        fi
    fi
    echo -e "\n\033[1mAdding some kernel arguments...\033[0m\n"
    sleep 1
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
    echo -e "\n\033[1mConfiguring GPU drivers and other hardware...\033[0m\n"
    sleep 1
    if [ "$INTELGPU" = true ]; then
        echo -e "\n\033[3mConfiguring Intel drivers...\033[0m\n"
        sleep 1
        if [ "$ATOMICFEDORA" = true ]; then
            rpm-ostree override remove libva-intel-media-driver --install intel-media-driver
        else
            sudo dnf swap libva-intel-media-driver intel-media-driver --allowerasing
        fi
    fi
    if [ "$AMDGPU" = true ]; then
        echo -e "\n\033[3mConfiguring AMD drivers...\033[0m\n"
        sleep 1
        if [ "$ATOMICFEDORA" = true ]; then
            rpm-ostree override remove mesa-va-drivers --install mesa-va-drivers-freeworld
            rpm-ostree override remove mesa-vdpau-drivers --install mesa-vdpau-drivers-freeworld
        else
            sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld
            sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
        fi
    fi
    if [ "$NVIDIAGPU" = true ]; then
        echo -e "\n\033[3mConfiguring Nvidia drivers...\033[0m\n"
        sleep 1
        if [ "$ATOMICFEDORA" = true ]; then
            sudo rpm-ostree install --apply-live akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-cuda
            sudo rpm-ostree kargs --append=rd.driver.blacklist=nouveau --append=modprobe.blacklist=nouveau --append=nvidia-drm.modeset=1
        else
            sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-cuda
            echo -e "\n\033[1;3mBuilding Graphics Driver Support (this takes 5 minutes)...\033[0m\n"
            sleep 300
            echo -e "\n\033[1;3mGraphics Driver Support has been built.\033[0m\n"
            modinfo -F version nvidia
            sudo grubby --update-kernel=ALL --args="nvidia-drm.modeset=1"
        fi
    fi
    echo -e "\n\033[1mUpdating Flatpak applications and Flathub repositories...\033[0m\n"
    sleep 1
    echo -e "\nNote: You may be prompted for your password by your desktop environment.\n"
    sleep 3
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak remote-modify --enable flathub
    flatpak install -y --reinstall flathub $(flatpak list --app-runtime=org.fedoraproject.Platform --columns=application | tail -n +1 )
    sleep 1
    flatpak remote-add --user flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
    flatpak update
    flatpak install -y flathub com.mattjakeman.ExtensionManager org.localsend.localsend_app
    echo -e "\n\033[1mInstalling Google Chrome and core GNOME applications...\033[0m\n"
    sleep 1
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
        echo -e "\n\033[1mInstalling office and productivity applications...\033[0m\n"
        sleep 1
        flatpak install -y flathub eu.betterbird.Betterbird us.zoom.Zoom com.slack.Slack org.gnome.World.Iotas md.obsidian.Obsidian
        if [ "$ATOMICFEDORA" = true ]; then
            flatpak install -y flathub org.libreoffice.LibreOffice org.gnome.Evolution org.gnome.Geary org.gnucash.GnuCash org.kde.okular com.calibre_ebook.calibre com.discordapp.Discord
        else
            sudo dnf install -y libreoffice geary evolution gnucash okular calibre discord
        fi
    fi
    if [ "$INSTALLMEDIA" = true ]; then
        echo -e "\n\033[1mInstalling personal multimedia applications...\033[0m\n"
        sleep 1
        flatpak install -y flathub io.bassi.Amberol com.github.iwalton3.jellyfin-media-player org.nickvision.tubeconverter
        if [ "$ATOMICFEDORA" = true ]; then
            flatpak install -y flathub io.github.celluloid_player.Celluloid org.videolan.VLC com.github.johnfactotum.Foliate org.gnome.Rhythmbox3 org.gnome.Totem
        else
            sudo dnf install -y celluloid vlc yt-dlp foliate rhythmbox totem
        fi
    fi
    if [ "$INSTALLCREATIVE" = true ]; then
        echo -e "\n\033[1mInstalling creative design applications...\033[0m\n"
        sleep 1
        flatpak install -y flathub io.github.nate_xyz.Conjure io.gitlab.theevilskeleton.Upscaler
        if [ "$ATOMICFEDORA" = true ]; then
            flatpak install -y flathub org.gimp.GIMP org.inkscape.Inkscape org.kde.krita org.darktable.Darktable net.scribus.Scribus org.fontforge.FontForge org.gnome.Shotwell org.entangle_photo.Manager nl.hjdskes.gcolor3 net.sourceforge.Hugin com.github.jeromerobert.pdfarranger
        else
            sudo dnf install -y darktable gimp inkscape krita scribus fontforge shotwell entangle gcolor3 hugin pdfarranger
        fi
    fi
    if [ "$INSTALLVIDEO" = true ]; then
        echo -e "\n\033[1mInstalling 3D and video production applications...\033[0m\n"
        sleep 1
        if [ "$ATOMICFEDORA" = true ]; then
            flatpak install -y flathub org.blender.Blender org.kde.kdenlive com.obsproject.Studio org.openshot.OpenShot org.pitivi.Pitivi org.synfig.SynfigStudio
        else
            sudo dnf install -y blender kdenlive obs-studio openshot pitivi synfigstudio
        fi
    fi
    if [ "$INSTALLAUDIO" = true ]; then
        echo -e "\n\033[1mInstalling audio production applications...\033[0m\n"
        sleep 1
        flatpak install -y flathub org.tenacityaudio.Tenacity
        if [ "$ATOMICFEDORA" = true ]; then
            flatpak install -y flathub org.ardour.Ardour org.musescore.MuseScore org.soundconverter.SoundConverter org.denemo.Denemo
        else
            sudo dnf install -y ardour8 musescore soundconverter gnome-sound-recorder denemo
        fi
    fi
    if [ "$INSTALLDEVELOPMENT" = true ]; then
        echo -e "\n\033[1mInstalling coding tools and developer applications...\033[0m\n"
        sleep 1
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
        echo -e "\n\033[1mInstalling GIS and weather data applications...\033[0m\n"
        sleep 1
        if [ "$ATOMICFEDORA" = true ]; then
            flatpak install -y flathub org.qgis.qgis com.gitlab.bitseater.meteo
        else
            sudo dnf install -y qgis meteo
        fi
    fi
    if [ "$INSTALLLLM" = true ]; then
        echo -e "\n\033[1mInstalling LLM front-end applications...\033[0m\n"
        sleep 1
        flatpak install -y flathub io.gpt4all.gpt4all com.jeffser.Alpaca
    fi
    if [ "$INSTALLGAMING" = true ]; then
        echo -e "\n\033[1mInstalling gaming platforms and packages...\033[0m\n"
        sleep 1
        if [ "$ATOMICFEDORA" = true ]; then
            flatpak install -y flathub com.valvesoftware.Steam io.github.sharkwouter.Minigalaxy net.lutris.Lutris org.winehq.Wine com.usebottles.bottles
        else
            sudo dnf install -y steam minigalaxy lutris wine bottles gamemode gamescope
        fi
    fi
    if [ "$INSTALLSHARING" = true ]; then
        echo -e "\n\033[1mInstalling file sharing platform packages...\033[0m\n"
        sleep 1
        if [ "$ATOMICFEDORA" = true ]; then
            rpm-ostree install --apply-live dropbox nautilus-dropbox
            flatpak install -y flathub org.sparkleshare.SparkleShare
        else
            sudo dnf install -y dropbox nautilus-dropbox sparkleshare
        fi
    fi
    if [ "$INSTALLCONTAINER" = true ]; then
        echo -e "\n\033[1mInstalling container and image management packages...\033[0m\n"
        sleep 1
        if [ "$ATOMICFEDORA" = true ]; then
            rpm-ostree install podman-docker docker-compose
        else
            sudo dnf install -y podman toolbox podman-docker docker-compose
        fi
        flatpak install -y flathub io.podman_desktop.PodmanDesktop com.github.marhkb.Pods
    fi
    if [ "$INSTALLTAILSCALE" = true ]; then
        echo -e "\n\033[1mInstalling Tailscale...\033[0m\n"
        sleep 1
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

# Start the script with the script's nice ASCII logo and a confirmation prompt
bespoke-start() {
    ASCIILOGO='
        \033[93;1m++----------------------------------------------++\033[0m
        \033[93;1m+\033[33;1m+----------------------------------------------+\033[93;1m+\033[0m
        \033[93;1m|\033[33;1m|                                              |\033[93;1m|\033[0m
        \033[93;1m|\033[33;1m|   \033[96;1m ___   ____  __   ___   ___   _     ____\033[33;1m   |\033[93;1m|\033[0m
        \033[93;1m|\033[33;1m|   \033[96;1m| |_) | |_  ( (` | |_) / / \ | |_/ | |_ \033[33;1m   |\033[93;1m|\033[0m
        \033[93;1m|\033[33;1m|   \033[96;1m|_|_) |_|__ _)_) |_|   \_\_/ |_| \ |_|__\033[33;1m   |\033[93;1m|\033[0m
        \033[93;1m|\033[33;1m|                                              |\033[93;1m|\033[0m
        \033[93;1m|\033[33;1m|                                              |\033[93;1m|\033[0m
        \033[93;1m+\033[33;1m+----------------------------------------------+\033[93;1m+\033[0m
        \033[93;1m++----------------------------------------------++\033[0m
        '
    sudo clear
    echo -e "$ASCIILOGO"
    echo -e "\nThe BESPOKE script is for a fresh \033[94;1mFedora\033[0m Workstation \033[94;1m40\033[0m or \033[94;1m41\033[0m installs only!"
    echo -e "\nIf you don't want to continue, press \033[31mControl-C\033[0m now to \033[31mexit\033[0m the script."
    sleep 2
    echo -e "\n\nA few questions before we begin - this will help the script customize your installation.\n"
}

# Ask the important questions about hardware compatibility and needed drivers
bespoke-options() {
    echo -e "\n\n\nThere are built-in fixes for the CPU Meltdown/Sceptre vulnerabilities that are\nbuilt-into the Linux kernel. If you do not believe you need these fixes, which\ncan negatively affect performance - this script can disable those mitagations.\n"
    echo -e "\nShould mitigations for \033[95mIntel 5th-9th Gen CPUs\033[0m be disabled?"
    read -n 1 -p "If you are unsure of what this means, choose N for no. (y/n) " answer
    case ${answer:0:1} in
        y|Y )
            DISABLEMITIGATIONS=true
        ;;
        * )
            DISABLEMITIGATIONS=false
        ;;
    esac

    echo -e "\n\n\nBy default, Fedora includes a free/open-source version for Intel iGPUs that can\nbe replaced with a higher performance, less-open driver.  It is recommended to\ninstall this package to increase performance for 5th gen platforms and later.\n"
    echo -e "\nIs this device an \033[95mIntel 5th Gen or later\033[0m with integrated Intel graphics?"
    read -n 1 -p "Choose Y (Yes) if you have a dedicated Intel GPU as well. (y/n) " answer
    case ${answer:0:1} in
        y|Y )
            INTELGPU=true
        ;;
        * )
            INTELGPU=false
        ;;
    esac

    echo -e "\n\n\nBy default, Fedora includes a free/open-source driver for \033[95mAMD GPUs and iGPUs\033[0m\nthat can be replaced with an updated package that may offer some increases in\nperformance.  It is recommended if you have AMD hardware to install these packages.\n"
    read -n 1 -p "Do you have integrated AMD graphics or an AMD GPU? (y/n) " answer
    case ${answer:0:1} in
        y|Y )
            AMDGPU=true
        ;;
        * )
            AMDGPU=false
        ;;
    esac

    echo -e "\n\n\nBy default, Fedora includes only free/open-source software which excludes some\nproprietary \033[95mpackages released by Nvidia to enable their hardware\033[0m or the best\nfeatures of their hardware.  It is recommended if you have Nvidia hardware to\ninstall these packages.  Additional setup prompts may appear during installation.\n"
    read -n 1 -p "Do you have integrated Nvidia graphics or a Nvidia GPU? (y/n) " answer
    case ${answer:0:1} in
        y|Y )
            NVIDIAGPU=true
        ;;
        * )
            NVIDIAGPU=false
        ;;
    esac

    echo -e "\n\n\nThis script includes prompts to install some common, popular packages from either\nthe \033[94mFedora/RPM Fusion\033[0m repositories or \033[92mFlathub\033[0m - this is different than some of\nthe default behavior from tools like dnf groups to minimize extra cruft.\n"
    read -n 1 -p "Do you want to choose apps to install? (y/n) " answer
    case ${answer:0:1} in
        y|Y )
            INSTALLAPPS=true
        ;;
        * )
            INSTALLAPPS=false
        ;;
    esac

    echo -e "\n\n\nDo you want to install \033[92mfile sharing platform\033[0m packages?"
    read -n 1 -p "Dropbox, Sparkleshare, and more - (y/n) " answer
    case ${answer:0:1} in
        y|Y )
            INSTALLSHARING=true
        ;;
        * )
            INSTALLSHARING=false
        ;;
    esac

    echo -e "\n\n\nDo you want to install \033[92mcontainer and image management\033[0m packages?"
    read -n 1 -p "Podman, Docker Compose, and more - (y/n) " answer
    case ${answer:0:1} in
        y|Y )
            INSTALLCONTAINER=true
        ;;
        * )
            INSTALLCONTAINER=false
        ;;
    esac


    echo -e "\n\n\nThis script includes the abiltiy to install the WireGuard-based networking suite\nfrom \033[92mTailscale\033[0m that integrates with both the Linux shell and your desktop\nenvironment.  You will be prompted during the script to login and add the node.\n"
    read -n 1 -p "Do you want to install Tailscale? (y/n) " answer
    case ${answer:0:1} in
        y|Y )
            INSTALLTAILSCALE=true
        ;;
        * )
            INSTALLTAILSCALE=false
        ;;
    esac
}

# Present the choice of different application packages to customize the setup and ideally avoid unneeded cruft
bespoke-appoptions() {
    if [ "$INSTALLAPPS" = true ]; then
        echo -e "\n\n\nDo you want to install \033[92moffice and productivity\033[0m applications?"
        read -n 1 -p "LibreOffice, Email, GnuCash, Okular, and more - (y/n) " answer
        case ${answer:0:1} in
            y|Y )
                INSTALLOFFICE=true
            ;;
            * )
                INSTALLOFFICE=false
            ;;
        esac

        echo -e "\n\n\nDo you want to install \033[92mpersonal multimedia\033[0m applications?"
        read -n 1 -p "Amberol, Calibre, Celluloid, VLC, and more - (y/n) " answer
        case ${answer:0:1} in
            y|Y )
                INSTALLMEDIA=true
            ;;
            * )
                INSTALLMEDIA=false
            ;;
        esac

        echo -e "\n\n\nDo you want to install \033[92mcreative design\033[0m applications?"
        read -n 1 -p "Darktable, GIMP, Inkscape, Krita, and more - (y/n) " answer
        case ${answer:0:1} in
            y|Y )
                INSTALLCREATIVE=true
            ;;
            * )
                INSTALLCREATIVE=false
            ;;
        esac

        echo -e "\n\n\nDo you want to install \033[92m3D and video production\033[0m applications?"
        read -n 1 -p "Blender, Kdenlive, OBS, OpenShot, Pitivi, and more - (y/n) " answer
        case ${answer:0:1} in
            y|Y )
                INSTALLVIDEO=true
            ;;
            * )
                INSTALLVIDEO=false
            ;;
        esac

        echo -e "\n\n\nDo you want to install \033[92maudio production\033[0m applications?"
        read -n 1 -p "Ardour, MuseScore, Tenacity, and more - (y/n) " answer
        case ${answer:0:1} in
            y|Y )
                INSTALLAUDIO=true
            ;;
            * )
                INSTALLAUDIO=false
            ;;
        esac

        echo -e "\n\n\nDo you want to install \033[92mcoding tools and development\033[0m applications?"
        read -n 1 -p "Android Studio, Pulsar, Obsidian, and Visual Studio Code (y/n) " answer
        case ${answer:0:1} in
            y|Y )
                INSTALLDEVELOPMENT=true
            ;;
            * )
                INSTALLDEVELOPMENT=false
            ;;
        esac

        echo -e "\n\n\nDo you want to install \033[92mGIS and weather\033[0m applications?"
        read -n 1 -p "Meteo and QGIS (y/n) " answer
        case ${answer:0:1} in
            y|Y )
                INSTALLGIS=true
            ;;
            * )
                INSTALLGIS=false
            ;;
        esac

        echo -e "\n\n\nDo you want to install \033[92mLLM front-end\033[0m applications?"
        read -n 1 -p "Alpaca and GPT4All (y/n) " answer
        case ${answer:0:1} in
            y|Y )
                INSTALLLLM=true
            ;;
            * )
                INSTALLLLM=false
            ;;
        esac

        echo -e "\n\n\nDo you want to install \033[92mgaming platforms\033[0m and packages?"
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

# Figure out if this is regular Fedora or an Atomic spin like Silverblue
bespoke-atomic() {
    echo -e "\nChecking if you are running an \033[35mAtomic\033[0m desktop...\n"
    sleep 1
    if [ ! -f /run/ostree-booted ]; then
        ATOMICFEDORA=false
        echo -e "\nYou are not running an \033[95mAtomic\033[0m version of Fedora.\n"
    else
        ATOMICFEDORA=true
        echo -e "\nYou are running an \033[95mAtomic\033[0m version of Fedora!\n"
    fi
}

# Figure out if we're running Fedora
bespoke-distro() {
    echo -e "\nChecking if you are running \033[94mFedora\033[0m...\n"
    sleep 1
    if [ ! -f /etc/os-release ]; then
        echo -e "\n\031[91mERROR at bespoke-distro\033[0m - Checking if you are running Fedora"
        echo -e "Script was not able to determine distribution or read /etc/os-release... \031[34mscript stopped\033[0m.\n"
        exit 1
    fi
    . /etc/os-release
    if [ "$ID" = "fedora" ]; then
        bespoke-version;
    else
        echo -e "\nThis script is not compatible with your distribution."
        echo -e "\nYour computer is is currently running: $ID $VERSION_ID"
        echo -e "\nThis script is for \033[94mFedora 40, 41, or higher\033[0m - \031[91minstallation stopped\033[0m."
        exit 1
    fi
}

# Figure out if we're running a version of Fedora that this script should support
bespoke-version() {
    echo -e "\nChecking your version of \033[94mFedora\033[0m...\n"
    sleep 1
    . /etc/os-release
    if [ "$VERSION_ID" -ge "40" ]; then
        bespoke-atomic;
    else
        echo -e "\nThis script is not compatible with your distribution version."
        echo -e "\nYour computer is is currently running: $ID $VERSION_ID"
        echo -e "\nThis script is for \033[94mFedora 40, 41, or higher\033[0m - \031[91minstallation stopped\033[0m."
        exit 1
    fi
}

bespoke-repos() {
    if [ "$ATOMICFEDORA" = true ]; then
        sudo wget -P /etc/yum.repos.d/ https://copr.fedorainfracloud.org/coprs/lilay/topgrade/repo/fedora-40/lilay-topgrade-fedora-$VERSION_ID.repo
        sudo wget -P /etc/yum.repos.d/ https://copr.fedorainfracloud.org/coprs/kwizart/fedy/repo/fedora-40/kwizart-fedy-fedora-$VERSION_ID.repo
        sudo rpm-ostree refresh-md
        sudo rpm-ostree reload
        sudo rpm-ostree install -y topgrade fedy
    else
        sudo dnf copr enable lilay/topgrade
        sudo dnf copr enable kwizart/fedy
        sudo dnf install -y topgrade fedy
    fi
}
# Install shell enhancements from Starship (https://starship.rs/) and activate the No Nerd Fonts preset (https://starship.rs/presets/no-nerd-font)
bespoke-starship() {
    echo -e "\nInstalling enhancements to default Bash shell with \033[95mStarship\033[0m...\n"
    sleep 1
    curl -sS https://starship.rs/install.sh | sh
    mkdir ~/.config
    touch ~/.config/starship.toml
    echo 'eval "$(starship init bash)"' | sudo tee -a ~/.bashrc
    starship preset no-nerd-font -o ~/.config/starship.toml
}

# Figure out what Desktop Environment we're running
if [ "$XDG_CURRENT_DESKTOP" = "" ]
    then
        USERDESKTOP=$(echo "$XDG_DATA_DIRS" | sed 's/.*\(xfce\|kde\|gnome\).*/\1/')
    else
        USERDESKTOP=$XDG_CURRENT_DESKTOP
fi

USERDESKTOP=${USERDESKTOP,,}  # Convert to lower case
echo -e "\nThe script has detected \033[93m$USERDESKTOP\033[0m as your current desktop environment..."
sleep 1

if [ "$USERDESKTOP" = "gnome" ]; then
    echo -e "\nSetting your desktop environment to stay unlocked during this script...\n"
    sleep 1
    gsettings set org.gnome.desktop.screensaver lock-enabled false
    gsettings set org.gnome.desktop.session idle-delay 0
    gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
    gsettings set org.gnome.desktop.interface show-battery-percentage true    
fi

# Run the actual script - doing this here so that if we're downloading it remotely, we don't start changing things without everything already loaded up above
bespoke-start
bespoke-distro
bespoke-options
bespoke-appoptions
bespoke-install
bespoke-appinstalls
bespoke-repos
bespoke-starship

if [ "$USERDESKTOP" = "gnome" ]; then
    echo -e "\nResetting your desktop environment to lock settings...\n"
    sleep 1
    gsettings set org.gnome.desktop.screensaver lock-enabled true
    gsettings set org.gnome.desktop.session idle-delay 300

fi

echo -e "\n\nThe script has now completed and it is recommended to reboot the device.\n"
sleep 1
read -n 1 -p "Do you want to restart now? (y/n) " answer
case ${answer:0:1} in
    y|Y )
        echo -e "\n"
        sudo systemctl reboot
    ;;
    * )
        echo -e "\n"
        exit 0
    ;;
esac

# End of the script
