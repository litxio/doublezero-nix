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
    version = "0.3.2";

    src = fetchurl {
      url = "https://dl.cloudsmith.io/public/malbeclabs/doublezero/deb/debian/pool/any-version/main/d/do/doublezero-solana_${version}-1/doublezero-solana_${version}_linux_amd64.deb";
      sha256 = "451e97a6643c97f867b1a6318341297392ef5061dc78340424fa0dabe65c7a94";
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
  version = "0.8.0";

  src = fetchurl {
    url = "https://dl.cloudsmith.io/public/malbeclabs/doublezero/deb/debian/pool/any-version/main/d/do/doublezero_${version}-1/doublezero_${version}_linux_amd64.deb";
    sha256 = "5f17c3c71657786beca287e1c65c40ba4fb2d3b989b38d95ab1fedd4f20179dc";
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
