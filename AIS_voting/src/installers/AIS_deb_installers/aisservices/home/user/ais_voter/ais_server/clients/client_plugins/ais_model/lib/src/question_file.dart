class QuestionFile {
  int id;
  String relativePath;
  String realPath;
  String fileName;
  String version;
  String description;
  int questionId;

  QuestionFile(
      {this.id,
      this.relativePath,
      this.realPath,
      this.fileName,
      this.version,
      this.description,
      this.questionId});

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
