{ stdenv, lib, fetchFromGitHub, kernel }:

stdenv.mkDerivation rec {
  pname = "hid-logitech-g-pro";
  version = "unstable-2025-06-18";

  src = fetchFromGitHub {
    owner = "vaughancodes";
    repo = "hid-logitech-hidpp";
    rev = "3b73f64";
    sha256 = "sha256-5XsmvshGPxpuQOJRr8Ki1MlZx3wcyR5LnWTzGWZY+S0=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  buildPhase = ''
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      M=$(pwd) modules
  '';

  installPhase = ''
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/updates
    cp hid-logitech-hidpp.ko $out/lib/modules/${kernel.modDirVersion}/updates/
  '';

  meta = {
    description = "Patched hid-logitech-hidpp with G Pro DD support";
    license = lib.licenses.gpl2;
  };
}
