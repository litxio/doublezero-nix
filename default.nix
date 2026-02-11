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
    version = "0.4.0";

    src = fetchurl {
      url = "https://dl.cloudsmith.io/public/malbeclabs/doublezero/deb/debian/pool/any-version/main/d/do/doublezero-solana_${version}-1/doublezero-solana_${version}_linux_amd64.deb";
      sha256 = "cad759e156178cc5b4d807653b7240f2b6d53219a708039912b75eec8bf704e2";
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
  version = "0.8.6";

  src = fetchurl {
    url = "https://dl.cloudsmith.io/public/malbeclabs/doublezero/deb/debian/pool/any-version/main/d/do/doublezero_${version}-1/doublezero_${version}_linux_amd64.deb";
    sha256 = "8a1c48550bc4c43f247ddddb9e572305c1f20dcaee7ec80ca91137a1b817e50e";
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
