import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ais_model/ais_model.dart';
import 'package:ais_utils/ais_utils.dart';
import 'package:global_configuration/global_configuration.dart';

class QuestionDescriptionPage extends StatefulWidget {
  final Question question;
  QuestionDescriptionPage({Key? key, required this.question}) : super(key: key);

  @override
  _QuestionDescriptionPageState createState() =>
      _QuestionDescriptionPageState();
}

class _QuestionDescriptionPageState extends State<QuestionDescriptionPage> {
  late Question _originalQuestion;
  final _formKey = GlobalKey<FormState>();
  var _captionControllers = <TextEditingController>[];
  var _textControllers = <TextEditingController>[];

  @override
  void initState() {
    super.initState();

    _originalQuestion =
        Question.fromJson(jsonDecode(jsonEncode(widget.question)));
  }

  bool _save() {
    if (_formKey.currentState?.validate() != true) {
      return false;
    }

    var questionId = widget.question.id;
    http
        .put(
            Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                '/questionDescription/$questionId'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(widget.question.toJson()))
        .then((value) => Navigator.pop(context));
    return true;
  }

  Widget getDescriptionItemControl(QuestionDescriptionItem item) {
    var index = widget.question.descriptions.indexOf(item);

    TextEditingController captionController;
    if (_captionControllers.length > index) {
      captionController = _captionControllers[index];
      captionController.text = item.caption;
    } else {
      captionController = TextEditingController(text: item.caption);
      _captionControllers.add(captionController);
    }
    TextEditingController textController;
    if (_textControllers.length > index) {
      textController = _textControllers[index];
      textController.text = item.text;
    } else {
      textController = TextEditingController(text: item.text);
      _textControllers.add(textController);
    }

    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.lightBlue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Tooltip(
                  message: 'Переместить секцию вверх',
                  child: TextButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        CircleBorder(
                            side: BorderSide(color: Colors.transparent)),
                      ),
                    ),
                    onPressed: () {
                      up(item);
                    },
                    child: Icon(Icons.arrow_upward),
                  ),
                ),
                Tooltip(
                  message: 'Переместить секцию вниз',
                  child: TextButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        CircleBorder(
                            side: BorderSide(color: Colors.transparent)),
                      ),
                    ),
                    onPressed: () {
                      down(item);
                    },
                    child: Icon(Icons.arrow_downward),
                  ),
                ),
                Tooltip(
                  message: 'Удалить',
                  child: TextButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        CircleBorder(
                            side: BorderSide(color: Colors.transparent)),
                      ),
                    ),
                    onPressed: () async {
                      var noButtonPressed = false;
                      var title = 'Удалить описание';

                      await Utility().showYesNoDialog(
                        context,
                        title: title,
                        message: TextSpan(
                          text:
                              'Вы уверены, что хотите ${title.toLowerCase()}?',
                        ),
                        yesButtonText: 'Да',
                        yesCallBack: () {
                          Navigator.of(context).pop();
                        },
                        noButtonText: 'Нет',
                        noCallBack: () {
                          noButtonPressed = true;
                          Navigator.of(context).pop();
                        },
                      );

                      if (noButtonPressed) {
                        return;
                      }

                      remove(item);
                    },
                    child: Icon(Icons.delete),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: TextFormField(
              controller: captionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Заголовок',
              ),
              validator: (value) {
                Scrollable.ensureVisible(context);
                if (value == null ||
                    value.isEmpty && textController.text.isEmpty) {
                  return 'Введите заголовок и/или текст';
                }

                return null;
              },
              onChanged: (value) {
                item.caption = value;
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: TextFormField(
              controller: textController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Текст',
              ),
              validator: (value) {
                if (value == null ||
                    value.isEmpty && captionController.text.isEmpty) {
                  return 'Введите заголовок и/или текст';
                }
                return null;
              },
              onChanged: (value) {
                item.text = value;
              },
            ),
          ),
        ],
      ),
    );
  }

  void up(QuestionDescriptionItem item) {
    var index = widget.question.descriptions.indexOf(item);
    if (index > 0) {
      var item1 = widget.question.descriptions[index - 1];
      var item2 = widget.question.descriptions[index];

      widget.question.descriptions[index - 1] = item2;
      widget.question.descriptions[index] = item1;

      setState(() {});
    }
  }

  void down(QuestionDescriptionItem item) {
    var index = widget.question.descriptions.indexOf(item);
    if (index < widget.question.descriptions.length) {
      var item1 = widget.question.descriptions[index];
      var item2 = widget.question.descriptions[index + 1];

      widget.question.descriptions[index] = item2;
      widget.question.descriptions[index + 1] = item1;

      setState(() {});
    }
  }

  void remove(QuestionDescriptionItem item) {
    setState(() {
      widget.question.descriptions.remove(item);
    });
  }

  void add() {
    setState(() {
      widget.question.descriptions.add(QuestionDescriptionItem(
        caption: '',
        text: '',
        showInReports: false,
        showOnStoreboard: false,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var shouldNavigateBack = true;
        //check for unsaved changes
        if (jsonEncode(widget.question.descriptions) !=
            jsonEncode(_originalQuestion.descriptions)) {
          await Utility().showYesNoDialog(
            context,
            title: 'Проверка',
            message: TextSpan(
              text: 'Имеются несохраненные изменения. Сохранить?',
            ),
            yesButtonText: 'Да',
            yesCallBack: () {
              if (!_save()) {
                shouldNavigateBack = false;
                Navigator.of(context).pop();
              }
            },
            noButtonText: 'Нет',
            noCallBack: () {
              widget.question.descriptions = _originalQuestion.descriptions;
              Navigator.of(context).pop();
            },
          );
        }

        //trigger leaving and use own data
        if (shouldNavigateBack) {
          Navigator.pop(context, false);
        }

        //we need to return a future
        return Future.value(false);
      },
      child: Form(
        key: _formKey,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Назад',
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: Text('Описание вопроса: ' + widget.question.name),
            centerTitle: true,
            actions: <Widget>[
              Tooltip(
                message: 'Сохранить',
                child: TextButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      CircleBorder(side: BorderSide(color: Colors.transparent)),
                    ),
                  ),
                  onPressed: _save,
                  child: Icon(Icons.save),
                ),
              ),
              Container(
                width: 20,
              ),
            ],
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  questionForm(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget questionForm(BuildContext context) {
    var descriptionControls = <Widget>[];

    for (var descriptionItem in widget.question.descriptions) {
      descriptionControls.add(getDescriptionItemControl(descriptionItem));
    }

    descriptionControls.add(Container(
        width: 160,
        margin: EdgeInsets.all(20),
        child: TextButton(
          onPressed: () {
            add();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Добавить',
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
              Icon(
                Icons.add,
              ),
            ],
          ),
        )));

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: descriptionControls,
    );
  }

  @override
  void dispose() {
    for (var captionController in _captionControllers) {
      captionController.dispose();
    }
    for (var textController in _textControllers) {
      textController.dispose();
    }

    super.dispose();
  }
}
