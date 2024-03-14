import 'package:ais_agenda/Model/agenda/agenda.dart';
import 'package:ais_agenda/Model/agenda/question.dart';
import 'package:ais_agenda/State/app_state.dart';
import 'package:ais_agenda/View/Pages/Shell/shell.dart';
import 'package:ais_agenda/View/Utilities/rights_helper.dart';
import 'package:ais_agenda/View/Widgets/formview/formview_helper.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter/material.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage(this.agenda, this.question, {Key? key}) : super(key: key);

  final Agenda agenda;
  final Question question;

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();

    AppState().setPreviousNavPath(
        'Повестки > ${widget.agenda.name} > ${widget.question.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Shell(
      title: Text(AppState().getPreviousNavPath()),
      actions: <Widget>[
        Container(
          width: 20,
        ),
        RightsHelper().getRightsButton(context, widget.question),
        Container(
          width: 20,
        ),
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
      body: FormBuilder(
        key: _formKey,
        // enabled: false,
        onChanged: () {
          _formKey.currentState!.save();
        },
        autovalidateMode: AutovalidateMode.disabled,

        skipDisabled: true,
        child: FormViewHelper().getFormWidget(
            context, widget.question.template, widget.question.template.fields),
      ),
    );
  }

  bool _save() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      debugPrint(_formKey.currentState?.value.toString());

      return true;
    } else {
      debugPrint(_formKey.currentState?.value.toString());
      debugPrint('validation failed');
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
