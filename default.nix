{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, dpkg
, openssl
}:

let
  doublezero-solana = stdenv.mkDerivation rec {
    pname = "doublezero-solana";
    version = "0.5.4";

    src = fetchurl {
      url = "https://dl.cloudsmith.io/public/malbeclabs/doublezero/deb/debian/pool/any-version/main/d/do/doublezero-solana_0.5.4-1/doublezero-solana_0.5.4_linux_amd64.deb";
      sha256 = "a3b94a7023caeb1c8d9a80d374c696c747d5eca7ae4097ac47e7d287d60b5f4a";
    };

    nativeBuildInputs = [
      autoPatchelfHook
      dpkg
    ];

    buildInputs = [
      openssl
      stdenv.cc.cc.lib
    ];

    unpackPhase = ''
      dpkg-deb -x $src .
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r usr/* $out/ || true
      cp -r etc $out/ || true
      runHook postInstall
    '';

    meta = with lib; {
      description = "DoubleZero Solana CLI";
      homepage = "https://doublezero.xyz";
      license = licenses.asl20;
      platforms = [ "x86_64-linux" ];
      maintainers = [];
    };
  };

in stdenv.mkDerivation rec {
  pname = "doublezero";
  version = "0.19.0";

  src = fetchurl {
    url = "https://dl.cloudsmith.io/public/malbeclabs/doublezero/deb/debian/pool/any-version/main/d/do/doublezero_0.19.0-1/doublezero-mainnet-beta_0.19.0_amd64.deb";
    sha256 = "7b2f5ffbf7a4060f1dcfde05b7b64e94306feea6113bbdea22cc88c4b6c7cbb1";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  buildInputs = [
    openssl
    stdenv.cc.cc.lib
  ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp -r usr/* $out/ || true
    cp -r etc $out/ || true

    # Symlink doublezero-solana into bin
    ln -s ${doublezero-solana}/bin/doublezero-solana $out/bin/doublezero-solana
    runHook postInstall
  '';

  meta = with lib; {
    description = "DoubleZero client and CLI";
    homepage = "https://doublezero.xyz";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
    maintainers = [];
  };
}
