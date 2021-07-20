{ stdenv, lib, makeWrapper, kinc-texture-src, kinc, libKinc }:

stdenv.mkDerivation {
  name = "kinc-texture";
  src = kinc-texture-src;

  nativeBuildInputs = [ makeWrapper kinc libKinc ];
  buildInputs = [ libKinc ];

  patchPhase = ''
    cat << EOF >> Sources/texture.c

    int main(int argc, char** argv) {
    	kickstart(argc, argv);
    }
    EOF
  '';

  # Use stand alone Krafix at some point
  buildPhase = ''
    cd Shaders/
    ${kinc}/Tools/krafix/krafix-linux64 glsl texture.vert.glsl texture.vert . linux
    ${kinc}/Tools/krafix/krafix-linux64 glsl texture.frag.glsl texture.frag . linux
    cd ../Sources/
    gcc -o .kinc-texture-wrapped texture.c -lKinc
    cd ..
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp Sources/.kinc-texture-wrapped Shaders/texture.vert Shaders/texture.frag Deployment/parrot.png $out/bin
    makeWrapper $out/bin/.kinc-texture-wrapped $out/bin/kinc-texture --run "cd $out/bin"
  '';

  meta = with lib; {
    description = "Texture-Kinc sample application modified to utilize libKinc.";
    homepage = https://github.com/Kinc-Samples/Texture-Kinc;
    downloadPage = https://github.com/Kinc-Samples/Texture-Kinc;
    license = licenses.free;
    maintainers = [ maintainers.patternspandemic ];
    platforms = [ "x86_64-linux" ];
  };
}
