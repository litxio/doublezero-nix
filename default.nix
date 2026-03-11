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
    version = "0.4.1";

    src = fetchurl {
      url = "https://dl.cloudsmith.io/public/malbeclabs/doublezero/deb/debian/pool/any-version/main/d/do/doublezero-solana_0.4.1-1/doublezero-solana_0.4.1_linux_amd64.deb";
      sha256 = "d96c6f4b40f1843fe80b71ca384a8829c6a213f715467f45f6ca71aade456298";
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
  version = "0.10.0";

  src = fetchurl {
    url = "https://dl.cloudsmith.io/public/malbeclabs/doublezero/deb/debian/pool/any-version/main/d/do/doublezero_0.10.0-1/doublezero-mainnet-beta_0.10.0_amd64.deb";
    sha256 = "7158974f49d40acee9c3b4e823e884f4578a3431a8aef3e2528d970b09c580b5";
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
