import 'package:ais_agenda/Model/agenda/agenda.dart';
import 'package:ais_agenda/Model/entity/form_field_group.dart';
import 'package:ais_agenda/State/app_state.dart';
import 'package:ais_agenda/View/Dialogs/add_question_dialog.dart';
import 'package:ais_agenda/View/Pages/Shell/shell.dart';
import 'package:ais_agenda/View/Utilities/group_utili.dart';
import 'package:ais_agenda/View/Utilities/rights_helper.dart';
import 'package:ais_agenda/View/Widgets/formview/formview_helper.dart';
import 'package:ais_agenda/View/Widgets/treeview/common/utility/unfocus.dart';
import 'package:ais_agenda/View/Widgets/treeview/questions_treeview/questions_tree_controller.dart';
import 'package:ais_agenda/View/Widgets/treeview/questions_treeview/questions_tree_view.dart';
import 'package:ais_agenda/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage(this.agenda, {Key? key}) : super(key: key);

  final Agenda agenda;

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  late final QuestionsTreeController treeController = QuestionsTreeController();
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();

    AppState().setPreviousNavPath('Повестки > ${widget.agenda.name}');
  }

  @override
  Widget build(BuildContext context) {
    var agendaGroup = AisFormFieldGroup();
    agendaGroup.fields.addAll(widget.agenda.template.fields);

    return QuestionsAppControllerScope(
      controller: treeController,
      child: Shell(
        title: Text(AppState().getPreviousNavPath()),
        actions: <Widget>[
          RightsHelper().getRightsButton(context, widget.agenda),
          Container(
            width: 20,
          ),
          Tooltip(
            message: "Добавить",
            child: TextButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                  const CircleBorder(
                      side: BorderSide(color: Colors.transparent)),
                ),
              ),
              onPressed: () async {
                await showAddQuestionDialog(
                    context, treeController.rootNode, treeController);
              },
              child: const Icon(Icons.add),
            ),
          ),
          Container(
            width: 20,
          ),
        ],
        body: Column(
          children: [
            SizedBox(
              height: GroupUtility.calcGroupHeight(agendaGroup),
              child: FormBuilder(
                key: _formKey,
                // enabled: false,
                onChanged: () {
                  _formKey.currentState!.save();
                },
                autovalidateMode: AutovalidateMode.disabled,

                skipDisabled: true,
                child: FormViewHelper().getFormWidget(context,
                    widget.agenda.template, widget.agenda.template.fields),
              ),
            ),
            const Text('Вопросы'),
            Expanded(
              child: FutureBuilder<void>(
                future: treeController.init(widget.agenda),
                builder: (_, __) {
                  if (treeController.isInitialized) {
                    return const Unfocus(
                      child: QuestionsTreeView(),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _save() {
    // File localFile = File('assets/cfg/forms.json');
    // localFile.writeAsStringSync(jsonEncode(AppState().getForms()));

    // Provider.of<AppState>(context, listen: false).navigateToPage('/forms');

    return true;
  }
}
