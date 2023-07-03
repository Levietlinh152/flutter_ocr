class ImageInformation {
  int? x;
  int? y;
  String? text;

  ImageInformation({this.x, this.y, this.text});

  ImageInformation.fromJson(Map<String, dynamic> json) {
    x = json['x'];
    y = json['y'];
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['x'] = x;
    data['y'] = y;
    data['text'] = "$text";
    return data;
  }
}
