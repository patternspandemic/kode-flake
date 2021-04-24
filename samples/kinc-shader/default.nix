{ stdenv, lib, kinc-shader-src, libKinc }:

stdenv.mkDerivation {
  name = "kinc-shader";
  src = kinc-shader-src;

  nativeBuildInputs = [ libKinc ];
  buildInputs = [ libKinc ];

# Will have to compile the shaders, perhaps with a standallone krafix
# krafix-linux64 glsl ./shader.vert.glsl ./shader.vert . linux
# krafix-linux64 glsl ./shader.frag.glsl ./shader.frag . linux

# Will have to append main to Shader.c
# int main(int argc, char** argv) {
# 	kickstart(argc, argv);
# }

  #gcc -o kinc-shader Shader.c -lKinc
}