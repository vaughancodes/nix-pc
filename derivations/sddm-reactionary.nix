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
in
pkgs.stdenv.mkDerivation {
  pname = "sddm-reactionary";
  version = "3.0.16";
  src = pkgs.fetchgit {
    url = "https://www.opencode.net/phob1an/reactionary.git";
    rev = "d02946110b87c9c61607ff4913dcbf9d070f6b6a";
    hash = "sha256-u74Mpdj57Ze5uz8vcLOcdvhMEzDfbnjqBJ8qD2/156s=";
  };
  installPhase = ''
    mkdir -p $out/share/sddm/themes/reactionary
    cp -r sddm/themes/reactionary/* $out/share/sddm/themes/reactionary/

    # Generate a solid teal background SVG (Win98 desktop color)
    cat > $out/share/sddm/themes/reactionary/background.svg <<BGEOF
    <?xml version="1.0"?>
    <svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%">
      <rect width="100%" height="100%" fill="#008080"/>
    </svg>
    BGEOF

    # Embed key icon from SE98C icon theme into promptbox SVG as base64
    logoBase64=$(base64 -w0 ${se98c-icons}/Win98SE-main/SE98/apps/48/keyring-manager.png)

    # Hide the geometric logo rects and embed the Windows logo
    sed -i \
      -e 's/id="rect4"/id="rect4" display="none"/' \
      -e 's/id="rect6"/id="rect6" display="none"/' \
      -e 's/id="rect9"/id="rect9" display="none"/' \
      -e 's/id="rect12"/id="rect12" display="none"/' \
      -e 's/id="rect13"/id="rect13" display="none"/' \
      -e 's/id="rect14"/id="rect14" display="none"/' \
      $out/share/sddm/themes/reactionary/assets/promptbox.svg

    # Insert the Windows logo as an embedded image before the closing </g>
    sed -i "s|</g>|<image x=\"-134\" y=\"542\" width=\"48\" height=\"48\" image-rendering=\"pixelated\" href=\"data:image/png;base64,$logoBase64\" />\n</g>|" \
      $out/share/sddm/themes/reactionary/assets/promptbox.svg

    # Recolor promptbox title bar gradient to Win98 navy->blue (#000080->#1084d0)
    sed -i \
      -e 's/#0b256a/#000080/g' \
      -e 's/#a5c9ef/#1084d0/g' \
      -e 's/#003452/#000080/g' \
      -e 's/#9ccff7/#1084d0/g' \
      -e 's/#0b8def/#1084d0/g' \
      -e 's/#004973/#000080/g' \
      $out/share/sddm/themes/reactionary/assets/promptbox.svg

    # Install MS Sans Serif and VMWare Terminal Font
    cp ${../derivations/fonts/ms-sans-serif.ttf} \
      $out/share/sddm/themes/reactionary/assets/ms-sans-serif.ttf
    cp ${../derivations/fonts/ms-sans-serif-bold.ttf} \
      $out/share/sddm/themes/reactionary/assets/ms-sans-serif-bold.ttf
    cp ${../derivations/fonts/vmware-terminal.ttf} \
      $out/share/sddm/themes/reactionary/assets/vmware-terminal.ttf

    # Replace font loaders to use MS Sans Serif
    sed -i \
      -e 's|source: "./assets/Arimo-Regular.ttf"|source: "./assets/ms-sans-serif.ttf"|' \
      -e 's|source: "./assets/Arimo-Bold.ttf"|source: "./assets/ms-sans-serif.ttf"|' \
      $out/share/sddm/themes/reactionary/Main.qml

    # Change greeting text to "Welcome to NixOS", make it slightly smaller and lower
    sed -i \
      -e 's|text: textConstants.welcomeText.arg(sddm.hostName)|text: "Welcome to NixOS"|' \
      -e '0,/font.pointSize: 10/{s/font.pointSize: 10/font.pointSize: 8/}' \
      -e '0,/anchors.topMargin: 4/{s/anchors.topMargin: 4/anchors.topMargin: 5/}' \
      $out/share/sddm/themes/reactionary/Main.qml

    # Change "Username:" to "User name:", make labels black, bump label/button text from 8 to 9
    sed -i \
      -e 's|text: textConstants.userName + ":"|text: "User name:"|' \
      -e 's/color: "#313131"/color: "#000000"/g' \
      -e 's/font.pointSize: 8/font.pointSize: 10/g' \
      $out/share/sddm/themes/reactionary/Main.qml

    # Recolor QML text colors to match Win98 navy
    sed -i \
      -e 's/color: "#308080"/color: "#000080"/g' \
      -e 's/#00456a/#000080/g' \
      -e 's/selectionColor: "#22476d"/selectionColor: "#000080"/g' \
      $out/share/sddm/themes/reactionary/Main.qml

    # Install retrosmart cursor theme
    mkdir -p $out/share/icons/retrosmart-xcursor-white-color
    cp -r ${retrosmart-cursors}/retrosmart-xcursor-white-color/* \
      $out/share/icons/retrosmart-xcursor-white-color/
  '';
}
