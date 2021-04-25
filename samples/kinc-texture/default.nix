{ stdenv, lib, makeWrapper, kinc-texture-src, kinc, libKinc }:

stdenv.mkDerivation {
  name = "kinc-texture";
  src = kinc-texture-src;

  nativeBuildInputs = [ makeWrapper kinc libKinc ];
  buildInputs = [ libKinc ];

  patchPhase = ''
    cat << EOF >> Sources/Shader.c

    int main(int argc, char** argv) {
    	kickstart(argc, argv);
    }
    EOF

    substituteInPlace Sources/Shader.c --replace "kinc_matrix3x_rotation_z" "kinc_matrix3x3_rotation_z"
  '';

  # Use stand alone Krafix at some point
  buildPhase = ''
    cd Sources/
    ${kinc}/Tools/krafix/krafix-linux64 glsl texture.vert.glsl texture.vert . linux
    ${kinc}/Tools/krafix/krafix-linux64 glsl texture.frag.glsl texture.frag . linux
    gcc -o .kinc-texture-wrapped Shader.c -lKinc
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp .kinc-texture-wrapped texture.vert texture.frag ../Deployment/parrot.png $out/bin
    makeWrapper $out/bin/.kinc-texture-wrapped $out/bin/kinc-texture --run "cd $out/bin"
  '';

  meta = with stdenv.lib; {
    description = "Texture-Kinc sample application modified to utilize libKinc.";
    homepage = https://github.com/Kinc-Samples/Texture-Kinc;
    downloadPage = https://github.com/Kinc-Samples/Texture-Kinc;
    license = licenses.free;
    maintainers = [ maintainers.patternspandemic ];
    platforms = [ "x86_64-linux" ];
  };
}
