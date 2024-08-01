class QuestionDescriptionItem {
  String caption;
  String text;
  bool showOnStoreboard;
  bool showInReports;

  QuestionDescriptionItem({
    required this.caption,
    required this.text,
    required this.showOnStoreboard,
    required this.showInReports,
  });

  Map toJson() => {
        'caption': caption,
        'text': text,
        'showOnStoreboard': showOnStoreboard,
        'showInReports': showInReports,
      };

  QuestionDescriptionItem.fromJson(Map<String, dynamic> json)
      : caption = json['caption'],
        text = json['text'],
        showOnStoreboard = json['showOnStoreboard'] ?? true,
        showInReports = json['showInReports'] ?? true;

  @override
  String toString() {
    return caption + text;
  }
}
