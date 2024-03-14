class VotingMode {
  int id;
  String name;
  String defaultDecision;
  int orderNum;
  String includedDecisions;

  VotingMode(
      {this.id,
      this.name,
      this.defaultDecision,
      this.orderNum,
      this.includedDecisions});

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
