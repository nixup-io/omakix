{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "ia-fonts";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "iaolo";
    repo = "iA-Fonts";
    rev = "f32c04c3058a75d7ce28919ce70fe8800817491b";
    hash = "sha256-2T165nFfCzO65/PIHauJA//S+zug5nUwPcg8NUEydfc=";
  };

  installPhase = ''
    local out_font=$out/share/fonts/ia-fonts
    install -m444 -Dt $out_font "./iA Writer Mono/Variable/iAWriterMonoV-Italic.ttf"
    install -m444 -Dt $out_font "./iA Writer Mono/Variable/iAWriterMonoV.ttf"
    install -m444 -Dt $out_font "./iA Writer Duo/Variable/iAWriterDuoV-Italic.ttf"
    install -m444 -Dt $out_font "./iA Writer Duo/Variable/iAWriterDuoV.ttf"
    install -m444 -Dt $out_font "./iA Writer Quattro/Variable/iAWriterQuattroV-Italic.ttf"
    install -m444 -Dt $out_font "./iA Writer Quattro/Variable/iAWriterQuattroV.ttf"
  '';

  meta = with stdenvNoCC.lib; {
    description = "Free variable writing fonts from iA";
    homepage = "https://github.com/iaolo/iA-Fonts";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [michaelshmitty];
  };
}
