{ stdenv, lib, makeWrapper, kinc-shader-src, kinc, libKinc }:

stdenv.mkDerivation {
  name = "kinc-shader";
  src = kinc-shader-src;

  nativeBuildInputs = [ makeWrapper kinc libKinc ];
  buildInputs = [ libKinc ];

  patchPhase = ''
    cat << EOF >> Sources/shader.c

    int main(int argc, char** argv) {
    	kickstart(argc, argv);
    }
    EOF
  '';

  # Use stand alone Krafix at some point
  buildPhase = ''
    cd Shaders/
    ${kinc}/Tools/krafix/krafix-linux64 glsl shader.vert.glsl shader.vert . linux
    ${kinc}/Tools/krafix/krafix-linux64 glsl shader.frag.glsl shader.frag . linux
    cd ../Sources/
    gcc -o .kinc-shader-wrapped shader.c -lKinc
    cd ..
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp Sources/.kinc-shader-wrapped Shaders/shader.vert Shaders/shader.frag $out/bin
    makeWrapper $out/bin/.kinc-shader-wrapped $out/bin/kinc-shader --run "cd $out/bin"
  '';

  meta = with lib; {
    description = "Shader-Kinc sample application modified to utilize libKinc.";
    homepage = https://github.com/Kinc-Samples/Shader-Kinc;
    downloadPage = https://github.com/Kinc-Samples/Shader-Kinc;
    license = licenses.free;
    maintainers = [ maintainers.patternspandemic ];
    platforms = [ "x86_64-linux" ];
  };
}
