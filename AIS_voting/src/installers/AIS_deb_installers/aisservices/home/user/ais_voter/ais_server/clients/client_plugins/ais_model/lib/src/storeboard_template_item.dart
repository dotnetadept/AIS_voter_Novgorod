class StoreboardTemplateItem {
  int order;
  String text = '';
  int fontSize = 14;
  String weight = 'Обычный';
  String align = 'По центру';

  StoreboardTemplateItem() {}

  Map toJson() => {
        'order': order,
        'text': text,
        'fontSize': fontSize,
        'weight': weight,
        'align': align,
      };

  StoreboardTemplateItem.fromJson(Map<String, dynamic> json)
      : order = json['order'],
        text = json['text'],
        fontSize = json['fontSize'],
        weight = json['weight'],
        align = json['align'];
}
