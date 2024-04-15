{
  pkgs,
  fetchFromGitHub,
  alsa-ucm-conf,
}:
with pkgs;
stdenv.mkDerivation {
  name = "chromebook-ucm-conf";
  version = "0.1";
  system = "x86_64-linux";

  src = fetchFromGitHub {
        owner = "WeirdTreeThing";
        repo = "chromebook-ucm-conf";
        rev = "2b2f3a7c993fd38a24aa81394e29ee530b890658";
        hash = "sha256-xWJ5IQZHO7tw5Ykt1MDknGVRZqXyMrIychUMF2A91DA=";
  };
  installPhase = ''
    runHook preInstall
    

    mkdir -p $out/share/alsa
    cp -sr ${alsa-ucm-conf}/share/alsa/ucm2 $out/share/alsa/ucm2
    chmod +w $out/share/alsa/ucm2 --recursive


    cp -rf $src/common $out/share/alsa/ucm2/
    cp -rf $src/codecs $out/share/alsa/ucm2/
    cp -rf $src/platforms $out/share/alsa/ucm2/
    cp -rf $src/sof-rt5682 $out/share/alsa/ucm2/conf.d/
    cp -rf $src/sof-cs42l42 $out/share/alsa/ucm2/conf.d/

    runHook postInstall
  '';
}
