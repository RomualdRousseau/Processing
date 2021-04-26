class KNNFilter extends GeoFilter {

  public String type = "health";

  public String postalCode = "";

  public float score = -1;

  public GeoData winner = null;

  public boolean match(GeoData d) {
    final float dist = mag(dist1(d.types, type), dist2(d.postalCode, postalCode));
    if (score < 0 || dist < score) {
      score = dist;
      winner = d;
      return true;
    } else {
      return false;
    }
  }

  private float dist1(String a, String b) {
    return a != null && a.contains(b) ? 0 : 1;
  }

  private float dist2(String a, String b) {
    return a != null && a.equals(b) ? 0 : 1;
  }
}
