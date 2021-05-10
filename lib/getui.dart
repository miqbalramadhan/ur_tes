Future<Uint8List> getUint8List(GlobalKey widgetKey) async {
  RenderRepaintBoundary boundary = widgetKey.currentContext.findRenderObject();
  var image = await boundary.toImage(pixelRatio: 2.0);
  ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
  return byteData.buffer.asUint8List();
}
