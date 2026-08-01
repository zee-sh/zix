{
  # Work-only nixpkgs config. ecdsa 0.19.x carries the Minerva side-channel
  # advisory; it's pulled in transitively by some cloud CLIs, so permit it.
  flake.modules.darwin.nixpkgsWork =
    { config, lib, ... }:
    {
      config = lib.mkIf config.zix.profiles.work.enable {
        nixpkgs.config.permittedInsecurePackages = [
          "python3.13-ecdsa-0.19.2"
          "python3.14-ecdsa-0.19.2"
        ];
      };
    };
}
