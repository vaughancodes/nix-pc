{ pkgs }:

let
  fetchFromKdeStore = import ./lib/fetchFromKdeStore.nix { inherit pkgs; };

  se98c-icons = fetchFromKdeStore {
    contentId = 1581320;
    name = "se98c-icons";
    hash = "sha256-OOinpdLnFFgThzv73yZps1lLOE2g7FsD/Vp2zRyZ8D0=";
  };

  retrosmart-cursors = fetchFromKdeStore {
    contentId = 1290398;
    name = "retrosmart-xcursor-white-color";
    hash = "sha256-+mpuoLD+hJwgiBbbaJfUennRsc8/FO5e5XLjbVDE4LY=";
  };

  die4ever-theme = pkgs.fetchFromGitHub {
    owner = "Die4Ever";
    repo = "KDE-Windows-98-Theme";
    rev = "3644d14171210630d34e2fbcd77d55ec9b902171";
    hash = "sha256-EpFyiO0L9BtYc5qen/D4YHbJKmg2j8ZLU8FKL0uBvFU=";
  };

  reactionary-src = pkgs.fetchgit {
    url = "https://www.opencode.net/phob1an/reactionary.git";
    rev = "d02946110b87c9c61607ff4913dcbf9d070f6b6a";
    hash = "sha256-u74Mpdj57Ze5uz8vcLOcdvhMEzDfbnjqBJ8qD2/156s=";
  };
in
pkgs.stdenv.mkDerivation {
  pname = "win98-desktop-theme";
  version = "1.0.0";

  dontUnpack = true;

  installPhase = ''
    # SE98C icon theme (upstream is SE98, look-and-feel expects SE98C)
    mkdir -p $out/share/icons
    cp -r ${se98c-icons}/Win98SE-main/SE98 $out/share/icons/SE98C
    chmod -R u+w $out/share/icons/SE98C
    sed -i 's/Name=SE98/Name=SE98C/' $out/share/icons/SE98C/index.theme
    find $out/share/icons/SE98C -xtype l -delete

    # Retrosmart cursor theme
    mkdir -p $out/share/icons/retrosmart-xcursor-white-color
    cp -r ${retrosmart-cursors}/retrosmart-xcursor-white-color/* \
      $out/share/icons/retrosmart-xcursor-white-color/

    # Windows 98 Aurorae window decoration
    mkdir -p $out/share/aurorae/themes
    cp -r ${die4ever-theme}/windows98-aurorae $out/share/aurorae/themes/

    # Win98 color scheme
    mkdir -p $out/share/color-schemes
    cp ${die4ever-theme}/Win98.colors $out/share/color-schemes/

    # Reactionary Plus look-and-feel
    mkdir -p $out/share/plasma/look-and-feel
    cp -r ${reactionary-src}/PLUS/look-and-feel/org.magpie.reactplus.desktop \
      $out/share/plasma/look-and-feel/
    chmod -R u+w $out/share/plasma/look-and-feel/org.magpie.reactplus.desktop

    # Replace the stock Application Launcher (kickoff) with our custom Win98
    # Start Button, and bind the Meta key to toggle it.
    sed -i 's|var kOff = panel.addWidget("org.kde.plasma.kickoff")|var winStart = panel.addWidget("org.win98.startbutton"); winStart.currentConfigGroup = ["Shortcuts"]; winStart.writeConfig("global", "Meta")|' \
      $out/share/plasma/look-and-feel/org.magpie.reactplus.desktop/contents/layouts/org.kde.plasma.desktop-layout.js

    # Reactionary Plus desktop/plasma theme
    mkdir -p $out/share/plasma/desktoptheme
    cp -r ${reactionary-src}/PLUS/desktoptheme/reactplus \
      $out/share/plasma/desktoptheme/

    # Fonts
    mkdir -p $out/share/fonts/truetype
    cp ${./fonts/ms-sans-serif.ttf} $out/share/fonts/truetype/ms-sans-serif.ttf
    cp ${./fonts/ms-sans-serif-bold.ttf} $out/share/fonts/truetype/ms-sans-serif-bold.ttf
    cp ${./fonts/vmware-terminal.ttf} $out/share/fonts/truetype/vmware-terminal.ttf

    # Windows 9x sound theme
    mkdir -p $out/share/sounds
    cp -r ${./sounds/windows-9x} $out/share/sounds/windows-9x

    # Win98 Start Button plasmoid
    mkdir -p $out/share/plasma/plasmoids
    cp -r ${./win98-start-button} $out/share/plasma/plasmoids/org.win98.startbutton
  '';
}
