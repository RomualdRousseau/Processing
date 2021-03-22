void prepareZuelligCustomer(String fileName) throws Exception {

  GeoLocation gl = new GeoLocation("AIzaSyAl8rftE96nl5cGZmD06-XKoP7mpYiQfRI", "sg", "sg");
  gl.useCache(dataPath("google_location.dat"), false);

  GeoPlace gp = new GeoPlace("AIzaSyAl8rftE96nl5cGZmD06-XKoP7mpYiQfRI", "sg", "en");
  gp.useCache(dataPath("google_place.dat"), false);

  Table output = new Table();
  output.addColumn("rowId");
  output.addColumn("code");
  output.addColumn("_name");
  output.addColumn("_address1");
  output.addColumn("_address2");
  output.addColumn("_postalCode");
  output.addColumn("types");
  output.addColumn("name");
  output.addColumn("formattedAddress");
  output.addColumn("postalCode");
  output.addColumn("latitude");
  output.addColumn("longitude");
  output.addColumn("score");

  Table input = loadTable(fileName, "header");

  int count = 0;

  for (final TableRow row : input.rows()) {

    KNNFilter filter = new KNNFilter();
    filter.postalCode = row.getString(5);
    GeoData cache = gl.query((row.getString(1) + " " + row.getString(2) + " " + row.getString(3) + " " + row.getString(5)).trim(), filter);
    if (filter.winner == null) {
      filter.winner = cache;
    }
    gl.query((row.getString(2) + " " + row.getString(3) + " " + row.getString(5)).trim(), filter);

    TableRow newRow = output.addRow();
    newRow.setInt("rowId", count);
    newRow.setString("code", row.getString(0));
    newRow.setString("_name", row.getString(1));
    newRow.setString("_address1", row.getString(2));
    newRow.setString("_address2", row.getString(3));
    newRow.setString("_postalCode", row.getString(5));
    newRow.setFloat("score", filter.score);
    if (filter.winner != null) {
      newRow.setString("types", filter.winner.types);
      newRow.setString("name", gp.query(filter.winner.placeId));
      newRow.setString("formattedAddress", filter.winner.formattedAddress);
      newRow.setString("postalCode", (filter.winner.postalCode == null || filter.winner.postalCode.equals("")) ? filter.postalCode : filter.winner.postalCode);
      newRow.setDouble("latitude", filter.winner.point.latitude);
      newRow.setDouble("longitude", filter.winner.point.longitude);
    }

    count++;
    println(((float) count * 100 / input.getRowCount()) + "%\r");
  }

  gp.flushCache();
  gl.flushCache();

  saveTable(output, "data/zuellig.csv");
}

void mapZuelligLynXCRMCustomers() {
  Table input1 = loadTable("zuellig.csv", "header");
  Table input2 = loadTable("lynxcrm.csv", "header");

  Table output = new Table();
  output.addColumn("rowIdZuellig");
  output.addColumn("codeZuellig");
  output.addColumn("rowIdLynXCRM");
  output.addColumn("codeLynXCRM");
  output.addColumn("distance");

  for (final TableRow row1 : input1.rows()) {
    GeoPoint src = new GeoPoint(row1.getDouble(10), row1.getDouble(11));

    double dist = -1;
    String code = null;
    String rowId = null;

    for (final TableRow row2 : input2.rows()) {
      GeoPoint dst = new GeoPoint(row2.getDouble(11), row2.getDouble(12));

      double d = src.distanceInMeter(dst);
      if (dist < 0 || d < dist) {
        dist = d;
        rowId = row2.getString(0);
        code = row2.getString(1);
      }
    }

    TableRow newRow = output.addRow();
    newRow.setString("rowIdZuellig", row1.getString(0));
    newRow.setString("codeZuellig", row1.getString(1));
    newRow.setString("rowIdLynXCRM", rowId);
    newRow.setString("codeLynXCRM", code);
    newRow.setInt("distance", (int) dist);
  }

  saveTable(output, "data/zuellig_lynxcrm.csv");
}
