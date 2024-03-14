import 'package:ais_agenda/Model/agenda/agenda_item.dart';
import 'package:ais_agenda/Model/agenda/file.dart';
import 'package:ais_agenda/Model/entity/aisform.dart';

class Question extends AgendaItem {
  AisForm template = AisForm();
  List<AisFile> files = <AisFile>[];

  Question();

  @override
  Map toJson() => {
        'id': id,
        'permissions': permissions,
        'parentId': parentId,
        'name': name,
        'files': files,
        'template': template,
      };

  Question.fromJson(Map<String, dynamic> json)
      : files = json['files'] == null
            ? <AisFile>[]
            : json['files'].map<AisFile>((i) {
                return AisFile.fromJson(i);
              }).toList(),
        template = AisForm.fromJson(json['template']),
        super.fromJson(json);
}
