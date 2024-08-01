class VotingMode {
  late int id;
  late String name;
  late String defaultDecision;
  late int orderNum;
  late String includedDecisions;

  VotingMode({
    required this.id,
    required this.name,
    required this.defaultDecision,
    required this.orderNum,
    required this.includedDecisions,
  });

  Map toJson() => {
        'id': id,
        'name': name,
        'defaultDecision': defaultDecision,
        'orderNum': orderNum,
        'includedDecisions': includedDecisions
      };

  VotingMode.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        defaultDecision = json['defaultDecision'],
        orderNum = json['orderNum'],
        includedDecisions = json['includedDecisions'];
}
