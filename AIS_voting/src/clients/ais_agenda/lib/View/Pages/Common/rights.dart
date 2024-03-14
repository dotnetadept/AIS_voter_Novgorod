import 'package:ais_agenda/Model/entity/restricted_item.dart';
import 'package:ais_agenda/Model/subject/permission.dart';
import 'package:ais_agenda/Model/subject/subject.dart';
import 'package:ais_agenda/Model/subject/subject_action.dart';
import 'package:ais_agenda/State/app_state.dart';
import 'package:ais_agenda/View/Dialogs/select_subject_dialog.dart';
import 'package:ais_agenda/View/Pages/Shell/shell.dart';
import 'package:flutter/material.dart';

import '../../../Model/subject/aisaction.dart';

class RightsPage extends StatefulWidget {
  const RightsPage(this.restrictedItem, {Key? key}) : super(key: key);

  final RestrictedItem restrictedItem;

  @override
  State<RightsPage> createState() => _RightsPageState();
}

class _RightsPageState extends State<RightsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Shell(
      title: Text(
          '${AppState().getPreviousNavPath()} > ${widget.restrictedItem.toString()} > Права'),
      actions: <Widget>[
        Tooltip(
          message: 'Сохранить',
          child: TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                const CircleBorder(side: BorderSide(color: Colors.transparent)),
              ),
            ),
            onPressed: _save,
            child: const Icon(Icons.save),
          ),
        ),
        Container(
          width: 20,
        ),
      ],
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: widget.restrictedItem.permissions.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  child:
                      getRightsItem(widget.restrictedItem.permissions[index]),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: TextButton(
              onPressed: () {
                var newItem = SubjectAction();
                newItem.subject = AppState().getUsers().first;
                newItem.action = AppState().getActions().first;
                newItem.permission = AppState().getPermissions().first;

                widget.restrictedItem.permissions.add(newItem);
                setState(() {});
              },
              child: const Text('Добавить'),
            ),
          )
        ],
      ),
    );
  }

  Widget getRightsItem(SubjectAction subjectAction) {
    return Row(
      children: [
        getSubjectSelector(subjectAction),
        Container(
          width: 20,
        ),
        getActionSelector(subjectAction),
        Container(
          width: 20,
        ),
        getPermissionSelector(subjectAction)
      ],
    );
  }

  Widget getSubjectSelector(SubjectAction subjectAction) {
    return TextButton(
        onPressed: () async {
          Subject? subject = await showDialog<Subject>(
            context: context,
            builder: (_) => const Dialog(
              child: SelectSubjectDialog(),
            ),
          );

          if (subject != null) {
            subjectAction.subject = subject;
          }

          setState(() {});
        },
        child: Text(subjectAction.subject.toString()));
  }

  Widget getActionSelector(SubjectAction subjectAction) {
    return DropdownButton<AisAction>(
      value: subjectAction.action,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (value) {},
      items: AppState()
          .getActions()
          .map<DropdownMenuItem<AisAction>>((AisAction value) {
        return DropdownMenuItem<AisAction>(
          value: value,
          child: Text(value.name),
        );
      }).toList(),
    );
  }

  Widget getPermissionSelector(SubjectAction subjectAction) {
    return DropdownButton<Permission>(
      value: subjectAction.permission,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (value) {},
      items: AppState()
          .getPermissions()
          .map<DropdownMenuItem<Permission>>((Permission value) {
        return DropdownMenuItem<Permission>(
          value: value,
          child: Text(value.name),
        );
      }).toList(),
    );
  }

  bool _save() {
    // File localFile = File('assets/cfg/forms.json');
    // localFile.writeAsStringSync(jsonEncode(AppState().getForms()));

    // Provider.of<AppState>(context, listen: false).navigateToPage('/forms');

    return true;
  }
}
