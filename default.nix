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
    version = "0.5.11";

    src = fetchurl {
      url = "https://dl.cloudsmith.io/public/malbeclabs/doublezero/deb/debian/pool/any-version/main/d/do/doublezero-solana_0.5.11-1/doublezero-solana_0.5.11_linux_amd64.deb";
      sha256 = "543aa348d06758165254a7db745253fd4d1b697ea22db0af2775a78511974e59";
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
  version = "0.32.0";

  src = fetchurl {
    url = "https://dl.cloudsmith.io/public/malbeclabs/doublezero/deb/debian/pool/any-version/main/d/do/doublezero_0.32.0-1/doublezero-mainnet-beta_0.32.0_amd64.deb";
    sha256 = "55bf459aca9b30ae8c3d01e2ad481d8f82af3689e81c48698299d801ac2a5174";
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
