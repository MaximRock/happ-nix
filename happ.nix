{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  cacert,
  xkeyboard_config,
  coreutils,
  lsb-release,
  net-tools,
  iproute2,
  iptables,
  procps,
  zlib,
  libglvnd,
  libx11,
  fontconfig,
  freetype,
  e2fsprogs,
  libgpg-error,
  krb5,
  openssl,
  dbus,
  wayland,
  libdrm,
  libxkbcommon,
  forceXwayland ? false,
  forceSoftwareRendering ? false,
}:

let
  runtimeDeps = [
    coreutils
    lsb-release
    net-tools
    iproute2
    iptables
    procps
  ];

  qtPlatformArgs = lib.optionalString forceXwayland "--set QT_QPA_PLATFORM xcb";

  softwareRenderArgs = lib.optionalString forceSoftwareRendering ''
    --set QT_QUICK_BACKEND software \
    --set QSG_RHI_BACKEND software \
    --set LIBGL_ALWAYS_SOFTWARE 1
  '';

  waylandCleanup = lib.optionalString forceXwayland ''
    rm -rf "$out/opt/happ/lib/plugins/wayland-"*
    rm -f "$out/opt/happ/lib/plugins/platforms/libqwayland"*.so
  '';
in
stdenv.mkDerivation rec {
  pname = "happ";
  version = "4.7.2";

  src = fetchurl {
    url = "https://github.com/Happ-proxy/happ-desktop/releases/download/${version}/Happ.linux.x64.deb";
    hash = "sha256-hRQPLKB98Lol0C1IKkj2UjdQkxxH/CS6O+bclwK5KfQ=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    zlib
    libglvnd
    libx11
    fontconfig
    freetype
    e2fsprogs
    libgpg-error
    krb5
    openssl
    dbus
    wayland
    libdrm
    libxkbcommon
  ];

  unpackPhase = "dpkg-deb -x $src source";

  sourceRoot = "source";

  autoPatchelfIgnoreMissingDeps = [ "libQt6WlShellIntegration.so.6" ];

  appendRunpaths = [ (lib.makeLibraryPath buildInputs) ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    cp -r opt "$out/"
    cp -r usr/share "$out/"

    test -x "$out/opt/happ/bin/Happ"
    test -x "$out/opt/happ/bin/happd"
    test -f "$out/share/applications/Happ.desktop"

    ${waylandCleanup}

    ln -s "$out/opt/happ/bin/Happ" "$out/bin/Happ"
    ln -s "$out/opt/happ/bin/Happ" "$out/bin/happ"
    ln -s "$out/opt/happ/bin/happd" "$out/bin/happd"

    substituteInPlace "$out/share/applications/Happ.desktop" \
      --replace-fail '/opt/happ/bin/Happ' "$out/bin/happ"

    runHook postInstall
  '';

  postFixup = ''
    for exe in Happ happd; do
      wrapProgram "$out/opt/happ/bin/$exe" \
        --prefix PATH : "${lib.makeBinPath runtimeDeps}" \
        --set SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt" \
        --set XKB_CONFIG_ROOT "${xkeyboard_config}/share/X11/xkb" \
        ${qtPlatformArgs} \
        ${softwareRenderArgs}
    done
  '';

  meta = {
    description = "Proxy utility powered by Xray core";
    homepage = "https://github.com/Happ-proxy/happ-desktop";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "happ";
  };
}
