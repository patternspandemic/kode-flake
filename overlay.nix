{ kinc-src, kinc-shader-src, kinc-texture-src }:
final: prev:
let

in
{
  kode = rec {
    kinc = prev.callPackage ./kinc { inherit kinc-src; };
    libKinc = prev.callPackage ./libKinc { inherit kinc; };
    # libKinc-opengl = prev.callPackage ./libKinc { inherit kinc; };
    # libKinc-vulkan = prev.callPackage ./libKinc { inherit kinc; graphics-api = "vulkan"; };
    kinc-shader = prev.callPackage ./samples/kinc-shader {inherit kinc-shader-src kinc libKinc; };
    kinc-texture = prev.callPackage ./samples/kinc-texture {inherit kinc-texture-src kinc libKinc; };
  };
}
