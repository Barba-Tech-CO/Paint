enum MaterialType {
  interior('Interior'),
  exterior('Exterior'),
  both('Both');

  const MaterialType(this.displayName);
  final String displayName;
}

enum MaterialQuality {
  economic('Economic'),
  standard('Standard'),
  high('High'),
  premium('Premium');

  const MaterialQuality(this.displayName);
  final String displayName;
}

enum MaterialFinish {
  flat('Flat'),
  eggshell('Eggshell'),
  satin('Satin'),
  semiGloss('Semi-Gloss'),
  gloss('Gloss');

  const MaterialFinish(this.displayName);
  final String displayName;
}
