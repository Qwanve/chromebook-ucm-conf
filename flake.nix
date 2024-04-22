{
  description = "A port of WeirdTreeThing's alsa-ucm-conf";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    wtt = {
      url = "github:WeirdTreeThing/chromebook-ucm-conf";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, wtt }:
    let

      version = "0.1";

      # System types to support.
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlays.default ]; });

    in

    {

      overlays.default = final: prev: {

        chromebook-ucm-conf = final.stdenv.mkDerivation {
          name = "chromebook-ucm-conf-${version}";

          src = wtt;

          installPhase =
            ''
              runHook preInstall
    
              mkdir -p $out/share/alsa
              cp -sr ${final.alsa-ucm-conf}/share/alsa/ucm2 $out/share/alsa/ucm2
              chmod +w $out/share/alsa/ucm2 --recursive

              cp -rf $src/common $out/share/alsa/ucm2/
              cp -rf $src/codecs $out/share/alsa/ucm2/
              cp -rf $src/platforms $out/share/alsa/ucm2/
              cp -rf $src/sof-rt5682 $out/share/alsa/ucm2/conf.d/
              cp -rf $src/sof-cs42l42 $out/share/alsa/ucm2/conf.d/

              runHook postInstall
            '';
        };

      };

      packages = forAllSystems (system:
        {
          default = self.packages.${system}.chromebook-ucm-conf;
          inherit (nixpkgsFor.${system}) chromebook-ucm-conf;
        });

      # defaultPackage = forAllSystems (system: self.packages.${system}.chromebook-ucm-conf);

      nixosModules = {
        default = self.nixosModules.chromebook-ucm-conf;
        chromebook-ucm-conf =
          { pkgs, ... }:
          {
            nixpkgs.overlays = [ self.overlays.default ];

            environment.systemPackages = [ pkgs.chromebook-ucm-conf ];
            environment.sessionVariables = {
              ALSA_CONFIG_UCM2 = "${pkgs.chromebook-ucm-conf}/share/alsa/ucm2";
            };
            boot.extraModprobeConfig = ''
              options snd-intel-dspcfg dsp_driver=3
            '';

          };
        };
      };
}
