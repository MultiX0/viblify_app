String getTheHex(String text) {
  var start = text.indexOf("(") + 1;
  var end = text.indexOf(")");
  String newText = text.substring(start, end);
  String hexString = newText.substring(4, newText.length);
  return "#$hexString";
}
