{ kinc-src }:
final: prev:
let

in
{
  kode = rec {
    kinc = prev.callPackage ./kinc { inherit kinc-src; };
    #libKinc = prev.callPackage ./libKinc { inherit kinc; };
    libKinc-opengl = prev.callPackage ./libKinc { inherit kinc; };
    libKinc-vulkan = prev.callPackage ./libKinc { inherit kinc; graphics-api = "vulkan"; };
  };
}
