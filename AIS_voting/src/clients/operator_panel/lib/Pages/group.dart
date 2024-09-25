import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ais_model/ais_model.dart';
import 'package:ais_utils/ais_utils.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:global_configuration/global_configuration.dart';

class GroupPage extends StatefulWidget {
  final Group group;
  final bool isReadOnly;
  GroupPage({Key? key, required this.group, required this.isReadOnly})
      : super(key: key);

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final dropDownKeyManager = GlobalKey<DropdownSearchState>();
  final dropDownKeyDeputy = GlobalKey<DropdownSearchState>();
  final dropDownKeyWorkplacesUser = GlobalKey<DropdownSearchState>();
  final dropDownKeyManagementUser = GlobalKey<DropdownSearchState>();

  late Group _originalGroup;

  var _users = <User>[];
  final _formKey = GlobalKey<FormState>();

  var _tecName = TextEditingController();
  var _tecLawUsersCount = TextEditingController();
  var _tecQuorumCount = TextEditingController();
  var _tecMajorityCount = TextEditingController();
  var _tecOneThirdsCount = TextEditingController();
  var _tecTwoThirdsCount = TextEditingController();
  var _tecChosenCount = TextEditingController();
  var _tecMajorityChosenCount = TextEditingController();
  var _tecOneThirdsChosenCount = TextEditingController();
  var _tecTwoThirdsChosenCount = TextEditingController();
  var _tecManagementCount = TextEditingController();
  var _tecTribuneCount = TextEditingController();
  var _tecRows = <TextEditingController>[];
  var _managementTerminalIdControllers = <TextEditingController>[];
  var _tribuneTerminalIdControllers = <TextEditingController>[];
  var _tribuneNameControllers = <TextEditingController>[];
  var _workplacesTerminalIdControllers = <List<TextEditingController>>[];
  var _tecUnblockedMics = TextEditingController();
  var _tecMicsNotActiveFrom = TextEditingController();
  var _tecManagerTerminal = TextEditingController();
  var _guestController = TextEditingController();

  var _guests = <String>[];

  @override
  void initState() {
    super.initState();

    _originalGroup = Group.fromJson(jsonDecode(jsonEncode(widget.group)));

    _tabController = TabController(vsync: this, length: 4);
    _tabController.addListener(() {
      setState(() {});
    });

    _tecName.text = widget.group.name;
    _tecLawUsersCount.text = widget.group.lawUsersCount.toString();
    _tecQuorumCount.text = widget.group.quorumCount.toString();
    _tecMajorityCount.text = widget.group.majorityCount.toString();
    _tecOneThirdsCount.text = widget.group.oneThirdsCount.toString();
    _tecTwoThirdsCount.text = widget.group.twoThirdsCount.toString();
    _tecChosenCount.text = widget.group.chosenCount.toString();
    _tecMajorityChosenCount.text = widget.group.majorityChosenCount.toString();
    _tecOneThirdsChosenCount.text =
        widget.group.oneThirdsChosenCount.toString();
    _tecTwoThirdsChosenCount.text =
        widget.group.twoThirdsChosenCount.toString();
    _tecManagementCount.text =
        widget.group.workplaces.managementPlacesCount.toString();
    _tecTribuneCount.text =
        widget.group.workplaces.tribunePlacesCount.toString();
    _tecUnblockedMics.text = widget.group.unblockedMics;
    _tecOneThirdsChosenCount.text =
        widget.group.oneThirdsChosenCount.toString();
    _tecMicsNotActiveFrom.text = widget.group.MicsNotActiveFrom.toString();
    _tecManagerTerminal.text = widget.group.managerTerminal.toString();

    for (int i = 0;
        i < widget.group.workplaces.managementTerminalIds.length;
        i++) {
      var text = widget.group.workplaces.managementTerminalIds[i] == null
          ? ""
          : widget.group.workplaces.managementTerminalIds[i].toString();
      _managementTerminalIdControllers.add(TextEditingController(text: text));
    }

    for (int i = 0; i < widget.group.workplaces.tribunePlacesCount; i++) {
      var terminalId = widget.group.workplaces.tribuneTerminalIds[i] == null
          ? ""
          : widget.group.workplaces.tribuneTerminalIds[i];
      _tribuneTerminalIdControllers
          .add(TextEditingController(text: terminalId));
      var tribuneName = widget.group.workplaces.tribuneNames[i] == null
          ? ""
          : widget.group.workplaces.tribuneNames[i];
      _tribuneNameControllers.add(TextEditingController(text: tribuneName));
    }

    for (int i = 0;
        i < widget.group.workplaces.workplacesTerminalIds.length;
        i++) {
      List<TextEditingController> workplaceControllers =
          <TextEditingController>[];
      for (int j = 0;
          j < widget.group.workplaces.workplacesTerminalIds[i].length;
          j++) {
        var text = widget.group.workplaces.workplacesTerminalIds[i][j] == null
            ? ""
            : widget.group.workplaces.workplacesTerminalIds[i][j].toString();
        workplaceControllers.add(TextEditingController(text: text));
      }

      _workplacesTerminalIdControllers.add(workplaceControllers);
    }

    loadUsers();
    loadGuests();
  }

  void loadUsers() {
    http
        .get(Uri.http(
            ServerConnection.getHttpServerUrl(GlobalConfiguration()), "/users"))
        .then((response) => {
              setState(() {
                _users = (json.decode(response.body) as List)
                    .map((data) => User.fromJson(data))
                    .where((element) => element.isVoter)
                    .toList();
              })
            });
  }

  void loadGuests() {
    _guests = (widget.group.guests ?? '').split(',').toList();
    _guests.sort((a, b) => a.compareTo(b));
  }

  // Flutter form validation not propely working with tabs
  String? _vmName;
  String? _vmIsLawUsersCount;
  String? _vmQuorumCount;
  String? _vmMajorityCount;
  String? _vmOneThirdsCount;
  String? _vmTwoThirdsCount;
  String? _vmChosenCount;
  String? _vmMajorityChosenCount;
  String? _vmOneThirdsChosenCount;
  String? _vmTwoThirdsChosenCount;
  String? _vmManagementCount;
  String? _vmTribuneCount;
  String? _vmUnblockedMics;
  String? _vmMicsNotActiveFrom;
  String? _vmManagerTerminal;

  bool validateWithErrors() {
    _vmName = null;
    _vmIsLawUsersCount = null;
    _vmQuorumCount = null;
    _vmMajorityCount = null;
    _vmOneThirdsCount = null;
    _vmTwoThirdsCount = null;
    _vmChosenCount = null;
    _vmMajorityChosenCount = null;
    _vmOneThirdsChosenCount = null;
    _vmTwoThirdsChosenCount = null;
    _vmManagementCount = null;
    _vmTribuneCount = null;
    _vmUnblockedMics = null;
    _vmMicsNotActiveFrom = null;
    _vmManagerTerminal = null;

    var wasDuplicate = false;

    // check edit fields
    if (_tecName.text.isEmpty) {
      _vmName = 'Введите название';
    }

    if (_tecLawUsersCount.text.isEmpty) {
      _vmIsLawUsersCount = 'Введите значение';
    }
    if (int.tryParse(_tecLawUsersCount.text) == null) {
      _vmIsLawUsersCount = 'Введите целое число больше 0';
    } else if ((int.tryParse(_tecLawUsersCount.text) ?? 0) < 1) {
      _vmIsLawUsersCount = 'Введите целое число больше 0';
    }

    if (_tecQuorumCount.text.isEmpty) {
      _vmQuorumCount = 'Введите значение';
    }
    if (int.tryParse(_tecQuorumCount.text) == null) {
      _vmQuorumCount = 'Введите целое число';
    }

    if (_tecMajorityCount.text.isEmpty) {
      _vmMajorityCount = 'Введите значение';
    }
    if (int.tryParse(_tecMajorityCount.text) == null) {
      _vmMajorityCount = 'Введите целое число';
    }

    if (_tecOneThirdsCount.text.isEmpty) {
      _vmOneThirdsCount = 'Введите значение';
    }
    if (int.tryParse(_tecOneThirdsCount.text) == null) {
      _vmOneThirdsCount = 'Введите целое число';
    }

    if (_tecOneThirdsCount.text.isEmpty) {
      _vmOneThirdsCount = 'Введите значение';
    }
    if (int.tryParse(_tecOneThirdsCount.text) == null) {
      _vmOneThirdsCount = 'Введите целое число';
    }

    if (_tecChosenCount.text.isEmpty) {
      _vmChosenCount = 'Введите значение';
    }
    if (int.tryParse(_tecChosenCount.text) == null) {
      _vmChosenCount = 'Введите целое число';
    }

    if (_tecMajorityChosenCount.text.isEmpty) {
      _vmMajorityChosenCount = 'Введите значение';
    }
    if (int.tryParse(_tecMajorityChosenCount.text) == null) {
      _vmMajorityChosenCount = 'Введите целое число';
    }

    if (_tecOneThirdsChosenCount.text.isEmpty) {
      _vmOneThirdsChosenCount = 'Введите значение';
    }
    if (int.tryParse(_tecOneThirdsChosenCount.text) == null) {
      _vmOneThirdsChosenCount = 'Введите целое число';
    }

    if (_tecOneThirdsChosenCount.text.isEmpty) {
      _vmOneThirdsChosenCount = 'Введите значение';
    }
    if (int.tryParse(_tecOneThirdsChosenCount.text) == null) {
      _vmOneThirdsChosenCount = 'Введите целое число';
    }

    if (_tecManagementCount.text.isEmpty) {
      _vmManagementCount = 'Введите значение';
    }
    if (int.tryParse(_tecManagementCount.text) == null) {
      _vmManagementCount = 'Введите целое число';
    }

    if (_tecTribuneCount.text.isEmpty) {
      _vmTribuneCount = 'Введите значение';
    }
    if (int.tryParse(_tecTribuneCount.text) == null) {
      _vmTribuneCount = 'Введите целое число';
    }

    if (_tecMicsNotActiveFrom.text.isEmpty) {
      _vmMicsNotActiveFrom = 'Введите значение';
    }
    if (int.tryParse(_tecMicsNotActiveFrom.text) == null) {
      _vmMicsNotActiveFrom = 'Введите целое число';
    }

    if (_tecManagerTerminal.text.isEmpty) {
      _vmManagerTerminal = 'Введите значение';
    }

    if (_tecUnblockedMics.text.isNotEmpty) {
      var parts = _tecUnblockedMics.text.split(',').toList();
      for (var i = 0; i < parts.length; i++) {
        if (int.tryParse(parts[i]) == null) {
          _vmUnblockedMics =
              'Введите ИД терминалов разделенных запятыми\nнапример: 001,002, ... ,0xx';
          break;
        }
      }
    }

    var result = !wasDuplicate &&
        _vmName == null &&
        _vmIsLawUsersCount == null &&
        _vmQuorumCount == null &&
        _vmMajorityCount == null &&
        _vmOneThirdsCount == null &&
        _vmTwoThirdsCount == null &&
        _vmManagementCount == null &&
        _vmTribuneCount == null &&
        _vmUnblockedMics == null &&
        _vmChosenCount == null &&
        _vmMicsNotActiveFrom == null &&
        _vmManagerTerminal == null;

    setState(() {
      if (!result) {
        if (wasDuplicate) {
          _tabController.index = 0;
        } else if (_vmManagementCount == null || _vmTribuneCount == null) {
          _tabController.index = 3;
        } else {
          _tabController.index = 2;
        }
      }
    });

    return result;
  }

  Future<bool> validateWithWarnings() async {
    var warningText = '';

    if (widget.group.workplaces.getTotalPlacesCount() !=
        widget.group.workplaces.getTotalUsersCount()) {
      warningText += 'На схеме зала имеются не заполненные рабочие места.\n';
    }

    if (warningText.isNotEmpty) {
      var noButtonPressed = false;
      await Utility().showYesNoDialog(
        context,
        title: 'Сохранение',
        message: TextSpan(
          text: '$warningTextВы уверены, что завершили работу с группой?',
        ),
        yesButtonText: 'Да',
        yesCallBack: () {
          Navigator.pop(context);
        },
        noButtonText: 'Нет',
        noCallBack: () {
          noButtonPressed = true;
          Navigator.pop(context);
        },
      );

      if (noButtonPressed) {
        return false;
      }
    }

    return true;
  }

  Future<bool> _save() async {
    if (!validateWithErrors()) {
      return false;
    }

    if (!(await validateWithWarnings())) {
      return false;
    }

    widget.group.name = _tecName.text;
    widget.group.unblockedMics = _tecUnblockedMics.text;
    widget.group.MicsNotActiveFrom = int.parse(_tecMicsNotActiveFrom.text);
    widget.group.managerTerminal = _tecManagerTerminal.text;
    widget.group.lawUsersCount = int.parse(_tecLawUsersCount.text);
    widget.group.quorumCount = int.parse(_tecQuorumCount.text);
    widget.group.majorityCount = int.parse(_tecMajorityCount.text);
    widget.group.oneThirdsCount = int.parse(_tecOneThirdsCount.text);
    widget.group.twoThirdsCount = int.parse(_tecTwoThirdsCount.text);
    widget.group.chosenCount = int.parse(_tecChosenCount.text);
    widget.group.majorityChosenCount = int.parse(_tecMajorityChosenCount.text);
    widget.group.oneThirdsChosenCount =
        int.parse(_tecOneThirdsChosenCount.text);
    widget.group.twoThirdsChosenCount =
        int.parse(_tecTwoThirdsChosenCount.text);

    if (widget.group.id == 0) {
      http
          .post(
              Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                  '/groups'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(widget.group.toJson()))
          .then((value) => Navigator.pop(context));
    } else {
      var groupId = widget.group.id;
      http
          .put(
              Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                  '/groups/$groupId'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(widget.group.toJson()))
          .then((value) => Navigator.pop(context));
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var yesButtonPressed = false;

        if (widget.group.name != _tecName.text ||
            widget.group.unblockedMics != _tecUnblockedMics.text ||
            widget.group.MicsNotActiveFrom.toString() !=
                _tecMicsNotActiveFrom.text ||
            widget.group.managerTerminal.toString() !=
                _tecManagerTerminal.text ||
            widget.group.lawUsersCount.toString() != _tecLawUsersCount.text ||
            widget.group.quorumCount.toString() != _tecQuorumCount.text ||
            widget.group.majorityCount.toString() != _tecMajorityCount.text ||
            widget.group.oneThirdsCount.toString() != _tecOneThirdsCount.text ||
            widget.group.twoThirdsCount.toString() != _tecTwoThirdsCount.text ||
            widget.group.chosenCount.toString() != _tecChosenCount.text ||
            widget.group.majorityChosenCount.toString() !=
                _tecMajorityChosenCount.text ||
            widget.group.oneThirdsChosenCount.toString() !=
                _tecOneThirdsChosenCount.text ||
            widget.group.twoThirdsChosenCount.toString() !=
                _tecTwoThirdsChosenCount.text ||
            _originalGroup.roundingRoule != widget.group.roundingRoule ||
            _originalGroup.managerRoule != widget.group.managerRoule ||
            _originalGroup.isManagerCastingVote !=
                widget.group.isManagerCastingVote ||
            _originalGroup.isDeputyAutoRegistration !=
                widget.group.isDeputyAutoRegistration ||
            _originalGroup.isFastRegistrationUsed !=
                widget.group.isFastRegistrationUsed ||
            _originalGroup.isManagerAutoRegistration !=
                widget.group.isManagerAutoRegistration ||
            _originalGroup.isActive != widget.group.isActive ||
            _originalGroup.guests != widget.group.guests ||
            jsonEncode(_originalGroup.workplaces) !=
                jsonEncode(widget.group.workplaces) ||
            jsonEncode(_originalGroup.groupUsers) !=
                jsonEncode(widget.group.groupUsers)) {
          await Utility().showYesNoDialog(
            context,
            title: 'Проверка',
            message: TextSpan(
              text: 'Имеются несохраненные изменения. Сохранить?',
            ),
            yesButtonText: 'Да',
            yesCallBack: () {
              yesButtonPressed = true;
              Navigator.of(context).pop();
            },
            noButtonText: 'Нет',
            noCallBack: () {
              Navigator.of(context).pop();
            },
          );
        }

        if (yesButtonPressed) {
          validateWithErrors();
          await Future.delayed(const Duration(milliseconds: 500), () async {
            await _save();
            return Future.value(false);
          });
        } else {
          Navigator.pop(context, false);
        }

        // prevent default event
        return Future.value(false);
      },
      child: Form(
        key: _formKey,
        child: DefaultTabController(
          length: 3,
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
              title: Text(widget.group.id == 0
                  ? 'Новая группа'
                  : widget.isReadOnly
                      ? 'Просмотр группы'
                      : 'Изменить группу ${_originalGroup.toString()}'),
              centerTitle: true,
              actions: <Widget>[
                widget.isReadOnly
                    ? Container()
                    : Tooltip(
                        message: 'Сохранить',
                        child: TextButton(
                          style: ButtonStyle(
                            shape: WidgetStateProperty.all(
                              CircleBorder(
                                  side: BorderSide(color: Colors.transparent)),
                            ),
                          ),
                          onPressed: () async {
                            validateWithErrors();
                            Future.delayed(const Duration(milliseconds: 500),
                                () async {
                              await _save();
                            });
                          },
                          child: Icon(Icons.save),
                        ),
                      ),
                Container(
                  width: 20,
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    icon: Icon(Icons.people),
                    text: 'Состав группы',
                  ),
                  Tab(
                    icon: Icon(Icons.people_outline),
                    text: 'Гости',
                  ),
                  Tab(
                    icon: Icon(Icons.workspaces_outline),
                    text: 'Схема зала',
                  ),
                  Tab(
                    icon: Icon(Icons.list),
                    text: 'Общая информация',
                  ),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                scrollableTab(usersForm(context)),
                scrollableTab(guestsForm(context)),
                scrollableTab(workplacesForm(context)),
                scrollableTab(groupForm(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getDropDownForManagerRule() {
    return DropdownButton<String>(
      value: widget.group.managerRoule,
      disabledHint: Text(widget.group.managerRoule),
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: widget.isReadOnly
          ? null
          : (String? newValue) {
              setState(() {
                widget.group.managerRoule = newValue!;
              });
            },
      items: <String>[
        'Председатель определяется по ФИО',
        'Председатель определяется рабочим местом',
        'Председатель определяется вначале ФИО затем рабочим местом',
        'Председатель определяется вначале рабочим местом затем ФИО',
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget getDropDownForRoundingRule() {
    return DropdownButton<String>(
      value: widget.group.roundingRoule,
      disabledHint: Text(widget.group.roundingRoule),
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: widget.isReadOnly
          ? null
          : (String? newValue) {
              setState(() {
                widget.group.roundingRoule = newValue!;
              });
            },
      items: <String>[
        'Отбросить после запятой',
        'Округлить вверх если есть знак после запятой',
        'Больше или равно 0,5 округляется  вверх, меньше - вниз'
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  bool isUserInGroup(User user) {
    var result = false;

    if (widget.group.groupUsers != null &&
        widget.group.groupUsers.any((i) => i.user.id == user.id)) {
      result = true;
    }
    return result;
  }

  Widget scrollableTab(Widget tabContext) {
    var scrollContoller = ScrollController();

    return Scrollbar(
      thumbVisibility: true,
      controller: scrollContoller,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: scrollContoller,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            tabContext,
          ],
        ),
      ),
    );
  }

  Widget groupForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: _tecName,
            readOnly: widget.isReadOnly,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Название',
              errorText: _vmName,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: _tecUnblockedMics,
            readOnly: widget.isReadOnly,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Список активных микрофонов',
              errorText: _vmUnblockedMics,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: _tecMicsNotActiveFrom,
            readOnly: widget.isReadOnly,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Микрофоны не активны, начиная с',
              errorText: _vmMicsNotActiveFrom,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: _tecManagerTerminal,
            readOnly: widget.isReadOnly,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Идентификатор терминала места председателя',
              errorText: _vmMicsNotActiveFrom,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: _tecLawUsersCount,
            readOnly: widget.isReadOnly,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Установленное законом/иным документом заседающих',
              errorText: _vmIsLawUsersCount,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: _tecQuorumCount,
            readOnly: widget.isReadOnly,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Кворум',
              errorText: _vmQuorumCount,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: _tecMajorityCount,
            readOnly: widget.isReadOnly,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText:
                  'Большинство от установленного законом/иным документом заседающих',
              errorText: _vmMajorityCount,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: _tecOneThirdsCount,
            readOnly: widget.isReadOnly,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText:
                  '1/3 от установленного законом/иным документом заседающих',
              errorText: _vmOneThirdsCount,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: _tecTwoThirdsCount,
            readOnly: widget.isReadOnly,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText:
                  '2/3 от установленного законом/иным документом заседающих',
              errorText: _vmTwoThirdsCount,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: _tecChosenCount,
            readOnly: widget.isReadOnly,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Число избранных',
              errorText: _vmChosenCount,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: _tecMajorityChosenCount,
            readOnly: widget.isReadOnly,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Большинство от избранных',
              errorText: _vmMajorityChosenCount,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: _tecOneThirdsChosenCount,
            readOnly: widget.isReadOnly,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: '1/3 от избранных',
              errorText: _vmOneThirdsChosenCount,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: _tecTwoThirdsChosenCount,
            readOnly: widget.isReadOnly,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: '2/3 от избранных',
              errorText: _vmTwoThirdsChosenCount,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                'Правило принятия - принято если больше или равно',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text('Правила округления: '),
              Container(
                width: 10,
              ),
              getDropDownForRoundingRule(),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text('При равном числе голосов голос председателя решающий:'),
              Container(
                width: 10,
              ),
              Switch(
                  value: widget.group.isManagerCastingVote,
                  onChanged: widget.isReadOnly
                      ? null
                      : (value) => {
                            setState(() {
                              widget.group.isManagerCastingVote = value;
                            })
                          })
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text('Председатель определяется:'),
              Container(
                width: 10,
              ),
              getDropDownForManagerRule(),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text('Отменять регистрацию при выходе пользователя:'),
              Container(
                width: 10,
              ),
              Switch(
                  value: widget.group.isUnregisterUserOnExit,
                  onChanged: widget.isReadOnly
                      ? null
                      : (value) => {
                            setState(() {
                              widget.group.isUnregisterUserOnExit = value;
                            })
                          })
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text('Не требовать обязательной регистрации:'),
              Container(
                width: 10,
              ),
              Switch(
                  value: widget.group.isFastRegistrationUsed,
                  onChanged: widget.isReadOnly
                      ? null
                      : (value) => {
                            setState(() {
                              widget.group.isFastRegistrationUsed = value;
                            })
                          })
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text('Депутат регистрируется автоматически:'),
              Container(
                width: 10,
              ),
              Switch(
                  value: widget.group.isDeputyAutoRegistration,
                  onChanged: widget.isReadOnly
                      ? null
                      : (value) => {
                            setState(() {
                              widget.group.isDeputyAutoRegistration = value;
                            })
                          })
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text('Председатель регистрируется автоматически:'),
              Container(
                width: 10,
              ),
              Switch(
                  value: widget.group.isManagerAutoRegistration,
                  onChanged: widget.isReadOnly
                      ? null
                      : (value) => {
                            setState(() {
                              widget.group.isManagerAutoRegistration = value;
                            })
                          })
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text('Активность:'),
              Container(
                width: 10,
              ),
              Switch(
                  value: widget.group.isActive,
                  onChanged: widget.isReadOnly
                      ? null
                      : (value) => {
                            setState(() {
                              widget.group.isActive = value;
                            })
                          })
            ],
          ),
        ),
      ],
    );
  }

  Widget guestsForm(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 10,
        ),
        Container(
          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
          color: Colors.lightBlue,
          child: Row(
            children: [
              Expanded(child: Container()),
              Text(
                'Гости',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
              Expanded(child: Container()),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: Tooltip(
                  message: 'Добавить',
                  child: TextButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        CircleBorder(
                            side: BorderSide(color: Colors.transparent)),
                      ),
                    ),
                    onPressed: () {
                      addGuest();
                    },
                    child: Icon(Icons.add),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: getGuestsTable(),
        ),
      ],
    );
  }

  Widget usersForm(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 10,
        ),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: getManagerSelector(),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
          color: Colors.lightBlue,
          child: Row(
            children: [
              Expanded(child: Container()),
              Text(
                'Депутаты',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
              Expanded(child: Container()),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: Tooltip(
                  message: 'Добавить',
                  child: TextButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        CircleBorder(
                            side: BorderSide(color: Colors.transparent)),
                      ),
                    ),
                    onPressed: () {
                      addSubject();
                    },
                    child: Icon(Icons.add),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: getSubjectsTable(),
        ),
      ],
    );
  }

  Widget getManagerSelector() {
    User? manager;

    for (int i = 0; i < _users.length; i++) {
      if (isManager(_users[i])) {
        manager = _users[i];
        break;
      }
    }

    var groupUsers = _users.where((element) => isInGroup(element)).toList();

    return DropdownSearch<User>(
      key: dropDownKeyManager,
      // mode: Mode.DIALOG,
      // showSearchBox: true,
      // showClearButton: true,
      items: groupUsers,
      // label: 'Председатель',
      // popupTitle: Container(
      //     alignment: Alignment.center,
      //     color: Colors.blueAccent,
      //     padding: EdgeInsets.all(10),
      //     child: Text(
      //       'Председатель',
      //       style: TextStyle(
      //           fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
      //     )),
      // hint: 'Выберите Председателя',
      selectedItem: manager,
      onChanged: (element) {
        setState(() {
          for (var groupUser in widget.group.groupUsers) {
            groupUser.isManager = false;
          }

          var groupUser = widget.group.groupUsers
              .firstWhereOrNull((x) => x.user.id == element!.id);
          if (groupUser != null) {
            groupUser.isManager = true;
          }
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Выберите Председателя';
        }
        return null;
      },
      dropdownBuilder: userDropDownItemBuilder,
      // popupItemBuilder: userItemBuilder,
      // emptyBuilder: emptyBuilder,
    );
  }

  Widget getGuestsTable() {
    if (_guests.length == 0) {
      return Container();
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: DataTable(
            showCheckboxColumn: false,
            dataRowColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
              return Colors.white;
            }),
            headingRowHeight: 0,
            columns: [
              DataColumn(
                label: Text(
                  'Ф.И.О.',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
            rows: _guests
                .map(
                  ((element) => DataRow(
                        cells: <DataCell>[
                          DataCell(
                            Row(
                              children: [
                                Expanded(
                                  child: Text(element.toString()),
                                ),
                                Tooltip(
                                  message: 'Удалить гостя',
                                  child: TextButton(
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all(
                                          Colors.transparent),
                                      foregroundColor:
                                          WidgetStateProperty.all(Colors.black),
                                      overlayColor: WidgetStateProperty.all(
                                          Colors.black12),
                                      shape: WidgetStateProperty.all(
                                        CircleBorder(
                                            side: BorderSide(
                                                color: Colors.transparent)),
                                      ),
                                    ),
                                    onPressed: () {
                                      removeGuest(element);
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

  void removeGuest(String guest) {
    setState(() {
      widget.group.guests = widget.group.guests
          .replaceAll(',${guest.toString()}', '')
          .replaceAll('${guest.toString()}', '');
      loadGuests();
    });
  }

  Future<void> addGuest() async {
    // show select user dialog
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Добавить Гостя'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: _guestController,
                    readOnly: widget.isReadOnly,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Имя Гостя',
                    ),
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
                if (_guestController.text.isEmpty) {
                  return;
                }

                setState(() {
                  if (widget.group.guests != null &&
                      widget.group.guests.isNotEmpty) {
                    widget.group.guests += ',' + _guestController.text;
                  } else {
                    widget.group.guests = _guestController.text;
                  }

                  loadGuests();
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget getSubjectsTable() {
    var groupUsers = _users.where((element) => isInGroup(element)).toList();

    if (groupUsers == null || groupUsers.length == 0) {
      return Container();
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: DataTable(
            showCheckboxColumn: false,
            dataRowColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
              return Colors.white;
            }),
            headingRowHeight: 0,
            columns: [
              DataColumn(
                label: Text(
                  'Ф.И.О.',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
            rows: groupUsers
                .map(
                  ((element) => DataRow(
                        cells: <DataCell>[
                          DataCell(
                            Row(
                              children: [
                                Expanded(
                                  child: Text(element.toString()),
                                ),
                                Tooltip(
                                  message: 'Удалить депутата',
                                  child: TextButton(
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all(
                                          Colors.transparent),
                                      foregroundColor:
                                          WidgetStateProperty.all(Colors.black),
                                      overlayColor: WidgetStateProperty.all(
                                          Colors.black12),
                                      shape: WidgetStateProperty.all(
                                        CircleBorder(
                                            side: BorderSide(
                                                color: Colors.transparent)),
                                      ),
                                    ),
                                    onPressed: () {
                                      removeDeputy(element);
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

  void removeDeputy(User user) {
    setState(() {
      // remove user if it used on scheme
      removeUserFromScheme(user.id);
      // remove user from list
      widget.group.groupUsers.removeWhere((gu) => gu.user.id == user.id);
    });
  }

  Future<void> addSubject() async {
    // show select user dialog
    final formKey = GlobalKey<FormState>();
    User? selectedUser;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Добавить депутата'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  getDeputySelector((value) {
                    selectedUser = value;
                  }),
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
                if (formKey.currentState?.validate() != true) {
                  return;
                }

                setState(() {
                  var isContains = widget.group.groupUsers
                      .any((x) => x.user.id == selectedUser!.id);
                  if (!isContains) {
                    var newGroupUser = GroupUser();

                    newGroupUser.groupId = widget.group.id;
                    newGroupUser.user = selectedUser!;
                    newGroupUser.isManager = false;
                    widget.group.groupUsers.add(newGroupUser);
                  }
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget getDeputySelector(void onChanged(User? value)) {
    var groupUsers = _users.where((element) => isInGroup(element)).toList();

    return DropdownSearch<User>(
      key: dropDownKeyDeputy,
      // mode: Mode.DIALOG,
      // showSearchBox: true,
      // showClearButton: true,
      items: _users.where((element) => !groupUsers.contains(element)).toList(),
      // label: 'Депутат',
      // popupTitle: Container(
      //     alignment: Alignment.center,
      //     color: Colors.blueAccent,
      //     padding: EdgeInsets.all(10),
      //     child: Text(
      //       'Депутат',
      //       style: TextStyle(
      //           fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
      //     )),
      // hint: 'Выберите Депутата',
      selectedItem: null,
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return 'Выберите Депутата';
        }
        return null;
      },
      dropdownBuilder: userDropDownItemBuilder,
      //popupItemBuilder: userItemBuilder,
      //emptyBuilder: emptyBuilder,
    );
  }

  Widget userDropDownItemBuilder(
    BuildContext context,
    User? item,
  ) {
    return item == null
        ? Container(
            child: Text(
              'Выберите депутата',
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        : userItemBuilder(context, item, true);
  }

  Widget userItemBuilder(BuildContext context, User item, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        selected: isSelected,
        title: Row(
          children: [
            Text(item.toString()),
            Expanded(child: Container()),
            Container(
              width: 20,
            ),
            Container(),
          ],
        ),
      ),
    );
  }

  Widget emptyBuilder(BuildContext context, String? text) {
    return Center(child: Text('Нет данных'));
  }

  Widget proxyDropDownItemBuilder(
    BuildContext context,
    User? item,
  ) {
    return item == null
        ? Container(
            child: Text(
              'Выберите депутата',
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        : userItemBuilder(context, item, true);
  }

  bool isManager(User user) {
    return widget.group.groupUsers.any(
        (element) => element.user.id == user.id && element.isManager == true);
  }

  bool isInGroup(User user) {
    return widget.group.groupUsers.any((element) => element.user.id == user.id);
  }

  var schemeScrollController = ScrollController();
  Widget workplacesForm(BuildContext context) {
    var usersForAdd = _users
        .where((user) => widget.group.groupUsers
            .any((groupUser) => groupUser.user.id == user.id))
        .toList();
    usersForAdd.sort((a, b) => a.getFullName().compareTo(b.getFullName()));

    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: [
              Expanded(
                child: Container(),
              ),
              Container(
                margin: const EdgeInsets.all(10.0),
                width: 200.0,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(),
                    ),
                    Text('Есть призидиум:'),
                    Switch(
                        value: widget.group.workplaces.hasManagement,
                        onChanged: widget.isReadOnly
                            ? null
                            : (value) {
                                if (!value) {
                                  _tecManagementCount.text = '0';
                                  widget.group.workplaces
                                      .managementPlacesCount = 0;
                                }
                                setState(() {
                                  _vmManagementCount = null;
                                  widget.group.workplaces.hasManagement = value;
                                });
                                updateScheme();
                              })
                  ],
                ),
              ),
              getManagementForm(),
              Container(
                margin: const EdgeInsets.all(10.0),
                width: 240,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(),
                    ),
                    Text('Отображать пустые места'),
                    Switch(
                        value: widget.group.workplaces.showEmptyManagement,
                        onChanged: widget.isReadOnly
                            ? null
                            : (value) {
                                setState(() {
                                  widget.group.workplaces.showEmptyManagement =
                                      value;
                                });
                                updateScheme();
                              })
                  ],
                ),
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Container(),
              ),
              Container(
                margin: const EdgeInsets.all(10.0),
                width: 200.0,
                alignment: Alignment.centerRight,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(),
                    ),
                    Text('Есть трибуна:'),
                    Switch(
                        value: widget.group.workplaces.hasTribune,
                        onChanged: widget.isReadOnly
                            ? null
                            : (value) {
                                if (!value) {
                                  _tecTribuneCount.text = '0';
                                  widget.group.workplaces.tribunePlacesCount =
                                      0;
                                }
                                setState(() {
                                  _vmTribuneCount = null;
                                  widget.group.workplaces.hasTribune = value;
                                });
                                updateScheme();
                              })
                  ],
                ),
              ),
              getTribuneForm(),
              Expanded(
                child: Container(),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Количество рядов: '),
                getDropDownForRowsCount()
              ],
            ),
          ),
          getRows(),
          Scrollbar(
            thumbVisibility: true,
            controller: schemeScrollController,
            child: SingleChildScrollView(
              controller: schemeScrollController,
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  getWorkplacesScheme(usersForAdd),
                  getManagementScheme(usersForAdd),
                  getTribuneScheme(),
                ],
              ),
            ),
          ),
        ]);
  }

  Widget getManagementForm() {
    setState(() {
      _vmManagementCount = _vmManagementCount;
    });
    return Container(
      margin: const EdgeInsets.all(10.0),
      width: 400,
      child: TextFormField(
          controller: _tecManagementCount,
          readOnly: widget.isReadOnly || !widget.group.workplaces.hasManagement,
          enabled:
              !(widget.isReadOnly || !widget.group.workplaces.hasManagement),
          onChanged: (value) => {
                setState(() {
                  widget.group.workplaces.managementPlacesCount =
                      int.tryParse(_tecManagementCount.text) ?? 0;

                  updateScheme();
                })
              },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Количество мест в президиуме',
            errorText: _vmManagementCount,
          )),
    );
  }

  Widget getTribuneForm() {
    setState(() {
      _vmTribuneCount = _vmTribuneCount;
    });
    return Container(
      margin: const EdgeInsets.all(10.0),
      width: 400,
      child: TextFormField(
          controller: _tecTribuneCount,
          readOnly: widget.isReadOnly || !widget.group.workplaces.hasTribune,
          enabled: !(widget.isReadOnly || !widget.group.workplaces.hasTribune),
          onChanged: (value) => {
                setState(() {
                  widget.group.workplaces.tribunePlacesCount =
                      int.tryParse(_tecTribuneCount.text) ?? 0;

                  updateScheme();
                })
              },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Количество мест в трибуне',
            errorText: _vmTribuneCount,
          )),
    );
  }

  Widget getRows() {
    // remove unused _tecRows
    if (_tecRows.length > widget.group.workplaces.rowsCount) {
      var removedControllers = <TextEditingController>[];

      _tecRows
          .getRange(widget.group.workplaces.rowsCount, _tecRows.length)
          .forEach((element) {
        removedControllers.add(element);
      });
      _tecRows.removeRange(widget.group.workplaces.rowsCount, _tecRows.length);
      removedControllers.forEach((element) {
        element.dispose();
      });

      updateScheme();
    }

    var rows = <Widget>[];
    for (int i = 1; i <= widget.group.workplaces.rowsCount; i++) {
      var tecRow = TextEditingController();
      // init row with saved values
      if (widget.group.workplaces.rows.length > i - 1) {
        tecRow.text = widget.group.workplaces.rows[i - 1].toString();
      }
      if (_tecRows.length >= i) {
        tecRow = _tecRows[i - 1];
      } else {
        _tecRows.add(tecRow);
      }
      rows.add(Container(
        margin: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(child: Container()),
            Text(
              'Ряд $i',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Container(
              width: 20,
            ),
            Container(
              width: 400,
              child: TextField(
                controller: tecRow,
                readOnly: widget.isReadOnly,
                onChanged: (value) async {
                  updateScheme();

                  setState(() {
                    schemeScrollController.jumpTo(0.01);
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Количество мест',
                ),
              ),
            ),
            Container(
              width: 20,
            ),
            Text('Отображать пустые места:'),
            Switch(
                value: widget.group.workplaces.isDisplayEmptyCell.length > i - 1
                    ? widget.group.workplaces.isDisplayEmptyCell[i - 1]
                    : false,
                onChanged: widget.isReadOnly
                    ? null
                    : (value) {
                        setState(() {
                          widget.group.workplaces.isDisplayEmptyCell[i - 1] =
                              value;
                        });
                      }),
            Container(
              width: 20,
            ),
            Expanded(child: Container()),
          ],
        ),
      ));
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, children: rows);
  }

  void updateScheme() {
    // update management places
    var oldManagementScheme = widget.group.workplaces.schemeManagement;
    var oldManagementTerminalIds =
        widget.group.workplaces.managementTerminalIds;

    widget.group.workplaces.schemeManagement = <int?>[];
    widget.group.workplaces.managementTerminalIds = <String?>[];

    for (int i = 0; i < widget.group.workplaces.managementPlacesCount; i++) {
      int? userId;
      String? terminalId;
      if (oldManagementScheme.length > i) {
        userId = oldManagementScheme[i];
      }
      if (oldManagementTerminalIds.length > i) {
        terminalId = oldManagementTerminalIds[i];
      }

      widget.group.workplaces.schemeManagement.add(userId);
      widget.group.workplaces.managementTerminalIds.add(terminalId);

      if (_managementTerminalIdControllers.length <= i) {
        _managementTerminalIdControllers.add(TextEditingController());
      }
    }

    _managementTerminalIdControllers.removeRange(
        widget.group.workplaces.managementPlacesCount,
        _managementTerminalIdControllers.length);

    if (_tecRows.length > widget.group.workplaces.isDisplayEmptyCell.length) {
      for (int i = 0;
          i <
              _tecRows.length -
                  widget.group.workplaces.isDisplayEmptyCell.length;
          i++) {
        widget.group.workplaces.isDisplayEmptyCell.add(false);
      }
    } else {
      widget.group.workplaces.isDisplayEmptyCell.removeRange(
          _tecRows.length, widget.group.workplaces.isDisplayEmptyCell.length);
    }

    //update tribunes
    var oldTribuneTerminalIds = widget.group.workplaces.tribuneTerminalIds;
    var oldTribuneNames = widget.group.workplaces.tribuneNames;
    widget.group.workplaces.tribuneTerminalIds = <String>[];
    widget.group.workplaces.tribuneNames = <String>[];

    for (int i = 0; i < widget.group.workplaces.tribunePlacesCount; i++) {
      String terminalId = '';
      if (oldTribuneTerminalIds.length > i) {
        terminalId = oldTribuneTerminalIds[i];
      }
      widget.group.workplaces.tribuneTerminalIds.add(terminalId);

      if (_tribuneTerminalIdControllers.length <= i) {
        _tribuneTerminalIdControllers
            .add(TextEditingController(text: terminalId));
      }

      String tribuneName = '';
      if (oldTribuneNames.length > i) {
        tribuneName = oldTribuneNames[i];
      }
      widget.group.workplaces.tribuneNames.add(tribuneName);

      if (_tribuneNameControllers.length <= i) {
        _tribuneNameControllers.add(TextEditingController(text: tribuneName));
      }
    }
    _tribuneTerminalIdControllers.removeRange(
        widget.group.workplaces.tribunePlacesCount,
        _tribuneTerminalIdControllers.length);
    _tribuneNameControllers.removeRange(
        widget.group.workplaces.tribunePlacesCount,
        _tribuneNameControllers.length);

    //update workplaces rows
    widget.group.workplaces.rows.clear();
    for (TextEditingController tecRow in _tecRows) {
      widget.group.workplaces.rows.add(int.tryParse(tecRow.text) ?? 0);
    }

    // update wokplaces scheme
    var oldWorkplacesScheme = widget.group.workplaces.schemeWorkplaces;
    var oldWorkplacesTerminalIds =
        widget.group.workplaces.workplacesTerminalIds;
    widget.group.workplaces.schemeWorkplaces = <List<int>>[];
    widget.group.workplaces.workplacesTerminalIds = <List<String>>[];

    var rowIndex = 0;
    widget.group.workplaces.rows.forEach((element) {
      var rowUserIds = <int?>[];
      var rowTerminalIds = <String?>[];
      for (int i = 0; i < element; i++) {
        int? userId;
        String? terminalId;
        if (oldWorkplacesScheme.length > rowIndex) {
          if (oldWorkplacesScheme[rowIndex].length > i) {
            userId = oldWorkplacesScheme[rowIndex][i];
          }
          if (oldWorkplacesTerminalIds[rowIndex].length > i) {
            terminalId = oldWorkplacesTerminalIds[rowIndex][i];
          }
        }
        rowUserIds.add(userId);
        rowTerminalIds.add(terminalId);
      }
      widget.group.workplaces.schemeWorkplaces.add(rowUserIds);
      widget.group.workplaces.workplacesTerminalIds.add(rowTerminalIds);
      rowIndex++;
    });

    //update workplaces terminal controllers
    for (int i = 0;
        i < widget.group.workplaces.workplacesTerminalIds.length;
        i++) {
      if (_workplacesTerminalIdControllers.length <= i) {
        _workplacesTerminalIdControllers.add(<TextEditingController>[]);
      }
      for (int j = 0;
          j < widget.group.workplaces.workplacesTerminalIds[i].length;
          j++) {
        if (j > _workplacesTerminalIdControllers[i].length) {
          var removedController = _workplacesTerminalIdControllers[i][j];
          _workplacesTerminalIdControllers[i].remove(removedController);
          //removedController.dispose();
        }
        if (_workplacesTerminalIdControllers[i].length <= j) {
          _workplacesTerminalIdControllers[i].add(TextEditingController());
        }
      }
    }

    if (_workplacesTerminalIdControllers.length >
        widget.group.workplaces.workplacesTerminalIds.length) {
      _workplacesTerminalIdControllers.removeRange(
          widget.group.workplaces.workplacesTerminalIds.length,
          _workplacesTerminalIdControllers.length);
    }

    setState(() {});
  }

  Widget getWorkplacesScheme(List<User> usersForAdd) {
    List<Column> columns = <Column>[];
    var rowIndex = 0;

    for (int row in widget.group.workplaces.rows) {
      List<Widget> currentRow = <Widget>[];
      for (int i = 0; i < row; i++) {
        currentRow.add(createUserCell(usersForAdd, rowIndex, i));
      }
      rowIndex++;
      var column = Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: currentRow,
      );
      columns.add(column);
    }

    return Container(
        margin: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: columns,
        ));
  }

  Widget getManagementScheme(List<User> usersForAdd) {
    var managementItems = <Widget>[];

    for (int i = 0; i < widget.group.workplaces.managementPlacesCount; i++) {
      managementItems.add(createManagerCell(usersForAdd, i));
    }

    return Container(
        margin: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: managementItems,
        ));
  }

  Widget getTribuneScheme() {
    var tribuneItems = <Widget>[];

    for (int i = 0; i < widget.group.workplaces.tribunePlacesCount; i++) {
      tribuneItems.add(createTribuneItem(i));
    }

    return Container(
        margin: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: tribuneItems,
        ));
  }

  Widget createUserCell(List<User> usersForAdd, int rowIndex, int columnIndex) {
    return Container(
      margin: EdgeInsets.all(10),
      width: 300,
      color: Colors.black12,
      child: Column(
        children: [
          TextField(
            controller: _workplacesTerminalIdControllers[rowIndex][columnIndex],
            readOnly: widget.isReadOnly,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'ИД терминала',
            ),
            onChanged: (value) {
              widget.group.workplaces.workplacesTerminalIds[rowIndex]
                  [columnIndex] = value;
            },
          ),
          DropdownSearch<User>(
            key: dropDownKeyWorkplacesUser,
            // mode: Mode.DIALOG,
            // showSearchBox: !widget.isReadOnly,
            // showClearButton: !widget.isReadOnly,
            items: usersForAdd,
            enabled: !widget.isReadOnly,
            // dropDownButton: !widget.isReadOnly ? null : Container(),
            // popupTitle: Container(
            //     alignment: Alignment.center,
            //     color: Colors.blueAccent,
            //     padding: EdgeInsets.all(10),
            //     child: Text(
            //       'Пользователи',
            //       style: TextStyle(
            //           fontWeight: FontWeight.bold,
            //           color: Colors.white,
            //           fontSize: 20),
            //     )),
            // hint: 'Выберите пользователя',
            selectedItem: widget.group.groupUsers
                .firstWhereOrNull((element) =>
                    element.user.id != null &&
                    element.user.id ==
                        widget.group.workplaces.schemeWorkplaces[rowIndex]
                            [columnIndex])
                ?.user,
            onChanged: widget.isReadOnly
                ? null
                : (value) {
                    if (value != null) {
                      removeUserFromScheme(value.id);
                      //set user on new place
                      widget.group.workplaces.schemeWorkplaces[rowIndex]
                          [columnIndex] = value.id;
                    } else {
                      widget.group.workplaces.schemeWorkplaces[rowIndex]
                          [columnIndex] = null;
                    }

                    setState(() {});
                  },

            popupProps: PopupProps.menu(
              itemBuilder: userPopupItemBuilder,
            ),
          ),
        ],
      ),
    );
  }

  Widget createManagerCell(List<User> usersForAdd, int index) {
    return Container(
      margin: EdgeInsets.all(10),
      width: 300,
      child: Column(
        children: [
          TextField(
            controller: _managementTerminalIdControllers[index],
            readOnly: widget.isReadOnly,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'ИД терминала',
            ),
            onChanged: (value) {
              widget.group.workplaces.managementTerminalIds[index] = value;
            },
          ),
          DropdownSearch<User>(
            key: dropDownKeyWorkplacesUser,
            // mode: Mode.DIALOG,
            // showSearchBox: !widget.isReadOnly,
            // showClearButton: !widget.isReadOnly,
            items: usersForAdd,
            enabled: !widget.isReadOnly,
            // popupTitle: Container(
            //     alignment: Alignment.center,
            //     color: Colors.blueAccent,
            //     padding: EdgeInsets.all(10),
            //     child: Text(
            //       'Пользователи',
            //       style: TextStyle(
            //           fontWeight: FontWeight.bold,
            //           color: Colors.white,
            //           fontSize: 20),
            //     )),
            // hint: 'Выберите пользователя',
            selectedItem: widget.group.groupUsers
                .firstWhereOrNull((element) =>
                    element.user.id != null &&
                    element.user.id ==
                        widget.group.workplaces.schemeManagement[index])
                ?.user,
            onChanged: (value) {
              if (value != null) {
                removeUserFromScheme(value.id);
                //set user on new place
                widget.group.workplaces.schemeManagement[index] = value.id;
              } else {
                widget.group.workplaces.schemeManagement[index] = null;
              }

              setState(() {});
            },
            popupProps: PopupProps.menu(
              itemBuilder: userPopupItemBuilder,
            ),
          ),
        ],
      ),
    );
  }

  Widget createTribuneItem(int index) {
    return Container(
      margin: EdgeInsets.all(10),
      color: Colors.greenAccent[100],
      width: 300,
      child: Column(
        children: [
          TextField(
            controller: _tribuneNameControllers[index],
            readOnly: widget.isReadOnly,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Имя трибуны',
            ),
            onChanged: (value) {
              widget.group.workplaces.tribuneNames[index] = value;
            },
          ),
          TextField(
            controller: _tribuneTerminalIdControllers[index],
            readOnly: widget.isReadOnly,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'ИД терминала',
            ),
            onChanged: (value) {
              widget.group.workplaces.tribuneTerminalIds[index] = value;
            },
          ),
        ],
      ),
    );
  }

  Widget userPopupItemBuilder(
      BuildContext context, User item, bool isSelected) {
    var isOnScheme = false;

    var managementPlaces = widget.group.workplaces.schemeManagement;
    for (int index = 0; index < managementPlaces.length; index++) {
      if (managementPlaces[index] == item.id) {
        isOnScheme = true;
        break;
      }
    }

    if (!isOnScheme) {
      var workPlaces = widget.group.workplaces.schemeWorkplaces;
      for (int row = 0; row < workPlaces.length; row++) {
        for (int column = 0; column < workPlaces[row].length; column++) {
          if (workPlaces[row][column] == item.id) {
            isOnScheme = true;
            break;
          }
        }
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        selected: isSelected,
        title: Row(
          children: [
            Text(item.toString()),
            Expanded(child: Container()),
            isOnScheme
                ? Tooltip(
                    message: 'Присутствует на схеме',
                    child: Icon(Icons.done),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  void removeUserFromScheme(int userId) {
    //remove user from management places
    var managementPlaces = widget.group.workplaces.schemeManagement;
    for (int index = 0; index < managementPlaces.length; index++) {
      if (managementPlaces[index] == userId) {
        managementPlaces[index] = null;
      }
    }
    //remove user from other workplaces places
    var workPlaces = widget.group.workplaces.schemeWorkplaces;
    for (int row = 0; row < workPlaces.length; row++) {
      for (int column = 0; column < workPlaces[row].length; column++) {
        if (workPlaces[row][column] == userId) {
          workPlaces[row][column] = null;
        }
      }
    }
  }

  Widget getDropDownForRowsCount() {
    return DropdownButton<int>(
      value: widget.group.workplaces.rowsCount,
      disabledHint: Text(widget.group.workplaces.rowsCount.toString()),
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: widget.isReadOnly
          ? null
          : (int? newValue) {
              setState(() {
                if (widget.group.workplaces.rowsCount != newValue) {
                  widget.group.workplaces.rowsCount = newValue!;
                }
              });
            },
      items: <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
          .map<DropdownMenuItem<int>>((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tecName.dispose();
    _tecLawUsersCount.dispose();
    _tecQuorumCount.dispose();
    _tecMajorityCount.dispose();
    _tecOneThirdsCount.dispose();
    _tecTwoThirdsCount.dispose();
    _tecChosenCount.dispose();
    _tecMajorityChosenCount.dispose();
    _tecOneThirdsChosenCount.dispose();
    _tecTwoThirdsChosenCount.dispose();
    _tecManagementCount.dispose();
    _tecMicsNotActiveFrom.dispose();
    _tecManagerTerminal.dispose();

    for (TextEditingController tecRow in _tecRows) {
      tecRow.dispose();
    }
    for (TextEditingController controller in _managementTerminalIdControllers) {
      controller.dispose();
    }
    for (var rowOfControllers in _workplacesTerminalIdControllers) {
      for (TextEditingController controller in rowOfControllers) {
        controller.dispose();
      }
    }

    super.dispose();
  }
}
