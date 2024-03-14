class BaseItem {
  String id = '';

  BaseItem();

  BaseItem.fromJson(Map<String, dynamic> json) : id = json['id'];
}
