{ pkgs }:

# Fixed-output derivation that fetches from the KDE Store OCS API at build time,
# getting a fresh JWT download URL each build.
{ contentId, name, hash }:
pkgs.stdenv.mkDerivation {
  inherit name;
  outputHash = hash;
  outputHashMode = "recursive";
  outputHashAlgo = "sha256";

  nativeBuildInputs = with pkgs; [ curl cacert gnutar xz bzip2 ];

  phases = [ "installPhase" ];

  installPhase = ''
    # Query the KDE Store API for a fresh download URL
    downloadUrl=$(curl -sL "https://api.kde-look.org/ocs/v1/content/data/${toString contentId}" \
      | sed -n 's|.*<downloadlink1>\(.*\)</downloadlink1>.*|\1|p' \
      | sed 's/&amp;/\&/g')

    # Download and extract
    curl -L "$downloadUrl" -o archive
    mkdir -p $out
    tar xf archive -C $out
  '';
}
