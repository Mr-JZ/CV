{
  description = "Get Started with LaTeX";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib;
    eachSystem allSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        tex = pkgs.texlive.combine {
          inherit (pkgs.texlive)
            scheme-full latex-bin latexmk collection-latex
            collection-fontsrecommended collection-latexextra;
        };
      in rec {
        documentName = "Zisenis_CV";
        packages = {
          document = pkgs.stdenvNoCC.mkDerivation rec {
            name = "latex-document";
            src = self;
            buildInputs = [ pkgs.coreutils tex ];
            phases = [ "unpackPhase" "buildPhase" "installPhase" ];
            buildPhase = ''
              # Copy common file first
              cp ${src}/cv_common.tex .
              
              # Build English version
              cp ${src}/Zisenis_CV.tex .
              pdflatex Zisenis_CV.tex
              pdflatex Zisenis_CV.tex
              
              # Build German version
              cp ${src}/Zisenis_CV_de.tex .
              pdflatex Zisenis_CV_de.tex
              pdflatex Zisenis_CV_de.tex
            '';
            installPhase = ''
              mkdir -p $out
              cp ${documentName}.pdf $out/
            '';
          };
        };
        packages.default = packages.document;
        devShell = with pkgs;
          mkShell {
            packages = [ packages.document.buildInputs ];
            shellHook = "echo -n Hello LaTeX";
          };
      });
}
