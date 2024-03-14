import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ais_model/ais_model.dart';
import 'package:ais_utils/ais_utils.dart';
import 'package:intl/intl.dart';
import 'package:global_configuration/global_configuration.dart';
import 'question_description.dart';
import 'package:uuid/uuid.dart';

class AgendaPage extends StatefulWidget {
  final Agenda agenda;
  final bool isReadOnly;
  final Settings settings;
  AgendaPage({Key key, this.agenda, this.isReadOnly, this.settings})
      : super(key: key);

  @override
  _AgendaPageState createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  var _tecName = TextEditingController();
  var _tecUploadDate = TextEditingController();
  var _tecLastUpdatedDate = TextEditingController();
  var _tecDocumentsDirectory = TextEditingController();
  var _tecEditQuestionName = TextEditingController();
  var _tecEditAgendaName = TextEditingController();
  var _tecEditFileDescription = TextEditingController();
  Question _selectedQuestion;

  @override
  void initState() {
    _tecName.text = widget.agenda.name;
    _tecUploadDate.text =
        DateFormat('dd.MM.yyyy').format(widget.agenda.lastUpdated);
    _tecLastUpdatedDate.text = DateFormat('dd.MM.yyyy HH:mm:ss')
        .format(widget.agenda.lastUpdated.toLocal());
    _tecDocumentsDirectory.text = widget.agenda.folder;

    if (widget.agenda.questions.length > 0 && _selectedQuestion == null) {
      _selectedQuestion = widget.agenda.questions[0];
    }

    widget.agenda.questions.sort((a, b) => a.orderNum.compareTo(b.orderNum));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Назад',
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(widget.isReadOnly
            ? 'Просмотр повестки ${widget.agenda.toString()}'
            : 'Изменить повестку ${widget.agenda.toString()}'),
        centerTitle: true,
        actions: <Widget>[],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              agendaForm(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget agendaForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: TextField(
                    controller: _tecName,
                    style: TextStyle(color: Colors.black45),
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Наименование',
                    ),
                  ),
                ),
              ),
              widget.isReadOnly
                  ? Container()
                  : Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
                      child: Tooltip(
                        message: 'Изменить наименование повестки',
                        child: TextButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              CircleBorder(
                                  side: BorderSide(color: Colors.transparent)),
                            ),
                          ),
                          onPressed: () {
                            showAgendaNameDialog();
                          },
                          child: Icon(Icons.edit),
                        ),
                      ),
                    ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(30, 10, 30, 10),
          child: TextFormField(
            controller: _tecUploadDate,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Дата загрузки',
            ),
            style: TextStyle(color: Colors.black45),
            readOnly: true,
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(30, 10, 30, 10),
          child: TextFormField(
            controller: _tecDocumentsDirectory,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Директория документов повестки',
            ),
            style: TextStyle(color: Colors.black45),
            readOnly: true,
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(30, 10, 30, 10),
          child: TextFormField(
            controller: _tecLastUpdatedDate,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Последнее изменение',
            ),
            style: TextStyle(color: Colors.black45),
            readOnly: true,
          ),
        ),
        getQuestionsSection(),
      ],
    );
  }

  void showAgendaNameDialog() async {
    _tecEditAgendaName.text = widget.agenda.name;
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Изменение наименования повестки'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: _tecEditAgendaName,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Наименование повестки',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Введите наименование повестки';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
              child: TextButton(
                child: Text('Отмена'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            TextButton(
              child: Text('Ок'),
              onPressed: () {
                if (!formKey.currentState.validate()) {
                  return;
                }

                widget.agenda.name = _tecEditAgendaName.text;
                widget.agenda.lastUpdated = DateTime.now();
                http
                    .put(
                        Uri.http(
                            ServerConnection.getHttpServerUrl(
                                GlobalConfiguration()),
                            '/agendas/${widget.agenda.id}'),
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                        },
                        body: jsonEncode(widget.agenda.toJson()))
                    .then((response) {});
                setState(() {
                  _tecName.text = widget.agenda.name;
                  _tecLastUpdatedDate.text = DateFormat('dd.MM.yyyy HH:mm:ss')
                      .format(widget.agenda.lastUpdated.toLocal());
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget getQuestionsSection() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            child: getQuestionsTable(),
            padding: EdgeInsets.fromLTRB(30, 5, 20, 0),
          ),
          getSelectedQuestionDescription(),
        ],
      ),
    );
  }

  Widget getSelectedQuestionDescription() {
    if (_selectedQuestion == null) {
      return Container();
    }
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 10, 15),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Наименование вопроса',
                        labelText: 'Наименование вопроса',
                        hintStyle: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      controller: TextEditingController(
                        text: _selectedQuestion.name,
                      ),
                      style: TextStyle(color: Colors.black45),
                    ),
                  ),
                ),
                widget.isReadOnly
                    ? Container()
                    : Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
                        child: Tooltip(
                          message: 'Изменить наименование вопроса',
                          child: TextButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                CircleBorder(
                                    side:
                                        BorderSide(color: Colors.transparent)),
                              ),
                            ),
                            onPressed: () {
                              showQuestionNameDialog(false);
                            },
                            child: Icon(Icons.edit),
                          ),
                        ),
                      ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 30, 15),
            child: TextField(
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Директория документов вопроса',
                labelText: 'Директория документов вопроса',
                hintStyle: TextStyle(fontStyle: FontStyle.italic),
              ),
              controller: TextEditingController(
                text: _tecDocumentsDirectory.text +
                    '/' +
                    _selectedQuestion.folder,
              ),
              style: TextStyle(color: Colors.black45),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 30, 0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(25, 15, 15, 15),
                    color: Colors.lightBlue,
                    child: Row(
                      children: [
                        Text(
                          'Описание вопроса',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        widget.isReadOnly
                            ? Container()
                            : Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: Tooltip(
                                  message: 'Изменить',
                                  child: TextButton(
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                        CircleBorder(
                                            side: BorderSide(
                                                color: Colors.transparent)),
                                      ),
                                    ),
                                    onPressed: _editSelectedQuestionDescription,
                                    child: Icon(Icons.edit),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          (_selectedQuestion.descriptions == null ||
                  _selectedQuestion.descriptions.length == 0)
              ? Container()
              : Container(
                  color: Colors.black12,
                  margin: EdgeInsets.fromLTRB(0, 0, 30, 10),
                  child: Row(children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                        child: AgendaUtil.getQuestionDescriptionText(
                          _selectedQuestion,
                          14,
                          showHiddenSections: true,
                        ),
                      ),
                    ),
                  ]),
                ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 30, 0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(25, 15, 15, 15),
                    color: Colors.lightBlue,
                    child: Row(
                      children: [
                        Text(
                          'Файлы вопроса',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        widget.isReadOnly
                            ? Container()
                            : Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: Tooltip(
                                  message: 'Добавить',
                                  child: TextButton(
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                        CircleBorder(
                                            side: BorderSide(
                                                color: Colors.transparent)),
                                      ),
                                    ),
                                    onPressed: addSelectedQuestionFile,
                                    child: Icon(Icons.add),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 30, 0),
            child: getFilesTable(),
          ),
        ],
      ),
    );
  }

  Future<void> showQuestionNameDialog(bool isNew) async {
    _tecEditQuestionName.text = isNew ? 'Вопрос' : _selectedQuestion.name;
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              isNew ? 'Создание вопроса' : 'Изменение наименования вопроса'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: _tecEditQuestionName,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Наименование вопроса',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Введите наименование вопроса';
                      }
                      if (widget.agenda.questions
                          .any((element) => element.name == value)) {
                        return 'Вопрос с таким именем уже содержится в повестке';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
              child: TextButton(
                child: Text('Отмена'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            TextButton(
              child: Text('Ок'),
              onPressed: () {
                if (!formKey.currentState.validate()) {
                  return;
                }

                int orderNum = 0;

                if (isNew) {
                  if (_selectedQuestion != null) {
                    widget.agenda.questions.forEach((element) {
                      if (element.orderNum > _selectedQuestion.orderNum) {
                        element.orderNum += 1;
                      }
                    });

                    orderNum = _selectedQuestion.orderNum + 1;
                  } else {
                    if (widget.agenda.questions.length > 0) {
                      orderNum = widget.agenda.questions.last.orderNum + 1;
                    }
                  }

                  setState(() {
                    var newQuestion = Question(
                      name: _tecEditQuestionName.text,
                      orderNum: orderNum,
                      folder: Uuid().v4(),
                      descriptions: <QuestionDescriptionItem>[],
                      agendaId: widget.agenda.id,
                    );

                    http
                        .post(
                            Uri.http(
                                ServerConnection.getHttpServerUrl(
                                    GlobalConfiguration()),
                                '/questions'),
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: jsonEncode(newQuestion.toJson()))
                        .then((response) {
                      widget.agenda.lastUpdated = DateTime.now();
                      http
                          .put(
                              Uri.http(
                                  ServerConnection.getHttpServerUrl(
                                      GlobalConfiguration()),
                                  '/agendas/${widget.agenda.id}'),
                              headers: <String, String>{
                                'Content-Type':
                                    'application/json; charset=UTF-8',
                              },
                              body: jsonEncode(widget.agenda.toJson()))
                          .then((response) {});
                      setState(() {
                        _tecLastUpdatedDate.text =
                            DateFormat('dd.MM.yyyy HH:mm:ss')
                                .format(widget.agenda.lastUpdated.toLocal());
                      });

                      var insertedQuestion =
                          Question.fromJson(json.decode(response.body));
                      setState(() {
                        widget.agenda.questions.add(insertedQuestion);
                        widget.agenda.questions
                            .sort((a, b) => a.orderNum.compareTo(b.orderNum));
                        _selectedQuestion = insertedQuestion;
                      });

                      Navigator.of(context).pop();
                    }).catchError((e) {
                      Navigator.of(context).pop();

                      Utility().showMessageOkDialog(context,
                          title: 'Ошибка',
                          message: TextSpan(
                            text:
                                'В ходе создания вопроса ${newQuestion.name} возникла ошибка: $e',
                          ),
                          okButtonText: 'Ок');
                    });
                  });
                } else {
                  setState(() {
                    _selectedQuestion.name = _tecEditQuestionName.text;
                  });
                  http
                      .put(
                          Uri.http(
                              ServerConnection.getHttpServerUrl(
                                  GlobalConfiguration()),
                              '/questions/${_selectedQuestion.id}'),
                          headers: <String, String>{
                            'Content-Type': 'application/json; charset=UTF-8',
                          },
                          body: jsonEncode(_selectedQuestion.toJson()))
                      .then((response) {});

                  widget.agenda.lastUpdated = DateTime.now();
                  http
                      .put(
                          Uri.http(
                              ServerConnection.getHttpServerUrl(
                                  GlobalConfiguration()),
                              '/agendas/${widget.agenda.id}'),
                          headers: <String, String>{
                            'Content-Type': 'application/json; charset=UTF-8',
                          },
                          body: jsonEncode(widget.agenda.toJson()))
                      .then((response) {});
                  setState(() {
                    _tecLastUpdatedDate.text = DateFormat('dd.MM.yyyy HH:mm:ss')
                        .format(widget.agenda.lastUpdated.toLocal());
                  });

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void addSelectedQuestionFile() async {
    // FilePickerCross fileToAdd = await FilePickerCross.importFromStorage(
    //         type: FileTypeCross.custom, fileExtension: 'pdf')
    //     .catchError((onError) {});

    // if (fileToAdd == null) {
    //   return;
    // }

    // if (_selectedQuestion.files
    //     .any((element) => element.fileName == fileToAdd.fileName)) {
    //   Utility().showMessageOkDialog(context,
    //       title: 'Загрузка файла',
    //       message: TextSpan(
    //         text:
    //             'Вопрос уже содержит файл с именем ${fileToAdd.fileName}\nЗагрузка будет отменена.',
    //       ),
    //       okButtonText: 'Ок');
    //   return;
    // }

    // showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (BuildContext context) {
    //       return Dialog(
    //         child: Row(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             CircularProgressIndicator(),
    //             Padding(
    //                 padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
    //                 child: Text("Загрузка файла ${fileToAdd.fileName}")),
    //           ],
    //         ),
    //       );
    //     });

    // var folderName = _selectedQuestion.folder;
    // var agendaFolderName = _tecDocumentsDirectory.text;
    // var request = http.MultipartRequest('POST',
    //     Uri.parse(ServerConnection.getFileServerUploadUrl(widget.settings)));

    // request.fields['agendaName'] = '$agendaFolderName';
    // request.fields['folderName'] = '$folderName';

    // request.files
    //     .add(await http.MultipartFile.fromPath('file', fileToAdd.path));

    // await request.send().timeout(Duration(seconds: 10)).then((value) {
    //   Navigator.pop(context);

    //   var questionFile = QuestionFile(
    //       fileName: fileToAdd.fileName,
    //       version: Uuid().v4(),
    //       description: fileToAdd.fileName,
    //       relativePath: agendaFolderName + '/' + _selectedQuestion.folder,
    //       questionId: _selectedQuestion.id);

    //   http
    //       .post(
    //           Uri.http(
    //               ServerConnection.getHttpServerUrl(GlobalConfiguration()) +
    //                   '/questionfiles'),
    //           headers: <String, String>{
    //             'Content-Type': 'application/json; charset=UTF-8',
    //           },
    //           body: jsonEncode(questionFile.toJson()))
    //       .then((response) {
    //     var insertedQuestionFile =
    //         QuestionFile.fromJson(json.decode(response.body));
    //     setState(() {
    //       _selectedQuestion.files.add(insertedQuestionFile);
    //     });
    //   });

    //   Utility().showMessageOkDialog(context,
    //       title: 'Загрузка файла',
    //       message: TextSpan(
    //         text: 'Загрузка файла ${fileToAdd.fileName} успешно завершена',
    //       ),
    //       okButtonText: 'Ок');
    // }).catchError((e) {
    //   Utility().showMessageOkDialog(context,
    //       title: 'Загрузка файла',
    //       message: TextSpan(
    //         text:
    //             'В ходе загрузки файла ${fileToAdd.fileName}  возникла ошибка: {$e}',
    //       ),
    //       okButtonText: 'Ок');
    // });
  }

  Widget getFilesTable() {
    if (_selectedQuestion.files == null ||
        _selectedQuestion.files.length == 0) {
      return Container();
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: DataTable(
            showCheckboxColumn: false,
            dataRowColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              return Colors.black12;
            }),
            columns: [
              DataColumn(
                label: Text(
                  'Имя файла',
                ),
              ),
              DataColumn(
                label: Text(
                  'Описание',
                ),
              ),
            ],
            rows: _selectedQuestion.files
                .map(
                  ((element) => DataRow(
                        cells: <DataCell>[
                          DataCell(
                            Text(element.fileName),
                          ),
                          DataCell(
                            Row(
                              children: [
                                Expanded(
                                  child: Wrap(children: [
                                    Tooltip(
                                      message: element.description,
                                      child: Text(element.description,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          softWrap: true),
                                    ),
                                  ]),
                                ),
                                widget.isReadOnly
                                    ? Container()
                                    : Tooltip(
                                        message: 'Изменить описание',
                                        child: TextButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.transparent),
                                            foregroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.black),
                                            overlayColor:
                                                MaterialStateProperty.all(
                                                    Colors.black12),
                                            shape: MaterialStateProperty.all(
                                              CircleBorder(
                                                  side: BorderSide(
                                                      color:
                                                          Colors.transparent)),
                                            ),
                                          ),
                                          onPressed: () {
                                            showFileDescriptionDialog(element);
                                          },
                                          child: Icon(Icons.edit),
                                        ),
                                      ),
                                widget.isReadOnly
                                    ? Container()
                                    : Tooltip(
                                        message: 'Удалить файл',
                                        child: TextButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.transparent),
                                            foregroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.black),
                                            overlayColor:
                                                MaterialStateProperty.all(
                                                    Colors.black12),
                                            shape: MaterialStateProperty.all(
                                              CircleBorder(
                                                  side: BorderSide(
                                                      color:
                                                          Colors.transparent)),
                                            ),
                                          ),
                                          onPressed: () {
                                            removeFile(element);
                                          },
                                          child: Icon(Icons.delete),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      )),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  void showFileDescriptionDialog(QuestionFile file) async {
    _tecEditFileDescription.text = file.description;
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Изменение описания файла'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: _tecEditFileDescription,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Описание файла',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Введите описание файла';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
              child: TextButton(
                child: Text('Отмена'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            TextButton(
              child: Text('Ок'),
              onPressed: () {
                if (!formKey.currentState.validate()) {
                  return;
                }
                file.description = _tecEditFileDescription.text;

                http
                    .put(
                        Uri.http(ServerConnection.getHttpServerUrl(
                                GlobalConfiguration()),
                            '/questionfiles/${file.id}'),
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                        },
                        body: jsonEncode(file.toJson()))
                    .then((response) {});

                // update agenda lastUpdated
                widget.agenda.lastUpdated = DateTime.now();
                http
                    .put(
                        Uri.http(ServerConnection.getHttpServerUrl(
                                GlobalConfiguration()),
                            '/agendas/${widget.agenda.id}'),
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                        },
                        body: jsonEncode(widget.agenda.toJson()))
                    .then((response) {});
                setState(() {
                  _tecName.text = widget.agenda.name;
                  _tecLastUpdatedDate.text = DateFormat('dd.MM.yyyy HH:mm:ss')
                      .format(widget.agenda.lastUpdated.toLocal());
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void removeFile(QuestionFile file) {
    http.delete(
        Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            '/questionfiles/${file.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        }).then((response) {
      _selectedQuestion.files.remove(file);
      setState(() {});
    }).catchError((e) {
      Utility().showMessageOkDialog(context,
          title: 'Ошибка',
          message: TextSpan(
            text:
                'В ходе удаления файла вопроса ${file.fileName} возникла ошибка: $e',
          ),
          okButtonText: 'Ок');
    });
  }

  void _editSelectedQuestionDescription() {
    if (_selectedQuestion != null) {
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      QuestionDescriptionPage(question: _selectedQuestion)))
          .then((value) {
        setState(() {
          _selectedQuestion = _selectedQuestion;
        });
        initState();
      });
    }
  }

  ScrollController _questionsScrollController = new ScrollController();

  Widget getQuestionsTable() {
    return Column(
      children: [
        Container(
          color: Colors.lightBlue,
          width: 460,
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 20,
              ),
              Text(
                'Вопросы',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              Container(width: _selectedQuestion == null ? 267 : 155),
              widget.isReadOnly
                  ? Container()
                  : Row(
                      children: [
                        _selectedQuestion == null
                            ? Container()
                            : Tooltip(
                                message: 'Переместить выбранный вопрос вверх',
                                child: TextButton(
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(
                                      CircleBorder(
                                          side: BorderSide(
                                              color: Colors.transparent)),
                                    ),
                                  ),
                                  onPressed: () {
                                    upQuestion();
                                  },
                                  child: Icon(Icons.arrow_upward),
                                ),
                              ),
                        _selectedQuestion == null
                            ? Container()
                            : Tooltip(
                                message: 'Переместить выбранный вопрос вниз',
                                child: TextButton(
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(
                                      CircleBorder(
                                          side: BorderSide(
                                              color: Colors.transparent)),
                                    ),
                                  ),
                                  onPressed: () {
                                    downQuestion();
                                  },
                                  child: Icon(Icons.arrow_downward),
                                ),
                              ),
                        Tooltip(
                          message: 'Добавить',
                          child: TextButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                CircleBorder(
                                    side:
                                        BorderSide(color: Colors.transparent)),
                              ),
                            ),
                            onPressed: () {
                              showQuestionNameDialog(true);
                            },
                            child: Icon(Icons.add),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
        Container(
          width: 460,
          height: 550,
          child: Scrollbar(
            thumbVisibility: true,
            controller: _questionsScrollController,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: _questionsScrollController,
              child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 0,
                dataRowColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected))
                    return Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.3);
                  return null;
                }),
                columns: [
                  DataColumn(label: Container()),
                ],
                rows: widget.agenda.questions
                    .map(
                      ((element) => DataRow(
                            cells: <DataCell>[
                              DataCell(
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(element.toString()),
                                    ),
                                    widget.isReadOnly
                                        ? Container()
                                        : Tooltip(
                                            message: 'Удалить вопрос',
                                            child: TextButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.transparent),
                                                foregroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.black),
                                                overlayColor:
                                                    MaterialStateProperty.all(
                                                        Colors.black12),
                                                shape:
                                                    MaterialStateProperty.all(
                                                  CircleBorder(
                                                      side: BorderSide(
                                                          color: Colors
                                                              .transparent)),
                                                ),
                                              ),
                                              onPressed: () {
                                                removeQuestion(element);
                                              },
                                              child: Icon(Icons.delete),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ],
                            selected: element == _selectedQuestion,
                            onSelectChanged: (bool value) {
                              setState(() {
                                if (value) {
                                  // _selectedQuestion = element;
                                  if (_selectedQuestion != element) {
                                    _selectedQuestion = element;
                                  }
                                } else {
                                  if (_selectedQuestion == element) {}
                                  _selectedQuestion = null;
                                }
                              });
                            },
                          )),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void upQuestion() {
    var index = widget.agenda.questions.indexOf(_selectedQuestion);

    if (index >= 1) {
      widget.agenda.questions[index - 1].orderNum += 1;
      _selectedQuestion.orderNum -= 1;
    }

    widget.agenda.questions.sort((a, b) => a.orderNum.compareTo(b.orderNum));

    widget.agenda.lastUpdated = DateTime.now();
    http
        .put(
            Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                '/agendas/${widget.agenda.id}'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(widget.agenda.toJson()))
        .then((response) {
      setState(() {
        _tecLastUpdatedDate.text = DateFormat('dd.MM.yyyy HH:mm:ss')
            .format(widget.agenda.lastUpdated.toLocal());
      });
    });
  }

  void downQuestion() {
    var index = widget.agenda.questions.indexOf(_selectedQuestion);

    if (index < widget.agenda.questions.length) {
      widget.agenda.questions[index + 1].orderNum -= 1;
      _selectedQuestion.orderNum += 1;
    }

    widget.agenda.questions.sort((a, b) => a.orderNum.compareTo(b.orderNum));

    widget.agenda.lastUpdated = DateTime.now();
    http
        .put(
            Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                '/agendas/${widget.agenda.id}'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(widget.agenda.toJson()))
        .then((response) {
      setState(() {
        _tecLastUpdatedDate.text = DateFormat('dd.MM.yyyy HH:mm:ss')
            .format(widget.agenda.lastUpdated.toLocal());
      });
    });
  }

  void removeQuestion(Question question) {
    http.delete(
        Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            '/questions/${question.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        }).then((response) {
      widget.agenda.questions.remove(question);

      if (_selectedQuestion == question) {
        _selectedQuestion = null;
      }
      setState(() {});
    }).catchError((e) {
      Utility().showMessageOkDialog(context,
          title: 'Ошибка',
          message: TextSpan(
            text:
                'В ходе удаления вопроса ${question.name} возникла ошибка: $e',
          ),
          okButtonText: 'Ок');
    });
  }

  @override
  void dispose() {
    _tecName.dispose();
    _tecUploadDate.dispose();
    _tecLastUpdatedDate.dispose();
    _tecDocumentsDirectory.dispose();
    _tecEditQuestionName.dispose();
    _tecEditAgendaName.dispose();
    _tecEditFileDescription.dispose();

    super.dispose();
  }
}
