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

    # TODO: Tidy up with pushd popd
    installPhase = ''
      mkdir -p $out/lib $out/include
      cp build/Release/Kinc.so $out/lib/libKinc.so
      cd Sources/
      find . -name "*.h" -print0 | cpio -pdm0 $out/include
      cd ../Backends/System/Linux/Sources/
      find . -name "*.h" -print0 | cpio -pdm0 $out/include
      cd ../../POSIX/Sources/
      find . -name "*.h" -print0 | cpio -pdm0 $out/include
    '' + lib.strings.optionalString (graphics-api == "opengl") ''
      cd ../../../Graphics4/OpenGL/Sources/
      find . -name "*.h" -print0 | cpio -pdm0 $out/include
      cd ../../../Graphics5/G5onG4/Sources/
      find . -name "*.h" -print0 | cpio -pdm0 $out/include
    '' + lib.strings.optionalString (graphics-api == "vulkan") ''
      cd ../../../Graphics5/Vulkan/Sources/
      find . -name "*.h" -print0 | cpio -pdm0 $out/include
      cd ../../../Graphics4/G4onG5/Sources/
      find . -name "*.h" -print0 | cpio -pdm0 $out/include
    '';

    meta = with lib; {
      description = "Shared library for Kode's Kinc framework.";
      homepage = https://github.com/Kode/Kinc;
      downloadPage = https://github.com/Kode/Kinc;
      license = licenses.zlib;
      maintainers = [ maintainers.patternspandemic ];
      platforms = [ "x86_64-linux" ];
    };
  }
