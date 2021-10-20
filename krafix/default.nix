{ stdenv, lib, krafix-bin }:

stdenv.mkDerivation {
  name = "krafix";
  src = krafix-bin;

  installPhase =  ''
    mkdir -p $out/bin
    cp krafix-linux64 $out/bin/krafix
  '';

  postFixup = ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath ".:${stdenv.cc.libc}/lib" \
      $out/bin/krafix
  '';

  meta = with lib; {
    description = "GLSL cross-compiler based on glslang and SPIRV-Cross.";
    homepage = https://kode.tech/;
    downloadPage = https://github.com/Kode/krafix_bin;
    license = licenses.zlib;
    maintainers = [ maintainers.patternspandemic ];
    platforms = [ "x86_64-linux" ];
  };
}
