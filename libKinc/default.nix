{ stdenv, lib
, cpio
, kinc, nodejs-slim
# Options
, graphics-api ? "opengl"
# Required Libs
, alsaLib
, libGL
, vulkan-headers
, vulkan-loader
, libudev
, xorg
}:

assert lib.asserts.assertOneOf "graphics-api" graphics-api [ "opengl" "vulkan" ];

let
  requiredLibs = [
      alsaLib
      libudev
      # mesa
      xorg.libX11
      xorg.libXcursor
      xorg.libXi
      xorg.libXinerama
      xorg.libXrandr
  ];
  openGLLibs = [ libGL ];
  vulkanLibs = [ vulkan-headers vulkan-loader ];

in
  stdenv.mkDerivation {
    name = "libKinc";
    src = kinc;

    nativeBuildInputs = [
      cpio
      nodejs-slim
    ];

    buildInputs = requiredLibs ++ lib.optionals (graphics-api == "opengl") openGLLibs
                               ++ lib.optionals (graphics-api == "vulkan") vulkanLibs;

    buildPhase = ''
      node make.js --graphics ${graphics-api} --dynlib
      make -C build/Release/
    '';

    installPhase = ''
      mkdir -p $out/lib $out/include
      cp build/Release/Kinc.so $out/lib/libKinc.so
      cd Sources/
      find . -name "*.h" -print0 | cpio -pdm0 $out/include
    '';

    meta = with stdenv.lib; {
      description = "Shared library for Kode's Kinc framework";
      homepage = https://github.com/Kode/Kinc;
      downloadPage = https://github.com/Kode/Kinc;
      license = licenses.zlib;
      maintainers = [ maintainers.patternspandemic ];
      platforms = [ "x86_64-linux" ];
    };
  }
