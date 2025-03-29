import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ais_model/ais_model.dart';
import 'package:ais_utils/ais_utils.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:global_configuration/global_configuration.dart';

class MeetingPage extends StatefulWidget {
  final Meeting meeting;
  final int timeOffset;
  MeetingPage({Key? key, required this.meeting, required this.timeOffset})
      : super(key: key);

  @override
  _MeetingPageState createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  late Meeting _originalMeeting;
  final _formKey = GlobalKey<FormState>();
  List<Group> _groups = <Group>[];
  List<Agenda> _agendas = <Agenda>[];

  var _tecName = TextEditingController();
  var _tecDescription = TextEditingController();

  @override
  void initState() {
    super.initState();

    _originalMeeting = Meeting.fromJson(jsonDecode(jsonEncode(widget.meeting)));

    loadData();

    _tecName.text = widget.meeting.name;
    _tecDescription.text = widget.meeting.description;
  }

  void loadData() {
    http
        .get(Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            "/groups"))
        .then((response) => {
              setState(() {
                _groups = (json.decode(response.body) as List)
                    .map((data) => Group.fromJson(data))
                    .toList();
              })
            });
    http
        .get(Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            "/agendas"))
        .then((response) => {
              setState(() {
                _agendas = (json.decode(response.body) as List)
                    .map((data) => Agenda.fromJson(data))
                    .toList();
                _agendas.sort((a, b) {
                  return a.createdDate.compareTo(b.createdDate) * -1;
                });
              })
            });
  }

  bool _save() {
    if (_formKey.currentState?.validate() != true) {
      return false;
    }

    widget.meeting.name = _tecName.text;
    widget.meeting.description = _tecDescription.text;
    widget.meeting.lastUpdated = TimeUtil.getDateTimeNow(widget.timeOffset);
    widget.meeting.status = 'Ожидание';

    if (widget.meeting.id == 0) {
      http
          .post(
              Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                  '/meetings'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(widget.meeting.toJson()))
          .then((value) => Navigator.pop(context));
    } else {
      var meetingId = widget.meeting.id;
      http
          .put(
              Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                  '/meetings/$meetingId'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(widget.meeting.toJson()))
          .then((value) => Navigator.pop(context));
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var shouldNavigateBack = true;
        //check for unsaved changes
        if (widget.meeting.name != _tecName.text ||
            widget.meeting.description != _tecDescription.text ||
            widget.meeting.agenda?.id != _originalMeeting.agenda?.id ||
            widget.meeting.group?.id != _originalMeeting.group?.id) {
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
            title: Text(widget.meeting.id == 0
                ? 'Новое заседание'
                : 'Изменить заседание ${_originalMeeting.toString()}'),
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
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                meetingForm(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget meetingForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: _tecName,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Название',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите название';
              }
              return null;
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: TextFormField(
            minLines: 6,
            maxLines: 6,
            controller: _tecDescription,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Описание',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите описание';
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: getAgendaSelector(),
        ),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: getGroupSelector(),
        ),
      ],
    );
  }

  Widget getAgendaSelector() {
    return DropdownSearch<Agenda>(
      // mode: Mode.DIALOG,
      // showSearchBox: true,
      // showClearButton: true,
      items: (filter, infiniteScrollProps) => _agendas,
      // label: 'Повестка',
      // popupTitle: Container(
      //     alignment: Alignment.center,
      //     color: Colors.blueAccent,
      //     padding: EdgeInsets.all(10),
      //     child: Text(
      //       'Повестка',
      //       style: TextStyle(
      //           fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
      //     )),
      // hint: 'Выберите повестку',
      selectedItem: _agendas.firstWhereOrNull(
          (element) => element.id == widget.meeting.agenda?.id),
      onChanged: (value) {
        setState(() {
          widget.meeting.agenda = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Выберите повестку';
        }
        return null;
      },
      dropdownBuilder: agendaDropDownItemBuilder,
      popupProps: PopupProps.menu(
        itemBuilder: agendaItemBuilder,
      ),
      // emptyBuilder: emptyBuilder,
    );
  }

  Widget emptyBuilder(BuildContext context, String? text) {
    return Center(child: Text('Нет данных'));
  }

  Widget agendaDropDownItemBuilder(BuildContext context, Agenda? item) {
    return item == null
        ? Container(
            child: Text(
              'Выберите повестку',
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        : agendaItemBuilder(context, item, false, true);
  }

  Widget agendaItemBuilder(
      BuildContext context, Agenda item, bool isDisabled, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0),
      child: ListTile(
        title: Text(item.name),
        contentPadding: isSelected ? EdgeInsets.all(0) : null,
        subtitle: Row(
          children: [
            Text(
              'дата загрузки: ',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(DateFormat('dd.MM.yyyy').format(item.createdDate.toLocal())),
            Text('\t'),
            Text(
              'время изменения: ',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(DateFormat('dd.MM.yyyy HH:mm:ss')
                .format(item.lastUpdated.toLocal())),
            Text('\t'),
            Text(
              'количество вопросов: ',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(item.questions.length.toString()),
          ],
        ),
      ),
    );
  }

  Widget getGroupSelector() {
    return DropdownSearch<Group>(
      // mode: Mode.DIALOG,
      // showSearchBox: true,
      // showClearButton: true,
      items: (filter, infiniteScrollProps) =>
          _groups.where((element) => element.isActive).toList(),
      // label: 'Группа',
      // popupTitle: Container(
      //     alignment: Alignment.center,
      //     color: Colors.blueAccent,
      //     padding: EdgeInsets.all(10),
      //     child: Text(
      //       'Группа',
      //       style: TextStyle(
      //           fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
      //     )),
      // hint: 'Выберите группу',
      selectedItem: _groups.firstWhereOrNull(
          (element) => element.id == widget.meeting.group?.id),
      onChanged: (value) {
        setState(() {
          widget.meeting.group = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Выберите группу';
        }
        return null;
      },
      dropdownBuilder: groupDropDownItemBuilder,
      popupProps: PopupProps.menu(
        itemBuilder: groupItemBuilder,
      ),
    );
  }

  Widget groupDropDownItemBuilder(BuildContext context, Group? item) {
    return item == null
        ? Container(
            child: Text(
              'Выберите группу',
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        : groupItemBuilder(context, item, false, true);
  }

  Widget groupItemBuilder(
      BuildContext context, Group item, bool isDisabled, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0),
      child: ListTile(
        contentPadding: isSelected ? EdgeInsets.all(0) : null,
        title: Text(item.name),
        subtitle: Row(
          children: [
            Text(
              'количество мест: ',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(item.workplaces.getTotalPlacesCount().toString()),
            Text('\t'),
            Text(
              'количество пользователей: ',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(item.workplaces.getTotalUsersCount().toString()),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tecName.dispose();
    _tecDescription.dispose();

    super.dispose();
  }
}
