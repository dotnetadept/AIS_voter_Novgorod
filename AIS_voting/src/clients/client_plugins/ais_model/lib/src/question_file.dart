class QuestionFile {
  late int id;
  late String relativePath;
  late String realPath;
  late String fileName;
  late String version;
  late String description;
  late int questionId;

  QuestionFile({
    required this.id,
    required this.relativePath,
    required this.realPath,
    required this.fileName,
    required this.version,
    required this.description,
    required this.questionId,
  });

  Map toJson() => {
        'id': id,
        'path': relativePath,
        'fileName': fileName,
        'version': version,
        'description': description,
        'question': {'id': questionId},
      };

  QuestionFile.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        questionId = json['question']['id'],
        relativePath = json['path'],
        fileName = json['fileName'],
        version = json['version'],
        description = json['description'];
}
