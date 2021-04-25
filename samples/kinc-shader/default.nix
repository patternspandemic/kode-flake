{ stdenv, lib, makeWrapper, kinc-shader-src, kinc, libKinc }:

stdenv.mkDerivation {
  name = "kinc-shader";
  src = kinc-shader-src;

  nativeBuildInputs = [ makeWrapper kinc libKinc ];
  buildInputs = [ libKinc ];

  patchPhase = ''
    cat << EOF >> Sources/Shader.c

    int main(int argc, char** argv) {
    	kickstart(argc, argv);
    }
    EOF
  '';

  # Use stand alone Krafix at some point
  buildPhase = ''
    cd Sources/
    ${kinc}/Tools/krafix/krafix-linux64 glsl shader.vert.glsl shader.vert . linux
    ${kinc}/Tools/krafix/krafix-linux64 glsl shader.frag.glsl shader.frag . linux
    gcc -o .kinc-shader-wrapped Shader.c -lKinc
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp .kinc-shader-wrapped shader.vert shader.frag $out/bin
    makeWrapper $out/bin/.kinc-shader-wrapped $out/bin/kinc-shader --run "cd $out/bin"
  '';

  meta = with stdenv.lib; {
    description = "Shader-Kinc sample application modified to utilize libKinc.";
    homepage = https://github.com/Kinc-Samples/Shader-Kinc;
    downloadPage = https://github.com/Kinc-Samples/Shader-Kinc;
    license = licenses.free;
    maintainers = [ maintainers.patternspandemic ];
    platforms = [ "x86_64-linux" ];
  };
}
