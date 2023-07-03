class ImageInformation {
  int? x1;
  int? y1;
  int? x2;
  int? y2;
  int? x3;
  int? y3;
  int? x4;
  int? y4;
  double? centerX;
  double? centerY;
  String? text;

  ImageInformation(
      {this.x1,
      this.x2,
      this.x3,
      this.x4,
      this.y1,
      this.y2,
      this.y3,
      this.y4,
      this.centerX,
      this.centerY,
      this.text});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['x1'] = x1;
    data['x2'] = x2;
    data['x3'] = x3;
    data['x4'] = x4;
    data['x_center'] = centerX;
    data['y1'] = y1;
    data['y2'] = y2;
    data['y3'] = y3;
    data['y4'] = y4;
    data['y_center'] = centerY;
    data['text'] = text;
    return data;
  }
}
