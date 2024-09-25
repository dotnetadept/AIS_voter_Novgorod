import 'dart:convert' show json;
import 'package:collection/collection.dart';
import 'package:file_selector/file_selector.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ais_model/ais_model.dart';
import 'package:ais_model/ais_model.dart' as ais;
import 'package:ais_utils/ais_utils.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';
import 'package:operator_panel/Providers/AppState.dart';
import 'package:operator_panel/Providers/WebSocketConnection.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../Controls/tableHelper.dart';
import '../Providers/SoundPlayer.dart';
import '../Utility/db_helper.dart';
import 'package:path_provider/path_provider.dart';

class SettingsPage extends StatefulWidget {
  final int startedTabIndex;
  List<User> users;

  SettingsPage({
    Key? key,
    required this.users,
    required this.startedTabIndex,
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  final int _tabLenght = 14;
  bool _isLoadingComplete = false;
  late TabController _tabController;
  var _headerItemsScrollController = ScrollController();
  var _votingModesScrollController = ScrollController();
  var _votingDecisionsScrollController = ScrollController();
  var _signalsScrollController = ScrollController();
  var _intervalsScrollController = ScrollController();
  var _versionsScrollController = ScrollController();
  var _tecVotingRegistrationTime = TextEditingController();
  var _tecLawUsersCount = TextEditingController();
  var _tecEditHeaderItemName = TextEditingController();
  var _tecEditVotingModeName = TextEditingController();
  var _tecSettingsName = TextEditingController();

  late Settings _currentSettings;
  late List<Settings> _settings;
  late List<Settings> _settingsTemplates;
  late DecisionMode _selectedDecisionMode;
  late List<VotingMode> _votingModes;
  late HeaderItem _selectedHeaderItem;
  late VotingMode _selectedVotingMode;
  late List<Signal> _signals;
  Signal? _selectedSignal;
  late List<ais.Interval> _intervals;
  late ais.Interval _selectedInterval;
  late Settings? _settingsForRestore;
  late WebSocketConnection _connection;
  late PackageInfo _packageInfo;

  void Function(void Function())? _setStateForDialog;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: _tabLenght);
    _tabController.addListener(() {
      setState(() {});
    });

    loadData();

    _tabController.animateTo(widget.startedTabIndex);
  }

  void loadData() {
    http
        .get(Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            "/settings"))
        .then((value) => {
              setState(() {
                _settings = (json.decode(value.body) as List)
                    .map((data) => Settings.fromJson(data))
                    .toList();

                _currentSettings =
                    _settings.firstWhere((element) => element.isSelected);
                _settingsTemplates =
                    _settings.where((x) => x != _currentSettings).toList();
                _settingsForRestore = _settingsTemplates.length > 0
                    ? _settingsTemplates.first
                    : null;

                sortSettingsInternal();
              })
            })
        .then((value) => http
            .get(Uri.http(
                ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                "/voting_modes"))
            .then((response) => {
                  setState(() {
                    _votingModes = (json.decode(response.body) as List)
                        .map((data) => VotingMode.fromJson(data))
                        .toList();
                    if (_votingModes.length > 0) {
                      _votingModes
                          .sort((a, b) => a.orderNum.compareTo(b.orderNum));
                      _selectedVotingMode = _votingModes.firstWhere(
                          (element) =>
                              element.id ==
                              _currentSettings.votingSettings
                                  .defaultVotingModeId, orElse: () {
                        return _votingModes.first;
                      });
                      _selectedDecisionMode = DecisionModeHelper.getEnumValue(
                          _selectedVotingMode.defaultDecision);
                    }
                  })
                }))
        .then((value) => http
            .get(Uri.http(
                ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                "/signals"))
            .then((response) => {
                  setState(() {
                    _signals = response.body.isEmpty
                        ? <Signal>[]
                        : (json.decode(response.body) as List)
                            .map((data) => Signal.fromJson(data))
                            .toList();
                    if (_signals.length > 0) {
                      _signals.sort((a, b) => a.orderNum.compareTo(b.orderNum));
                      _selectedSignal = _signals.first;
                    }
                  })
                }))
        .then((value) => http
            .get(Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()), "/intervals"))
            .then((response) => {
                  setState(() {
                    _intervals = response.body.isEmpty
                        ? <ais.Interval>[]
                        : (json.decode(response.body) as List)
                            .map((data) => ais.Interval.fromJson(data))
                            .toList();
                    if (_intervals.length > 0) {
                      _intervals
                          .sort((a, b) => a.orderNum.compareTo(b.orderNum));
                      _selectedInterval = _intervals.first;
                    }
                  })
                }))
        .then((value) => PackageInfo.fromPlatform())
        .then((value) {
      _packageInfo = value;
      if (_currentSettings.tableViewSettings.headerItems.length == 0) {
        _currentSettings.tableViewSettings.headerItems.add(HeaderItem(
            name: "Зарегистрированные",
            value: HeaderItemValue.RegistredCount,
            orderNum: 1,
            isVisible: true));
        _currentSettings.tableViewSettings.headerItems.add(HeaderItem(
            name: "Незарегистрированные",
            value: HeaderItemValue.UnRegistredCount,
            orderNum: 2,
            isVisible: true));
        _currentSettings.tableViewSettings.headerItems.add(HeaderItem(
            name: "За",
            value: HeaderItemValue.VotedYes,
            orderNum: 3,
            isVisible: true));
        _currentSettings.tableViewSettings.headerItems.add(HeaderItem(
            name: "Против",
            value: HeaderItemValue.VotedNo,
            orderNum: 4,
            isVisible: true));
        _currentSettings.tableViewSettings.headerItems.add(HeaderItem(
            name: "Воздержались",
            value: HeaderItemValue.VotedIndifferent,
            orderNum: 5,
            isVisible: true));
        _currentSettings.tableViewSettings.headerItems.add(HeaderItem(
            name: "Всего проголосовало",
            value: HeaderItemValue.VotedTotal,
            orderNum: 6,
            isVisible: true));
        _currentSettings.tableViewSettings.headerItems.add(HeaderItem(
            name: "Избранно",
            value: HeaderItemValue.ChosenCount,
            orderNum: 7,
            isVisible: true));
        _currentSettings.tableViewSettings.headerItems.add(HeaderItem(
            name: "Кворум",
            value: HeaderItemValue.QuorumCount,
            orderNum: 8,
            isVisible: true));
      }
      _selectedHeaderItem =
          _currentSettings.tableViewSettings.headerItems.first;

      setState(() => {_isLoadingComplete = true});
    });
  }

  void restoreDefaultSettingsForTab() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Восстановить настройки по умолчанию на текущей вкладке'),
          content: Container(
            height: 100,
            child: Column(
              children: [
                Text('Выберите шаблон настроек:'),
                DropdownButton<Settings>(
                  value: _settingsForRestore,
                  icon: Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (Settings? value) {
                    setState(() {
                      _settingsForRestore = value;
                    });
                  },
                  items: _settingsTemplates
                      .map<DropdownMenuItem<Settings>>((Settings value) {
                    return DropdownMenuItem<Settings>(
                      value: value,
                      child: Text(value.name.toString()),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text('Отмена', style: TextStyle(fontSize: 20)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                Container(
                  width: 20,
                ),
                TextButton(
                  child: Text('Ок', style: TextStyle(fontSize: 20)),
                  onPressed: () {
                    setState(() {
                      if (_tabController.index == 0) {
                        _currentSettings.palletteSettings =
                            _settingsForRestore!.palletteSettings;
                      }
                      if (_tabController.index == 1) {
                        _currentSettings.operatorSchemeSettings =
                            _settingsForRestore!.operatorSchemeSettings;
                      }
                      if (_tabController.index == 2) {
                        _currentSettings.managerSchemeSettings =
                            _settingsForRestore!.managerSchemeSettings;
                      }
                      if (_tabController.index == 3) {
                        _currentSettings.managerSchemeSettings =
                            _settingsForRestore!.managerSchemeSettings;
                      }
                      if (_tabController.index == 4) {
                        _currentSettings.deputySettings =
                            _settingsForRestore!.deputySettings;
                      }
                      if (_tabController.index == 5) {
                        _currentSettings.votingSettings =
                            _settingsForRestore!.votingSettings;
                      }
                      if (_tabController.index == 6) {
                        _currentSettings.reportSettings =
                            _settingsForRestore!.reportSettings;
                      }
                      if (_tabController.index == 7) {
                        _currentSettings.storeboardSettings =
                            _settingsForRestore!.storeboardSettings;
                      }
                      if (_tabController.index == 8) {
                        _currentSettings.questionListSettings =
                            _settingsForRestore!.questionListSettings;
                      }
                      if (_tabController.index == 9) {
                        _currentSettings.signalsSettings =
                            _settingsForRestore!.signalsSettings;
                      }
                      if (_tabController.index == 10) {
                        _currentSettings.signalsSettings =
                            _settingsForRestore!.signalsSettings;
                      }
                      if (_tabController.index == 11) {
                        _currentSettings.intervalsSettings =
                            _settingsForRestore!.intervalsSettings;
                      }
                      if (_tabController.index == 12) {
                        _currentSettings.licenseSettings =
                            _settingsForRestore!.licenseSettings;
                      }
                    });
                    DbHelper.saveSettings(_currentSettings);
                    Navigator.pop(context);
                  },
                ),
              ],
            )
          ],
        );
      },
    );
  }

  void restoreDefaultSettings() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Восстановить настройки по умолчанию для всех вкладок'),
          content: Container(
            height: 100,
            child: Column(
              children: [
                Text('Выберите шаблон настроек:'),
                DropdownButton<Settings>(
                  value: _settingsForRestore,
                  icon: Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (Settings? value) {
                    setState(() {
                      _settingsForRestore = value;
                    });
                  },
                  items: _settingsTemplates
                      .map<DropdownMenuItem<Settings>>((Settings value) {
                    return DropdownMenuItem<Settings>(
                      value: value,
                      child: Text(value.name.toString()),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text('Отмена', style: TextStyle(fontSize: 20)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                Container(
                  width: 20,
                ),
                TextButton(
                  child: Text('Ок', style: TextStyle(fontSize: 20)),
                  onPressed: () {
                    setState(() {
                      _currentSettings.palletteSettings =
                          _settingsForRestore!.palletteSettings;
                      _currentSettings.operatorSchemeSettings =
                          _settingsForRestore!.operatorSchemeSettings;
                      _currentSettings.managerSchemeSettings =
                          _settingsForRestore!.managerSchemeSettings;
                      _currentSettings.deputySettings =
                          _settingsForRestore!.deputySettings;
                      _currentSettings.votingSettings =
                          _settingsForRestore!.votingSettings;
                      _currentSettings.reportSettings =
                          _settingsForRestore!.reportSettings;
                      _currentSettings.storeboardSettings =
                          _settingsForRestore!.storeboardSettings;
                      _currentSettings.signalsSettings =
                          _settingsForRestore!.signalsSettings;
                      _currentSettings.licenseSettings =
                          _settingsForRestore!.licenseSettings;
                    });
                    DbHelper.saveSettings(_currentSettings);
                    Navigator.pop(context);
                  },
                ),
              ],
            )
          ],
        );
      },
    );
  }

  void saveDefaultSettings() async {
    _tecSettingsName.text = '';
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Создание шаблона настроек'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Container(
                    width: 500,
                    child: TextFormField(
                      controller: _tecSettingsName,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Наименование шаблона настроек',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите наименование повестки';
                        }

                        // check settings template name
                        if (_settings.any((element) =>
                            element.toString() ==
                            _tecSettingsName.text.trim())) {
                          return 'Шаблон настроек с таким именем уже существует.';
                        }

                        return null;
                      },
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
                if (formKey.currentState?.validate() != true) {
                  return;
                }

                var setting = Settings.fromJson(
                    json.decode(json.encode(_currentSettings.toJson())));
                setting.id = 0;
                setting.name = _tecSettingsName.text;
                setting.createdDate = DateTime.now();
                setting.isSelected = false;
                http
                    .post(
                        Uri.http(
                            ServerConnection.getHttpServerUrl(
                                GlobalConfiguration()),
                            '/settings'),
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                        },
                        body: json.encode(setting.toJson()))
                    .then((response) {
                  var insertedSetting =
                      Settings.fromJson(json.decode(response.body));
                  setState(() {
                    _settings.add(insertedSetting);
                    _settingsTemplates.add(insertedSetting);
                    sortSettingsInternal();
                  });

                  Navigator.of(context).pop();
                }).catchError((e) {
                  Navigator.of(context).pop();

                  Utility().showMessageOkDialog(context,
                      title: 'Ошибка',
                      message: TextSpan(
                        text:
                            'В ходе создания шаблона настроек ${setting.toString()} возникла ошибка: $e',
                      ),
                      okButtonText: 'Ок');
                });
              },
            ),
          ],
        );
      },
    );
  }

  void sortSettingsInternal() {
    _settings.sort((a, b) {
      return a.toString().compareTo(b.toString());
    });
  }

  void editSettingsTemplates() {}

  Widget getCurrentSettingsTemplate() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black54,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(_currentSettings.toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppState().refreshDialog = setState;
    _connection = Provider.of<WebSocketConnection>(context, listen: true);
    return DefaultTabController(
        length: _tabLenght,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Назад',
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                SoundPlayer.cancelSound();
                Navigator.of(context).pop();
              },
            ),
            title: Row(
              children: [
                Expanded(
                  child: Container(),
                ),
                Icon(Icons.settings),
                Container(
                  width: 10,
                ),
                Text('Настройки'),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
            centerTitle: true,
            actions: <Widget>[
              Tooltip(
                message:
                    'Восстановить настройки по умолчанию на текущей вкладке',
                child: TextButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      CircleBorder(side: BorderSide(color: Colors.transparent)),
                    ),
                  ),
                  onPressed: restoreDefaultSettingsForTab,
                  child: Icon(Icons.restore_page),
                ),
              ),
              Tooltip(
                message: 'Восстановить настройки по умолчанию для всех вкладок',
                child: TextButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      CircleBorder(side: BorderSide(color: Colors.transparent)),
                    ),
                  ),
                  onPressed: restoreDefaultSettings,
                  child: Icon(Icons.settings_backup_restore),
                ),
              ),
              Tooltip(
                message: 'Сохранить как настройки по умолчанию',
                child: TextButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      CircleBorder(side: BorderSide(color: Colors.transparent)),
                    ),
                  ),
                  onPressed: saveDefaultSettings,
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
                  icon: Icon(Icons.palette_outlined),
                  text: 'Палитра',
                ),
                Tab(
                  icon: Icon(
                    Icons.settings_applications,
                  ),
                  text: 'Схема оператора',
                ),
                Tab(
                  icon: Icon(Icons.settings_display),
                  text: 'Схема председателя',
                ),
                Tab(
                  icon: Icon(Icons.table_chart),
                  text: 'Табличный вид',
                ),
                Tab(
                  icon: Icon(Icons.people),
                  text: 'Депутаты',
                ),
                Tab(
                  icon: Icon(Icons.touch_app),
                  text: 'Голосование',
                ),
                Tab(
                  icon: Icon(Icons.list_alt),
                  text: 'Протокол',
                ),
                Tab(
                  icon: Icon(Icons.monitor),
                  text: 'Табло',
                ),
                Tab(
                  icon: Icon(Icons.list),
                  text: 'Список вопросов',
                ),
                Tab(
                  icon: Icon(Icons.drive_folder_upload),
                  text: 'Загрузка файлов',
                ),
                Tab(
                  icon: Icon(Icons.volume_up),
                  text: 'Сигналы',
                ),
                Tab(
                  icon: Icon(Icons.timer),
                  text: 'Интервалы',
                ),
                Tab(
                  icon: Icon(Icons.vpn_key),
                  text: 'Настройки лицензии',
                ),
                Tab(
                  icon: Icon(Icons.settings_applications),
                  text: 'Шаблоны настроек',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              getLegendSetting(),
              getOperatorSchemeSetting(),
              getManagerSchemeSetting(),
              getTableViewSettings(),
              getDeputyTab(),
              getVotingSessionTab(),
              getReportsTab(),
              getStoreboardSettingsTab(),
              getQuestionListTab(),
              getFilesTab(),
              getSignalsTab(),
              getIntervalsTab(),
              getLicenseSettingsTab(),
              getSettingsTab(),
            ],
          ),
        ));
  }

  Widget getLegendItem(
      void setColor(int value), int color, String caption1, String caption2) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            width: 170,
            child: Text(
              caption1,
              style: TextStyle(fontSize: 16),
            ),
          ),
          Container(width: 20),
          Container(
            width: 260,
            height: 50,
            decoration: BoxDecoration(
              color: Color(color),
              border: Border.all(
                color: Colors.black54,
                width: 1,
              ),
            ),
          ),
          Container(width: 20),
          Tooltip(
            message: 'Изменить $caption2',
            child: TextButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  CircleBorder(side: BorderSide(color: Colors.transparent)),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    Color _color = Color(color);
                    return AlertDialog(
                      title: Text('Выберите $caption2'),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: Color(color),
                          onColorChanged: (value) {
                            _color = value;
                          },
                        ),
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              child: Text('Отмена',
                                  style: TextStyle(fontSize: 20)),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            Container(
                              width: 20,
                            ),
                            TextButton(
                              child: Text('Ок', style: TextStyle(fontSize: 20)),
                              onPressed: () {
                                setState(() {
                                  setColor(_color.value);
                                });
                                DbHelper.saveSettings(_currentSettings);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        )
                      ],
                    );
                  },
                );
              },
              child: Icon(Icons.edit),
            ),
          ),
        ],
      ),
    );
  }

  Widget getLegendSetting() {
    if (!_isLoadingComplete) {
      return CommonWidgets().getLoadingStub();
    }

    var scrollContoller = ScrollController();

    return Scrollbar(
      thumbVisibility: true,
      controller: scrollContoller,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: scrollContoller,
        child: Center(
          child: Column(
            children: [
              getHeader('Палитра схемы'),
              getLegendItem((value) {
                _currentSettings.palletteSettings.backgroundColor = value;
              }, _currentSettings.palletteSettings.backgroundColor,
                  'Цвет фона:', 'цвет фона'),
              getLegendItem((value) {
                _currentSettings.palletteSettings.schemeBackgroundColor = value;
              }, _currentSettings.palletteSettings.schemeBackgroundColor,
                  'Цвет фона области схемы', 'цвет фона области схемы'),
              getLegendItem((value) {
                _currentSettings.palletteSettings.cellColor = value;
              }, _currentSettings.palletteSettings.cellColor, 'Цвет ячейки:',
                  'цвет ячейки'),
              getLegendItem((value) {
                _currentSettings.palletteSettings.alternateCellColor = value;
              }, _currentSettings.palletteSettings.alternateCellColor,
                  'Альтернативный цвет ячейки:', 'альтернативный цвет ячейки'),
              getStringSettingItem((value) {
                _currentSettings.palletteSettings.alternateRowNumbers = value;
              },
                  _currentSettings.palletteSettings.alternateRowNumbers,
                  'Номера альтернативно раскрашенных рядов',
                  'номера альтернативно раскрашенных рядов',
                  defaultRowNumbersValidator),
              getStringSettingItem((value) {
                _currentSettings.palletteSettings.paddingRowNumbers = value;
              },
                  _currentSettings.palletteSettings.paddingRowNumbers,
                  'Номера рядов с отступом',
                  'номера рядов с отступом',
                  defaultRowNumbersValidator),
              getIntSettingItem((value) {
                _currentSettings.palletteSettings.alternateRowPadding = value;
              }, _currentSettings.palletteSettings.alternateRowPadding,
                  'Отступ рядов:', 'Отступ рядов'),
              getLegendItem((value) {
                _currentSettings.palletteSettings.cellTextColor = value;
              }, _currentSettings.palletteSettings.cellTextColor,
                  'Цвет текста ячейки:', 'цвет текста ячейки'),
              getLegendItem((value) {
                _currentSettings.palletteSettings.cellBorderColor = value;
              }, _currentSettings.palletteSettings.cellBorderColor,
                  'Цвет границы ячейки:', 'цвет границы ячейки'),
              getHeader('Палитра опций голосования'),
              getLegendItem((value) {
                _currentSettings.palletteSettings.unRegistredColor = value;
              }, _currentSettings.palletteSettings.unRegistredColor,
                  'Не зарегистрирован:', 'цвет Не зарегистрирован'),
              getLegendItem((value) {
                _currentSettings.palletteSettings.registredColor = value;
              }, _currentSettings.palletteSettings.registredColor,
                  'Зарегистрирован:', 'цвет Зарегистрирован'),
              getLegendItem((value) {
                _currentSettings.palletteSettings.voteYesColor = value;
              }, _currentSettings.palletteSettings.voteYesColor, 'За:',
                  'цвет За'),
              getLegendItem((value) {
                _currentSettings.palletteSettings.voteNoColor = value;
              }, _currentSettings.palletteSettings.voteNoColor, 'Против:',
                  'цвет Против'),
              getLegendItem((value) {
                _currentSettings.palletteSettings.voteIndifferentColor = value;
              }, _currentSettings.palletteSettings.voteIndifferentColor,
                  'Воздержался:', 'цвет Воздержался'),
              getLegendItem((value) {
                _currentSettings.palletteSettings.voteResetColor = value;
              }, _currentSettings.palletteSettings.voteResetColor, 'Сброс:',
                  'цвет Сброс'),
              getLegendItem((value) {
                _currentSettings.palletteSettings.askWordColor = value;
              }, _currentSettings.palletteSettings.askWordColor, 'Прошу слова:',
                  'цвет Прошу слова'),
              getLegendItem((value) {
                _currentSettings.palletteSettings.onSpeechColor = value;
              }, _currentSettings.palletteSettings.onSpeechColor,
                  'Идет выступление:', 'цвет Идет выступление'),
              getHeader('Палитра депутата'),
              getLegendItem((value) {
                _currentSettings.palletteSettings.buttonTextColor = value;
              },
                  _currentSettings.palletteSettings.buttonTextColor,
                  'Цвет текста и границы кнопок:',
                  'цвет текста и границы кнопок'),
              getHeader('Палитра иконок'),
              getLegendItem((value) {
                _currentSettings.palletteSettings.iconOnlineColor = value;
              }, _currentSettings.palletteSettings.iconOnlineColor,
                  'Цвет иконки онлайн:', 'цвет иконки онлайн'),
              getLegendItem((value) {
                _currentSettings.palletteSettings.iconOfflineColor = value;
              }, _currentSettings.palletteSettings.iconOfflineColor,
                  'Цвет иконки оффлайн:', 'цвет иконки оффлайн'),
              getLegendItem((value) {
                _currentSettings.palletteSettings.iconDocumentsDownloadedColor =
                    value;
              },
                  _currentSettings
                      .palletteSettings.iconDocumentsDownloadedColor,
                  'Цвет иконки документы загружены:',
                  'цвет иконки документы загружены'),
              getLegendItem((value) {
                _currentSettings
                    .palletteSettings.iconDocumentsNotDownloadedColor = value;
              },
                  _currentSettings
                      .palletteSettings.iconDocumentsNotDownloadedColor,
                  'Цвет иконки документы не загружены:',
                  'цвет иконки документы не загружены'),
            ],
          ),
        ),
      ),
    );
  }

  Widget getIntSettingItem(
      void setValue(int value), int value, String caption1, String caption2) {
    final formKey = GlobalKey<FormState>();
    final tecValue = TextEditingController(text: value.toString());

    return Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: TextField(
              controller: tecValue,
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '$caption1',
              ),
            ),
          ),
        ),
        Tooltip(
          message: 'Изменить $caption2',
          child: TextButton(
            style: ButtonStyle(
              shape: WidgetStateProperty.all(
                CircleBorder(side: BorderSide(color: Colors.transparent)),
              ),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Введите $caption2'),
                    content: Form(
                      key: formKey,
                      child: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            TextFormField(
                              controller: tecValue,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '$caption1',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Введите $caption2';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Введите целое число';
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
                        padding: EdgeInsets.fromLTRB(0, 0, 20, 10),
                        child: TextButton(
                          child: Text('Отмена'),
                          onPressed: () {
                            setState(() {});
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 20, 10),
                        child: TextButton(
                          child: Text('Ок'),
                          onPressed: () {
                            if (formKey.currentState?.validate() != true) {
                              return;
                            }

                            setState(() {
                              setValue(int.parse(tecValue.text));
                            });

                            DbHelper.saveSettings(_currentSettings);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            child: Icon(Icons.edit),
          ),
        ),
        Container(
          width: 20,
        ),
      ],
    );
  }

  Widget getStringSettingItem(
      void setValue(String value),
      String value,
      String caption1,
      String caption2,
      String? validator(String? value, String fieldName),
      {bool multiline = false}) {
    final formKey = GlobalKey<FormState>();
    final tecValue = TextEditingController(text: value.toString());

    return Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: TextField(
              controller: tecValue,
              minLines: multiline ? 4 : 1,
              maxLines: multiline ? null : 1,
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '$caption1',
              ),
            ),
          ),
        ),
        Tooltip(
          message: 'Изменить $caption2',
          child: TextButton(
            style: ButtonStyle(
              shape: WidgetStateProperty.all(
                CircleBorder(side: BorderSide(color: Colors.transparent)),
              ),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Введите $caption2'),
                    content: Form(
                      key: formKey,
                      child: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            TextFormField(
                              controller: tecValue,
                              minLines: multiline ? 4 : 1,
                              maxLines: multiline ? null : 1,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '$caption1',
                              ),
                              validator: (value) {
                                return validator(value, caption2);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 20, 10),
                        child: TextButton(
                          child: Text('Отмена'),
                          onPressed: () {
                            setState(() {});
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 20, 10),
                        child: TextButton(
                          child: Text('Ок'),
                          onPressed: () {
                            if (formKey.currentState?.validate() != true) {
                              return;
                            }

                            setState(() {
                              setValue(tecValue.text);
                            });

                            DbHelper.saveSettings(_currentSettings);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            child: Icon(Icons.edit),
          ),
        ),
        Container(
          width: 20,
        ),
      ],
    );
  }

  Widget getFileSettingItem(void setValue(String value), String value,
      String caption, String? validator(String? value, String fieldName)) {
    final tecValue = TextEditingController(text: value.toString());

    return Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: TextField(
              controller: tecValue,
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '$caption',
              ),
            ),
          ),
        ),
        Tooltip(
          message: 'Проверить $caption',
          child: TextButton(
            style: ButtonStyle(
              foregroundColor: _connection.getServerState.playSound == value
                  ? WidgetStateProperty.all(Colors.lightGreenAccent)
                  : WidgetStateProperty.all(Colors.white),
              shape: WidgetStateProperty.all(
                CircleBorder(side: BorderSide(color: Colors.transparent)),
              ),
            ),
            onPressed: () async {
              await SoundPlayer.playSoundByPath(value);
              setState(() {});
            },
            child: Icon(Icons.volume_up),
          ),
        ),
        Tooltip(
          message: 'Изменить $caption',
          child: TextButton(
            style: ButtonStyle(
              shape: WidgetStateProperty.all(
                CircleBorder(side: BorderSide(color: Colors.transparent)),
              ),
            ),
            onPressed: () async {
              XTypeGroup typeGroup = XTypeGroup(
                label: 'Выберите $caption',
                extensions: <String>['mp3'],
              );
              final String initialDirectory =
                  (await getApplicationDocumentsDirectory()).path;
              final XFile? file = await openFile(
                acceptedTypeGroups: <XTypeGroup>[typeGroup],
                initialDirectory: initialDirectory,
              );

              setState(() {
                setValue(file?.path ?? '');
              });

              DbHelper.saveSettings(_currentSettings);
            },
            child: Icon(Icons.edit),
          ),
        ),
        Tooltip(
          message: 'Очистить $caption',
          child: TextButton(
            style: ButtonStyle(
              shape: WidgetStateProperty.all(
                CircleBorder(side: BorderSide(color: Colors.transparent)),
              ),
            ),
            onPressed: () async {
              setState(() {
                setValue('');
              });

              DbHelper.saveSettings(_currentSettings);
            },
            child: Icon(Icons.close),
          ),
        ),
        Container(
          width: 20,
        ),
      ],
    );
  }

  String? defaultStringFieldValidator(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Введите $fieldName';
    }

    return null;
  }

  String? defaultRowNumbersValidator(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '';
    } else {
      var rowNumbers = value.split(',');

      for (int i = 0; i < rowNumbers.length; i++) {
        if (int.tryParse(rowNumbers[i]) == null) {
          return 'Введите номера строк разделенные запятыми (напр: 1,2,4,9)';
        }
      }
    }

    return null;
  }

  String? emptyStringFieldValidator(String? value, String fieldName) {
    return null;
  }

  Widget getOperatorSchemeSetting() {
    if (!_isLoadingComplete) {
      return CommonWidgets().getLoadingStub();
    }

    var scrollContoller = ScrollController();

    return Scrollbar(
      thumbVisibility: true,
      controller: scrollContoller,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: scrollContoller,
        child: Column(
          children: [
            getHeader('Вид схемы'),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 20, 10),
              child: RadioListTile<bool>(
                title: Text('Табличный вид'),
                value: true,
                groupValue:
                    _currentSettings.operatorSchemeSettings.useTableView,
                onChanged: (bool? value) {
                  setState(() {
                    _currentSettings.operatorSchemeSettings.useTableView =
                        value == true;
                  });

                  DbHelper.saveSettings(_currentSettings);
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 20, 10),
              child: RadioListTile<bool>(
                title: Text('Схема зала'),
                value: false,
                groupValue:
                    _currentSettings.operatorSchemeSettings.useTableView,
                onChanged: (bool? value) {
                  setState(() {
                    _currentSettings.operatorSchemeSettings.useTableView =
                        value == true;
                  });

                  DbHelper.saveSettings(_currentSettings);
                },
              ),
            ),
            getHeader('Состав схемы'),
            Container(
              padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Row(
                children: [
                  Checkbox(
                    value: _currentSettings.operatorSchemeSettings.showLegend,
                    onChanged: (bool? value) {
                      setState(() {
                        _currentSettings.operatorSchemeSettings.showLegend =
                            value == true;
                      });

                      DbHelper.saveSettings(_currentSettings);
                    },
                  ),
                  Text('Отображать легенду'),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Row(
                children: [
                  Checkbox(
                    value: _currentSettings.operatorSchemeSettings.showTribune,
                    onChanged: (bool? value) {
                      setState(() {
                        _currentSettings.operatorSchemeSettings.showTribune =
                            value == true;
                      });

                      DbHelper.saveSettings(_currentSettings);
                    },
                  ),
                  Text('Отображать трибуну'),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Row(
                children: [
                  Checkbox(
                    value:
                        _currentSettings.operatorSchemeSettings.showStatePanel,
                    onChanged: (bool? value) {
                      setState(() {
                        _currentSettings.operatorSchemeSettings.showStatePanel =
                            value == true;
                      });

                      DbHelper.saveSettings(_currentSettings);
                    },
                  ),
                  Text('Отображать панель управления'),
                ],
              ),
            ),
            getHeader('Управление звуком'),
            Container(
              padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _currentSettings
                              .operatorSchemeSettings.controlSound,
                          onChanged: (bool? value) {
                            setState(() {
                              _currentSettings.operatorSchemeSettings
                                  .controlSound = value == true;
                            });

                            DbHelper.saveSettings(_currentSettings);
                          },
                        ),
                        Text('Управление микрофонами'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            getHeader('Пространственное положение'),
            Container(
              padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Row(
                children: [
                  Checkbox(
                    value:
                        _currentSettings.operatorSchemeSettings.inverseScheme,
                    onChanged: (bool? value) {
                      setState(() {
                        _currentSettings.operatorSchemeSettings.inverseScheme =
                            value == true;
                      });

                      DbHelper.saveSettings(_currentSettings);
                    },
                  ),
                  Text('Инвертировать схему'),
                ],
              ),
            ),
            getHeader('Размеры ячейки'),
            getIntSettingItem((value) {
              _currentSettings.operatorSchemeSettings.cellWidth = value;
            }, _currentSettings.operatorSchemeSettings.cellWidth,
                'Ширина ячейки', 'ширину ячейки'),
            getIntSettingItem((value) {
              _currentSettings.operatorSchemeSettings.cellManagementWidth =
                  value;
            }, _currentSettings.operatorSchemeSettings.cellManagementWidth,
                'Ширина ячейки президиума', 'ширину ячейки президиума'),
            getIntSettingItem((value) {
              _currentSettings.operatorSchemeSettings.cellTribuneWidth = value;
            }, _currentSettings.operatorSchemeSettings.cellTribuneWidth,
                'Ширина ячейки трибуны', 'ширину ячейки трибуны'),
            getIntSettingItem((value) {
              _currentSettings.operatorSchemeSettings.cellBorder = value;
            }, _currentSettings.operatorSchemeSettings.cellBorder,
                'Толщина границы ячейки', 'толщину границы ячейки'),
            getIntSettingItem((value) {
              _currentSettings.operatorSchemeSettings.cellInnerPadding = value;
            }, _currentSettings.operatorSchemeSettings.cellInnerPadding,
                'Отступ внутри ячейки', 'отступ внутри ячейки'),
            getIntSettingItem((value) {
              _currentSettings.operatorSchemeSettings.cellOuterPaddingVertical =
                  value;
            },
                _currentSettings
                    .operatorSchemeSettings.cellOuterPaddingVertical,
                'Отступ между ячейками по вертикали',
                'отступ между ячейками по вертикали'),
            getIntSettingItem((value) {
              _currentSettings
                  .operatorSchemeSettings.cellOuterPaddingHorisontal = value;
            },
                _currentSettings
                    .operatorSchemeSettings.cellOuterPaddingHorisontal,
                'Отступ между ячейками по горизонтали',
                'отступ между ячейками по горизонтали'),
            getHeader('Текст ячейки'),
            Container(
              padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Row(
                children: [
                  Checkbox(
                    value: _currentSettings
                        .operatorSchemeSettings.isShortNamesUsed,
                    onChanged: (bool? value) {
                      setState(() {
                        _currentSettings.operatorSchemeSettings
                            .isShortNamesUsed = value == true;
                      });

                      DbHelper.saveSettings(_currentSettings);
                    },
                  ),
                  Text('Использовать сокращенные имена (Фамилия И.О.)'),
                ],
              ),
            ),
            getIntSettingItem((value) {
              _currentSettings.operatorSchemeSettings.cellTextSize = value;
            }, _currentSettings.operatorSchemeSettings.cellTextSize,
                'Размер шрифта', 'размер шрифта'),
            Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  Text(
                    'При переполнениии текста:',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 20, 10),
              child: RadioListTile<String>(
                title: Text('Растягивать ячейку по высоте текста'),
                value: 'Растягивать ячейку по высоте текста',
                groupValue:
                    _currentSettings.operatorSchemeSettings.overflowOption,
                onChanged: (String? value) {
                  setState(() {
                    _currentSettings.operatorSchemeSettings.overflowOption =
                        value ?? '';
                  });

                  DbHelper.saveSettings(_currentSettings);
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 20, 10),
              child: RadioListTile<String>(
                title: Text('Обрезать текст'),
                value: 'Обрезать текст',
                groupValue:
                    _currentSettings.operatorSchemeSettings.overflowOption,
                onChanged: (String? value) {
                  setState(() {
                    _currentSettings.operatorSchemeSettings.overflowOption =
                        value ?? '';
                  });

                  DbHelper.saveSettings(_currentSettings);
                },
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
              child: Column(
                children: [
                  getIntSettingItem((value) {
                    _currentSettings.operatorSchemeSettings.textMaxLines =
                        value;
                  },
                      _currentSettings.operatorSchemeSettings.textMaxLines,
                      'Максимальное количество строк',
                      'максимальное количество строк'),
                  Container(
                    padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _currentSettings
                              .operatorSchemeSettings.showOverflow,
                          onChanged: (bool? value) {
                            setState(() {
                              _currentSettings.operatorSchemeSettings
                                  .showOverflow = value == true;
                            });

                            DbHelper.saveSettings(_currentSettings);
                          },
                        ),
                        Text('Показывать \'...\' при переполнении'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            getHeader('Иконки ячейки'),
            getIntSettingItem((value) {
              _currentSettings.operatorSchemeSettings.iconSize = value;
            }, _currentSettings.operatorSchemeSettings.iconSize,
                'Размер иконок', 'размер иконок'),
          ],
        ),
      ),
    );
  }

  Widget getManagerSchemeSetting() {
    if (!_isLoadingComplete) {
      return CommonWidgets().getLoadingStub();
    }

    var scrollContoller = ScrollController();

    return Scrollbar(
      thumbVisibility: true,
      controller: scrollContoller,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: scrollContoller,
        child: Center(
          child: Column(
            children: [
              getHeader('Вид схемы'),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: RadioListTile<bool>(
                  title: Text('Табличный вид'),
                  value: true,
                  groupValue:
                      _currentSettings.managerSchemeSettings.useTableView,
                  onChanged: (bool? value) {
                    setState(() {
                      _currentSettings.managerSchemeSettings.useTableView =
                          value == true;
                    });

                    DbHelper.saveSettings(_currentSettings);
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 20, 10),
                child: RadioListTile<bool>(
                  title: Text('Схема зала'),
                  value: false,
                  groupValue:
                      _currentSettings.managerSchemeSettings.useTableView,
                  onChanged: (bool? value) {
                    setState(() {
                      _currentSettings.managerSchemeSettings.useTableView =
                          value == true;
                    });

                    DbHelper.saveSettings(_currentSettings);
                  },
                ),
              ),
              getHeader('Состав схемы'),
              Container(
                padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: Row(
                  children: [
                    Checkbox(
                      value: _currentSettings.managerSchemeSettings.showLegend,
                      onChanged: (bool? value) {
                        setState(() {
                          _currentSettings.managerSchemeSettings.showLegend =
                              value == true;
                        });

                        DbHelper.saveSettings(_currentSettings);
                      },
                    ),
                    Text('Отображать легенду'),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: Row(
                  children: [
                    Checkbox(
                      value: _currentSettings.managerSchemeSettings.showTribune,
                      onChanged: (bool? value) {
                        setState(() {
                          _currentSettings.managerSchemeSettings.showTribune =
                              value == true;
                        });

                        DbHelper.saveSettings(_currentSettings);
                      },
                    ),
                    Text('Отображать трибуну'),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: Row(
                  children: [
                    Checkbox(
                      value:
                          _currentSettings.managerSchemeSettings.showStatePanel,
                      onChanged: (bool? value) {
                        setState(() {
                          _currentSettings.managerSchemeSettings
                              .showStatePanel = value == true;
                        });

                        DbHelper.saveSettings(_currentSettings);
                      },
                    ),
                    Text('Отображать панель управления'),
                  ],
                ),
              ),
              getHeader('Управление звуком'),
              Container(
                padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: Row(
                  children: [
                    Checkbox(
                      value:
                          _currentSettings.managerSchemeSettings.controlSound,
                      onChanged: (bool? value) {
                        setState(() {
                          _currentSettings.managerSchemeSettings.controlSound =
                              value == true;
                        });

                        DbHelper.saveSettings(_currentSettings);
                      },
                    ),
                    Text('Управление микрофонами'),
                  ],
                ),
              ),
              getHeader('Пространственное положение'),
              Container(
                padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: Row(
                  children: [
                    Checkbox(
                      value:
                          _currentSettings.managerSchemeSettings.inverseScheme,
                      onChanged: (bool? value) {
                        setState(() {
                          _currentSettings.managerSchemeSettings.inverseScheme =
                              value == true;
                        });

                        DbHelper.saveSettings(_currentSettings);
                      },
                    ),
                    Text('Инвертировать схему'),
                  ],
                ),
              ),
              getHeader('Размеры ячейки'),
              getIntSettingItem((value) {
                _currentSettings.managerSchemeSettings.cellWidth = value;
              }, _currentSettings.managerSchemeSettings.cellWidth,
                  'Ширина ячейки', 'ширину ячейки'),
              getIntSettingItem((value) {
                _currentSettings.managerSchemeSettings.cellManagementWidth =
                    value;
              }, _currentSettings.managerSchemeSettings.cellManagementWidth,
                  'Ширина ячейки президиума', 'ширину ячейки президиума'),
              getIntSettingItem((value) {
                _currentSettings.managerSchemeSettings.cellTribuneWidth = value;
              }, _currentSettings.managerSchemeSettings.cellTribuneWidth,
                  'Ширина ячейки трибуны', 'ширину ячейки трибуны'),
              getIntSettingItem((value) {
                _currentSettings.managerSchemeSettings.cellBorder = value;
              }, _currentSettings.managerSchemeSettings.cellBorder,
                  'Толщина границы ячейки', 'толщину границы ячейки'),
              getIntSettingItem((value) {
                _currentSettings.managerSchemeSettings.cellInnerPadding = value;
              }, _currentSettings.managerSchemeSettings.cellInnerPadding,
                  'Отступ внутри ячейки', 'отступ внутри ячейки'),
              getIntSettingItem((value) {
                _currentSettings
                    .managerSchemeSettings.cellOuterPaddingVertical = value;
              },
                  _currentSettings
                      .managerSchemeSettings.cellOuterPaddingVertical,
                  'Отступ между ячейками по вертикали',
                  'отступ между ячейками по вертикали'),
              getIntSettingItem((value) {
                _currentSettings
                    .managerSchemeSettings.cellOuterPaddingHorisontal = value;
              },
                  _currentSettings
                      .managerSchemeSettings.cellOuterPaddingHorisontal,
                  'Отступ между ячейками по горизонтали',
                  'отступ между ячейками по горизонтали'),
              getHeader('Текст ячейки'),
              Container(
                padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: Row(
                  children: [
                    Checkbox(
                      value: _currentSettings
                          .managerSchemeSettings.isShortNamesUsed,
                      onChanged: (bool? value) {
                        setState(() {
                          _currentSettings.managerSchemeSettings
                              .isShortNamesUsed = value == true;
                        });

                        DbHelper.saveSettings(_currentSettings);
                      },
                    ),
                    Text('Использовать сокращенные имена (Фамилия И.О.)'),
                  ],
                ),
              ),
              getIntSettingItem((value) {
                _currentSettings.managerSchemeSettings.cellTextSize = value;
              }, _currentSettings.managerSchemeSettings.cellTextSize,
                  'Размер шрифта', 'размер шрифта'),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    Text(
                      'При переполнениии текста:',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 10, 20, 10),
                child: RadioListTile<String>(
                  title: Text('Растягивать ячейку по высоте текста'),
                  value: 'Растягивать ячейку по высоте текста',
                  groupValue:
                      _currentSettings.managerSchemeSettings.overflowOption,
                  onChanged: (String? value) {
                    setState(() {
                      _currentSettings.managerSchemeSettings.overflowOption =
                          value ?? '';
                    });

                    DbHelper.saveSettings(_currentSettings);
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 10, 20, 10),
                child: RadioListTile<String>(
                  title: Text('Обрезать текст'),
                  value: 'Обрезать текст',
                  groupValue:
                      _currentSettings.managerSchemeSettings.overflowOption,
                  onChanged: (String? value) {
                    setState(() {
                      _currentSettings.managerSchemeSettings.overflowOption =
                          value ?? '';
                    });

                    DbHelper.saveSettings(_currentSettings);
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                child: Column(
                  children: [
                    getIntSettingItem((value) {
                      _currentSettings.managerSchemeSettings.textMaxLines =
                          value;
                    },
                        _currentSettings.managerSchemeSettings.textMaxLines,
                        'Максимальное количество строк',
                        'максимальное количество строк'),
                    Container(
                      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _currentSettings
                                .managerSchemeSettings.showOverflow,
                            onChanged: (bool? value) {
                              setState(() {
                                _currentSettings.managerSchemeSettings
                                    .showOverflow = value == true;
                              });

                              DbHelper.saveSettings(_currentSettings);
                            },
                          ),
                          Text('Показывать \'...\' при переполнении'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              getHeader('Иконки ячейки'),
              getIntSettingItem((value) {
                _currentSettings.managerSchemeSettings.iconSize = value;
              }, _currentSettings.managerSchemeSettings.iconSize,
                  'Размер иконок', 'размер иконок'),
              getHeader('Настройки текста депутата'),
              getIntSettingItem((value) {
                _currentSettings.managerSchemeSettings.deputyNumberFontSize =
                    value;
              },
                  _currentSettings.managerSchemeSettings.deputyNumberFontSize,
                  'Размер шрифта номера вопроса списка вопросов',
                  'размер шрифта номера вопроса списка вопросов'),
              getIntSettingItem((value) {
                _currentSettings.managerSchemeSettings.deputyFontSize = value;
              },
                  _currentSettings.managerSchemeSettings.deputyFontSize,
                  'Размер шрифта списка вопросов',
                  'размер шрифта списка вопросов'),
              getIntSettingItem((value) {
                _currentSettings.managerSchemeSettings.deputyCaptionFontSize =
                    value;
              },
                  _currentSettings.managerSchemeSettings.deputyCaptionFontSize,
                  'Размер заголовков описания вопроса',
                  'размер заголовков описания вопроса'),
              getIntSettingItem((value) {
                _currentSettings.managerSchemeSettings.deputyFilesListHeight =
                    value;
              }, _currentSettings.managerSchemeSettings.deputyFilesListHeight,
                  'Высота списка вопросов', 'Высота списка вопросов'),
            ],
          ),
        ),
      ),
    );
  }

  Widget getHeader(String header) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
            padding: EdgeInsets.fromLTRB(10, 18, 10, 17),
            color: Colors.lightBlue,
            child: Text(
              header,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget getTableViewSettings() {
    if (!_isLoadingComplete) {
      return CommonWidgets().getLoadingStub();
    }
    var scrollContoller = ScrollController();
    return Scrollbar(
      thumbVisibility: true,
      controller: scrollContoller,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: scrollContoller,
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            children: [
              getHeader('Настройки таблицы'),
              getIntSettingItem((value) {
                _currentSettings.tableViewSettings.columnsCount = value;
              }, _currentSettings.tableViewSettings.columnsCount,
                  'Количество столбцов', 'Количество столбцов'),
              Container(
                padding: EdgeInsets.fromLTRB(15, 10, 0, 10),
                child: Row(
                  children: [
                    Text('Выравнивание текста ячейки:'),
                    Container(
                      width: 20,
                    ),
                    DropdownButton<TextAlign>(
                      value: _currentSettings.tableViewSettings.cellTextAlign ==
                              'Слева'
                          ? TextAlign.left
                          : TextAlign.center,
                      hint: Text('Выравнивание текста ячейки'),
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (TextAlign? value) {
                        _currentSettings.tableViewSettings.cellTextAlign =
                            value == TextAlign.left ? 'Слева' : 'По центру';

                        DbHelper.saveSettings(_currentSettings);

                        setState(() {});
                      },
                      items: <TextAlign>[
                        TextAlign.left,
                        TextAlign.center,
                      ].map<DropdownMenuItem<TextAlign>>((TextAlign value) {
                        return DropdownMenuItem<TextAlign>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              getIntSettingItem((value) {
                _currentSettings.operatorSchemeSettings.cellInnerPadding =
                    value;
              }, _currentSettings.operatorSchemeSettings.cellInnerPadding,
                  'Отступ внутри ячейки', 'отступ внутри ячейки'),
              Container(
                padding: EdgeInsets.fromLTRB(15, 10, 0, 10),
                child: Row(
                  children: [
                    Checkbox(
                      value: _currentSettings.tableViewSettings.showLegend,
                      onChanged: (bool? value) {
                        setState(() {
                          _currentSettings.tableViewSettings.showLegend =
                              value == true;
                        });

                        DbHelper.saveSettings(_currentSettings);
                      },
                    ),
                    Text('Отображать легенду'),
                  ],
                ),
              ),
              getHeader('Текст ячейки'),
              Container(
                padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: Row(
                  children: [
                    Checkbox(
                      value: _currentSettings
                          .operatorSchemeSettings.isShortNamesUsed,
                      onChanged: (bool? value) {
                        setState(() {
                          _currentSettings.operatorSchemeSettings
                              .isShortNamesUsed = value == true;
                        });

                        DbHelper.saveSettings(_currentSettings);
                      },
                    ),
                    Text('Использовать сокращенные имена (Фамилия И.О.)'),
                  ],
                ),
              ),
              getIntSettingItem((value) {
                _currentSettings.operatorSchemeSettings.cellTextSize = value;
              }, _currentSettings.operatorSchemeSettings.cellTextSize,
                  'Размер шрифта', 'размер шрифта'),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    Text(
                      'При переполнениии текста:',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 10, 20, 10),
                child: RadioListTile<String>(
                  title: Text('Растягивать ячейку по высоте текста'),
                  value: 'Растягивать ячейку по высоте текста',
                  groupValue:
                      _currentSettings.operatorSchemeSettings.overflowOption,
                  onChanged: (String? value) {
                    setState(() {
                      _currentSettings.operatorSchemeSettings.overflowOption =
                          value ?? '';
                    });

                    DbHelper.saveSettings(_currentSettings);
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 10, 20, 10),
                child: RadioListTile<String>(
                  title: Text('Обрезать текст'),
                  value: 'Обрезать текст',
                  groupValue:
                      _currentSettings.operatorSchemeSettings.overflowOption,
                  onChanged: (String? value) {
                    setState(() {
                      _currentSettings.operatorSchemeSettings.overflowOption =
                          value ?? '';
                    });

                    DbHelper.saveSettings(_currentSettings);
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                child: Column(
                  children: [
                    getIntSettingItem((value) {
                      _currentSettings.operatorSchemeSettings.textMaxLines =
                          value;
                    },
                        _currentSettings.operatorSchemeSettings.textMaxLines,
                        'Максимальное количество строк',
                        'максимальное количество строк'),
                    Container(
                      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _currentSettings
                                .operatorSchemeSettings.showOverflow,
                            onChanged: (bool? value) {
                              setState(() {
                                _currentSettings.operatorSchemeSettings
                                    .showOverflow = value == true;
                              });

                              DbHelper.saveSettings(_currentSettings);
                            },
                          ),
                          Text('Показывать \'...\' при переполнении'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              getTableHeaderItemsHeader(),
              getTableHeaderItems(),
            ],
          ),
        ),
      ),
    );
  }

  Widget getVotingModesHeader() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(25, 7, 15, 7),
            color: Colors.lightBlue,
            child: Row(
              children: [
                Text(
                  'Режимы голосования',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Container(),
                ),
                Row(
                  children: [
                    _selectedVotingMode == null
                        ? Container()
                        : Tooltip(
                            message:
                                'Переместить выбранный режим голосования вверх',
                            child: TextButton(
                              style: ButtonStyle(
                                shape: WidgetStateProperty.all(
                                  CircleBorder(
                                      side: BorderSide(
                                          color: Colors.transparent)),
                                ),
                              ),
                              onPressed: () {
                                upVotingMode();
                              },
                              child: Icon(Icons.arrow_upward),
                            ),
                          ),
                    _selectedVotingMode == null
                        ? Container()
                        : Tooltip(
                            message:
                                'Переместить выбранный режим голосования вниз',
                            child: TextButton(
                              style: ButtonStyle(
                                shape: WidgetStateProperty.all(
                                  CircleBorder(
                                      side: BorderSide(
                                          color: Colors.transparent)),
                                ),
                              ),
                              onPressed: () {
                                downVotingMode();
                              },
                              child: Icon(Icons.arrow_downward),
                            ),
                          ),
                    Tooltip(
                      message: 'Добавить',
                      child: TextButton(
                        style: ButtonStyle(
                          shape: WidgetStateProperty.all(
                            CircleBorder(
                                side: BorderSide(color: Colors.transparent)),
                          ),
                        ),
                        onPressed: () {
                          showVotingModeDialog(true);
                        },
                        child: Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget getVotingModesTable() {
    return Container(
      height: 480,
      child: Scrollbar(
        thumbVisibility: true,
        controller: _votingModesScrollController,
        child: SingleChildScrollView(
          controller: _votingModesScrollController,
          child: DataTable(
            headingRowHeight: 0,
            columnSpacing: 0,
            horizontalMargin: 10,
            showCheckboxColumn: false,
            columns: [
              DataColumn(
                  label: Text(
                'Режимы голосования',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )),
            ],
            rows: _votingModes
                .map(
                  ((element) => DataRow(
                        color: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                          if (element == _selectedVotingMode) {
                            return Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3);
                          }
                          return Colors.transparent;
                        }),
                        cells: <DataCell>[
                          DataCell(
                            Row(
                              children: [
                                Expanded(
                                  child: Tooltip(
                                    message: _currentSettings.votingSettings
                                                .defaultVotingModeId ==
                                            element.id
                                        ? 'Вариант по умолчанию'
                                        : 'Установить вариант по умолчанию',
                                    child: RadioListTile<int>(
                                      title: Container(
                                        width: 0,
                                        height: 0,
                                      ),
                                      value: element.id,
                                      groupValue: _currentSettings
                                          .votingSettings.defaultVotingModeId,
                                      onChanged: (int? value) {
                                        setState(() {
                                          _currentSettings.votingSettings
                                              .defaultVotingModeId = value;
                                          _selectedVotingMode = element;
                                        });

                                        DbHelper.saveSettings(_currentSettings);
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 6,
                                  child: Text(element.name,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      softWrap: true),
                                ),
                                Expanded(
                                  flex: 0,
                                  child: Tooltip(
                                    message:
                                        'Редактировать наименование режима голосования',
                                    child: TextButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                Colors.transparent),
                                        foregroundColor:
                                            WidgetStateProperty.all(
                                                Colors.black),
                                        overlayColor: WidgetStateProperty.all(
                                            Colors.black12),
                                        shape: WidgetStateProperty.all(
                                          CircleBorder(
                                              side: BorderSide(
                                                  color: Colors.transparent)),
                                        ),
                                      ),
                                      onPressed: () {
                                        showVotingModeDialog(false);
                                      },
                                      child: Icon(Icons.edit),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 0,
                                  child: Tooltip(
                                    message: 'Удалить режим голосования',
                                    child: TextButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                Colors.transparent),
                                        foregroundColor:
                                            WidgetStateProperty.all(
                                                Colors.black),
                                        overlayColor: WidgetStateProperty.all(
                                            Colors.black12),
                                        shape: WidgetStateProperty.all(
                                          CircleBorder(
                                              side: BorderSide(
                                                  color: Colors.transparent)),
                                        ),
                                      ),
                                      onPressed: () async {
                                        var noButtonPressed = false;
                                        var title = 'Удалить режим голосования';

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

                                        removeVotingMode(element);
                                      },
                                      child: Icon(Icons.clear),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 5,
                                ),
                              ],
                            ),
                          ),
                        ],
                        selected: element == _selectedVotingMode,
                        onSelectChanged: (bool? value) {
                          if (value == true) {
                            setState(() {
                              _selectedVotingMode = element;
                              _selectedDecisionMode =
                                  DecisionModeHelper.getEnumValue(
                                      _selectedVotingMode.defaultDecision);
                            });
                          }
                        },
                      )),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  void removeVotingMode(VotingMode element) {
    http
        .delete(
      Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
          '/voting_modes/${element.id}'),
    )
        .then((response) {
      loadData();
    });
  }

  void upVotingMode() {
    var index = _votingModes.indexOf(_selectedVotingMode);

    if (index >= 1) {
      _votingModes[index - 1].orderNum += 1;
      _selectedVotingMode.orderNum -= 1;

      http
          .put(
              Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                  '/voting_modes/${_votingModes[index - 1].id}'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: json.encode(_votingModes[index - 1].toJson()))
          .then((response) {});
      http
          .put(
              Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                  '/voting_modes/${_selectedVotingMode.id}'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: json.encode(_selectedVotingMode.toJson()))
          .then((response) {
        setState(() {
          _votingModes.sort((a, b) => a.orderNum.compareTo(b.orderNum));
        });
      });
    }
  }

  void downVotingMode() {
    var index = _votingModes.indexOf(_selectedVotingMode);

    if (index < _votingModes.length) {
      _votingModes[index + 1].orderNum -= 1;
      _selectedVotingMode.orderNum += 1;

      http
          .put(
              Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                  '/voting_modes/${_selectedVotingMode.id}'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: json.encode(_selectedVotingMode.toJson()))
          .then((response) {});
      http
          .put(
              Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                  '/voting_modes/${_votingModes[index + 1].id}'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: json.encode(_votingModes[index + 1].toJson()))
          .then((response) {
        setState(() {
          _votingModes.sort((a, b) => a.orderNum.compareTo(b.orderNum));
        });
      });
    }
  }

  Widget getDeputyTab() {
    if (!_isLoadingComplete) {
      return CommonWidgets().getLoadingStub();
    }
    var scrollContoller = ScrollController();
    return Scrollbar(
      thumbVisibility: true,
      controller: scrollContoller,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: scrollContoller,
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            children: [
              getHeader('Отображать список вопросов'),
              Container(
                padding: EdgeInsets.fromLTRB(15, 10, 0, 10),
                child: Row(
                  children: [
                    Checkbox(
                      value: _currentSettings
                          .deputySettings.showQuestionsOnPreparation,
                      onChanged: (bool? value) {
                        setState(() {
                          _currentSettings.deputySettings
                              .showQuestionsOnPreparation = value == true;
                        });

                        DbHelper.saveSettings(_currentSettings);
                      },
                    ),
                    Text('На этапе подготовки заседания'),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(15, 10, 0, 10),
                child: Row(
                  children: [
                    Checkbox(
                      value: _currentSettings
                          .deputySettings.showQuestionsForRegistred,
                      onChanged: (bool? value) {
                        setState(() {
                          _currentSettings.deputySettings
                              .showQuestionsForRegistred = value == true;
                        });

                        DbHelper.saveSettings(_currentSettings);
                      },
                    ),
                    Text('Только для пользователей прошедших регистрацию'),
                  ],
                ),
              ),
              getHeader('Очередь записавшихся на выступление'),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: RadioListTile<bool>(
                  title: Text('Постоянная'),
                  value: false,
                  groupValue:
                      _currentSettings.deputySettings.useTempAskWordQueue,
                  onChanged: (bool? value) {
                    setState(() {
                      _currentSettings.deputySettings.useTempAskWordQueue =
                          value == true;
                    });

                    DbHelper.saveSettings(_currentSettings);
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 20, 10),
                child: RadioListTile<bool>(
                  title: Text('Временная'),
                  value: true,
                  groupValue:
                      _currentSettings.deputySettings.useTempAskWordQueue,
                  onChanged: (bool? value) {
                    setState(() {
                      _currentSettings.deputySettings.useTempAskWordQueue =
                          value == true;
                    });

                    DbHelper.saveSettings(_currentSettings);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getReportsTab() {
    if (!_isLoadingComplete) {
      return CommonWidgets().getLoadingStub();
    }
    var scrollContoller = ScrollController();
    return Scrollbar(
      thumbVisibility: true,
      controller: scrollContoller,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: scrollContoller,
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            children: [
              getHeader('Вывод сессий вопроса'),
              Container(
                padding: EdgeInsets.fromLTRB(15, 10, 0, 10),
                child: Row(
                  children: [
                    Checkbox(
                      value: _currentSettings.reportSettings.isLastResultsOnly,
                      onChanged: (bool? value) {
                        setState(() {
                          _currentSettings.reportSettings.isLastResultsOnly =
                              value == true;
                        });

                        DbHelper.saveSettings(_currentSettings);
                      },
                    ),
                    Text('Только последнее голосование по вопросу'),
                  ],
                ),
              ),
              getHeader('Подпись протокола'),
              getStringSettingItem((value) {
                _currentSettings.reportSettings.reportFooter = value;
              },
                  _currentSettings.reportSettings.reportFooter,
                  'Подпись протокола',
                  'Подпись протокола',
                  defaultStringFieldValidator,
                  multiline: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget getVotingSessionTab() {
    if (!_isLoadingComplete) {
      return CommonWidgets().getLoadingStub();
    }
    var scrollContoller = ScrollController();
    return Scrollbar(
      thumbVisibility: true,
      controller: scrollContoller,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: scrollContoller,
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            children: [
              getDefaultMeetingModeHeader(),
              getMeetingRegimSelector(
                (value) {
                  _currentSettings.votingSettings.votingRegim = value;
                },
                _currentSettings.votingSettings.votingRegim,
              ),
              getDefaultVotingModeHeader(),
              Container(
                padding: EdgeInsets.fromLTRB(15, 10, 0, 10),
                child: Row(
                  children: [
                    Checkbox(
                      value: _currentSettings.votingSettings.isVotingFixed,
                      onChanged: (bool? value) {
                        setState(() {
                          _currentSettings.votingSettings.isVotingFixed =
                              value == true;
                        });

                        DbHelper.saveSettings(_currentSettings);
                      },
                    ),
                    Text('Фиксированное голосование'),
                  ],
                ),
              ),
              getDefaultVotingCountHeader(),
              Container(
                padding: EdgeInsets.fromLTRB(15, 10, 0, 10),
                child: Row(
                  children: [
                    Checkbox(
                      value: _currentSettings
                              .votingSettings.isCountNotVotingAsIndifferent ==
                          true,
                      onChanged: (bool? value) {
                        setState(() {
                          _currentSettings.votingSettings
                              .isCountNotVotingAsIndifferent = value == true;
                        });

                        DbHelper.saveSettings(_currentSettings);
                      },
                    ),
                    Text(
                      'Учитывать не голосовавших как воздержавшихся',
                    ),
                  ],
                ),
              ),
              getDefaultSignalsHeader(),
              getIntSettingItem((value) {
                _currentSettings.votingSettings.defaultShowResultInterval =
                    value;
              },
                  _currentSettings.votingSettings.defaultShowResultInterval,
                  'Время демострации результатов голосования по умолчанию',
                  'Время демострации результатов голосования по умолчанию'),
              Container(
                height: 542,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          getVotingModesHeader(),
                          getVotingModesTable(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          getVotingDecisionHeader(),
                          getVotingDecisionTable(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getQuestionListTab() {
    if (!_isLoadingComplete) {
      return CommonWidgets().getLoadingStub();
    }
    var scrollContoller = ScrollController();
    return Scrollbar(
      thumbVisibility: true,
      controller: scrollContoller,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: scrollContoller,
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            children: [
              getHeader('Настройки файловой системы'),
              getStringSettingItem((value) {
                _currentSettings.questionListSettings.reportsFolderPath = value;
              },
                  _currentSettings.questionListSettings.reportsFolderPath,
                  'Путь папки отчетов',
                  'путь папки отчетов',
                  defaultStringFieldValidator),
              getStringSettingItem((value) {
                _currentSettings.questionListSettings.agendaFileExtension =
                    value;
              },
                  _currentSettings.questionListSettings.agendaFileExtension,
                  'Расширение файла повестки',
                  'расширение файла повестки',
                  defaultStringFieldValidator),
              getStringSettingItem((value) {
                _currentSettings.questionListSettings.fileNameTrimmer = value;
              },
                  _currentSettings.questionListSettings.fileNameTrimmer,
                  'Регулярное выражение обрезки имен файлов',
                  'Регулярное выражение обрезки имен файлов',
                  emptyStringFieldValidator),
              getHeader('Вывод нулевого вопроса'),
              getStringSettingItem((value) {
                _currentSettings.questionListSettings.firstQuestion
                    .defaultGroupName = value;
              },
                  _currentSettings
                      .questionListSettings.firstQuestion.defaultGroupName,
                  'Наименование нулевого вопроса',
                  'наименование нулевого вопроса',
                  defaultStringFieldValidator),
              getStringSettingItem((value) {
                _currentSettings
                    .questionListSettings.firstQuestion.storeboardStub = value;
              },
                  _currentSettings
                      .questionListSettings.firstQuestion.storeboardStub,
                  'Наименование нулевого вопроса на табло',
                  'наименование нулевого вопроса на табло',
                  defaultStringFieldValidator),
              getQuestionGroupWidget(
                  _currentSettings.questionListSettings.firstQuestion),
              getHeader('Вывод основных вопросов'),
              getStringSettingItem((value) {
                _currentSettings
                    .questionListSettings.mainQuestion.defaultGroupName = value;
              },
                  _currentSettings
                      .questionListSettings.mainQuestion.defaultGroupName,
                  'Наименование основных вопросов',
                  'наименование основных вопросов',
                  defaultStringFieldValidator),
              Container(
                padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: Row(
                  children: [
                    Checkbox(
                      value: _currentSettings
                          .questionListSettings.mainQuestion.isUseNumber,
                      onChanged: (bool? value) {
                        setState(() {
                          _currentSettings.questionListSettings.mainQuestion
                              .isUseNumber = value == true;
                        });

                        DbHelper.saveSettings(_currentSettings);
                      },
                    ),
                    Text('Использовать порядковый номер в заголовке вопроса'),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: RadioListTile<bool>(
                  title: Text('В начале заголовка'),
                  value: true,
                  groupValue: _currentSettings
                      .questionListSettings.mainQuestion.showNumberBeforeName,
                  onChanged: !_currentSettings
                          .questionListSettings.mainQuestion.isUseNumber
                      ? null
                      : (bool? value) {
                          setState(() {
                            _currentSettings.questionListSettings.mainQuestion
                                .showNumberBeforeName = value == true;
                          });

                          DbHelper.saveSettings(_currentSettings);
                        },
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 20, 10),
                child: RadioListTile<bool>(
                  title: Text('В конце заголовка'),
                  value: false,
                  groupValue: _currentSettings
                      .questionListSettings.mainQuestion.showNumberBeforeName,
                  onChanged: !_currentSettings
                          .questionListSettings.mainQuestion.isUseNumber
                      ? null
                      : (bool? value) {
                          setState(() {
                            _currentSettings.questionListSettings.mainQuestion
                                .showNumberBeforeName = value == true;
                          });

                          DbHelper.saveSettings(_currentSettings);
                        },
                ),
              ),
              getQuestionGroupWidget(
                  _currentSettings.questionListSettings.mainQuestion),
              getHeader('Вывод дополнительных вопросов'),
              getStringSettingItem((value) {
                _currentSettings.questionListSettings.additionalQiestion
                    .defaultGroupName = value;
              },
                  _currentSettings
                      .questionListSettings.additionalQiestion.defaultGroupName,
                  'Наименование дополнительных вопросов',
                  'наименование дополнительных вопросов',
                  defaultStringFieldValidator),
              Container(
                padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: Row(
                  children: [
                    Checkbox(
                      value: _currentSettings
                          .questionListSettings.additionalQiestion.isUseNumber,
                      onChanged: (bool? value) {
                        setState(() {
                          _currentSettings.questionListSettings
                              .additionalQiestion.isUseNumber = value == true;
                        });

                        DbHelper.saveSettings(_currentSettings);
                      },
                    ),
                    Text('Использовать порядковый номер в заголовке вопроса'),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: RadioListTile<bool>(
                  title: Text('В начале заголовка'),
                  value: true,
                  groupValue: _currentSettings.questionListSettings
                      .additionalQiestion.showNumberBeforeName,
                  onChanged: !_currentSettings
                          .questionListSettings.additionalQiestion.isUseNumber
                      ? null
                      : (bool? value) {
                          setState(() {
                            _currentSettings
                                .questionListSettings
                                .additionalQiestion
                                .showNumberBeforeName = value == true;
                          });

                          DbHelper.saveSettings(_currentSettings);
                        },
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 20, 10),
                child: RadioListTile<bool>(
                  title: Text('В конце заголовка'),
                  value: false,
                  groupValue: _currentSettings.questionListSettings
                      .additionalQiestion.showNumberBeforeName,
                  onChanged: !_currentSettings
                          .questionListSettings.additionalQiestion.isUseNumber
                      ? null
                      : (bool? value) {
                          setState(() {
                            _currentSettings
                                .questionListSettings
                                .additionalQiestion
                                .showNumberBeforeName = value == true;
                          });

                          DbHelper.saveSettings(_currentSettings);
                        },
                ),
              ),
              getQuestionGroupWidget(
                  _currentSettings.questionListSettings.additionalQiestion),
            ],
          ),
        ),
      ),
    );
  }

  Widget getFilesTab() {
    if (!_isLoadingComplete) {
      return CommonWidgets().getLoadingStub();
    }
    var scrollContoller = ScrollController();
    return Scrollbar(
      thumbVisibility: true,
      controller: scrollContoller,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: scrollContoller,
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            children: [
              getHeader('Сервер файлов'),
              getStringSettingItem((value) {
                _currentSettings.fileSettings.ip = value;
              }, _currentSettings.fileSettings.ip, 'Ip сервера', 'Ip сервера',
                  defaultStringFieldValidator),
              getIntSettingItem((value) {
                _currentSettings.fileSettings.port = value;
              }, _currentSettings.fileSettings.port, 'Порт сервера',
                  'Порт сервера'),
              getStringSettingItem((value) {
                _currentSettings.fileSettings.uploadPath = value;
              },
                  _currentSettings.fileSettings.uploadPath,
                  'Страница загрузки файлов на сервер',
                  'Страницу загрузки файлов на сервер',
                  defaultStringFieldValidator),
              getStringSettingItem((value) {
                _currentSettings.fileSettings.downloadPath = value;
              },
                  _currentSettings.fileSettings.downloadPath,
                  'Страница скачивания файлов c сервера',
                  'Страницу скачивания файлов c сервера',
                  defaultStringFieldValidator),
              getHeader('Очередь загрузки'),
              getIntSettingItem((value) {
                _currentSettings.fileSettings.queueSize = value;
              }, _currentSettings.fileSettings.queueSize, 'Длина очереди',
                  'Длину очереди'),
              getIntSettingItem((value) {
                _currentSettings.fileSettings.queueInterval = value;
              },
                  _currentSettings.fileSettings.queueInterval,
                  'Интервал между подключениями',
                  'Интервал между подключениями'),
            ],
          ),
        ),
      ),
    );
  }

  Widget getDefaultMeetingModeHeader() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(10, 18, 10, 17),
            color: Colors.lightBlue,
            child: Text(
              'Вид голосования по умолчанию',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget getDefaultVotingModeHeader() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(10, 18, 10, 17),
            color: Colors.lightBlue,
            child: Text(
              'Настройки режима голосования',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget getDefaultVotingCountHeader() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(10, 18, 10, 17),
            color: Colors.lightBlue,
            child: Text(
              'Настройки подсчета результатов голосования',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget getDefaultSignalsHeader() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(10, 18, 10, 17),
            color: Colors.lightBlue,
            child: Text(
              'Интервалы по умолчанию',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget getVotingDecisionHeader() {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
            padding: EdgeInsets.fromLTRB(10, 18, 10, 17),
            height: 62,
            color: Colors.lightBlue,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Принятие решения',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget getVotingDecisionTable() {
    return Container(
      height: 440,
      child: Scrollbar(
        thumbVisibility: true,
        controller: _votingDecisionsScrollController,
        child: SingleChildScrollView(
          controller: _votingDecisionsScrollController,
          child: Column(
            children: <Widget>[
              getVotingDecisionTableItem(DecisionMode.MajorityOfLawMembers),
              getVotingDecisionTableItem(DecisionMode.TwoThirdsOfLawMembers),
              getVotingDecisionTableItem(DecisionMode.OneThirdsOfLawMembers),
              getVotingDecisionTableItem(DecisionMode.MajorityOfChosenMembers),
              getVotingDecisionTableItem(DecisionMode.TwoThirdsOfChosenMembers),
              getVotingDecisionTableItem(DecisionMode.OneThirdsOfChosenMembers),
              getVotingDecisionTableItem(
                  DecisionMode.MajorityOfRegistredMembers),
              getVotingDecisionTableItem(
                  DecisionMode.TwoThirdsOfRegistredMembers),
              getVotingDecisionTableItem(
                  DecisionMode.OneThirdsOfRegistredMembers),
            ],
          ),
        ),
      ),
    );
  }

  Widget getVotingDecisionTableItem(DecisionMode item) {
    return Row(
      children: [
        Expanded(
          child: Tooltip(
            message: _selectedDecisionMode == item
                ? 'Вариант по умолчанию'
                : 'Установить вариант по умолчанию',
            child: RadioListTile<DecisionMode>(
              title: Text(DecisionModeHelper.getStringValue(item)),
              value: item,
              groupValue: _selectedDecisionMode,
              onChanged: (DecisionMode? value) {
                if (value != null) {
                  setDecisionMode(value);
                }
              },
            ),
          ),
        ),
        Tooltip(
          message: 'Отображать в списке вариантов',
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: Checkbox(
              value: isDecisionModeIncluded(item),
              onChanged: (value) {
                if (_selectedDecisionMode != item) {
                  setDecisionModeIncluded(item, value == true);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget getRowWrapper(DecisionMode item) {
    if (item == _selectedDecisionMode) {
      return Tooltip(
        message: 'Вариант по умолчанию',
      );
    }
    return Container();
  }

  void setDecisionMode(DecisionMode value) {
    _selectedDecisionMode = value;
    _selectedVotingMode.defaultDecision =
        DecisionModeHelper.getStringValue(_selectedDecisionMode);
    if (!_selectedVotingMode.includedDecisions
        .contains(_selectedVotingMode.defaultDecision + ';')) {
      _selectedVotingMode.includedDecisions +=
          _selectedVotingMode.defaultDecision + ';';
    }
    http
        .put(
            Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                '/voting_modes/${_selectedVotingMode.id}'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: json.encode(_selectedVotingMode.toJson()))
        .then((response) {
      setState(() {});
    });
  }

  bool isDecisionModeIncluded(DecisionMode value) {
    if (_selectedVotingMode != null) {
      if (_selectedVotingMode.includedDecisions
          .contains(DecisionModeHelper.getStringValue(value) + ';')) {
        return true;
      }
    }
    return false;
  }

  void setDecisionModeIncluded(DecisionMode decisionMode, bool isIncluded) {
    if (isIncluded) {
      if (!_selectedVotingMode.includedDecisions
          .contains(DecisionModeHelper.getStringValue(decisionMode) + ';')) {
        _selectedVotingMode.includedDecisions +=
            DecisionModeHelper.getStringValue(decisionMode) + ';';
      }
    } else {
      if (_selectedVotingMode.includedDecisions
          .contains(DecisionModeHelper.getStringValue(decisionMode) + ';')) {
        _selectedVotingMode.includedDecisions =
            _selectedVotingMode.includedDecisions.replaceAll(
                DecisionModeHelper.getStringValue(decisionMode) + ';', '');
      }
    }

    http
        .put(
            Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                '/voting_modes/${_selectedVotingMode.id}'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: json.encode(_selectedVotingMode.toJson()))
        .then((response) {
      setState(() {});
    });
  }

  Widget getTableHeaderItemsHeader() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(25, 7, 15, 7),
            color: Colors.lightBlue,
            child: Row(
              children: [
                Text(
                  'Настройки информационной панели',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Container(),
                ),
                Row(
                  children: [
                    _selectedHeaderItem == null
                        ? Container()
                        : Tooltip(
                            message:
                                'Переместить выбранный элемент информационной панели вверх',
                            child: TextButton(
                              style: ButtonStyle(
                                shape: WidgetStateProperty.all(
                                  CircleBorder(
                                      side: BorderSide(
                                          color: Colors.transparent)),
                                ),
                              ),
                              onPressed: () {
                                upTableHeaderItem();
                              },
                              child: Icon(Icons.arrow_upward),
                            ),
                          ),
                    _selectedHeaderItem == null
                        ? Container()
                        : Tooltip(
                            message:
                                'Переместить выбранный элемент информационной панели вниз',
                            child: TextButton(
                              style: ButtonStyle(
                                shape: WidgetStateProperty.all(
                                  CircleBorder(
                                      side: BorderSide(
                                          color: Colors.transparent)),
                                ),
                              ),
                              onPressed: () {
                                downTableHeaderItem();
                              },
                              child: Icon(Icons.arrow_downward),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget getTableHeaderItems() {
    return Container(
      height: 480,
      child: Scrollbar(
        thumbVisibility: true,
        controller: _headerItemsScrollController,
        child: SingleChildScrollView(
          controller: _headerItemsScrollController,
          child: Row(
            children: <Widget>[
              Expanded(
                child: DataTable(
                  headingRowHeight: 0,
                  columnSpacing: 0,
                  horizontalMargin: 10,
                  showCheckboxColumn: false,
                  columns: [
                    DataColumn(
                        label: Text(
                      'Наименование',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    )),
                    DataColumn(
                        label: Text(
                      'Значение',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    )),
                  ],
                  rows: _currentSettings.tableViewSettings.headerItems
                      .map(
                        ((element) => DataRow(
                              color: WidgetStateProperty.resolveWith<Color>(
                                  (Set<WidgetState> states) {
                                if (element == _selectedHeaderItem) {
                                  return Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.3);
                                }
                                return Colors.transparent;
                              }),
                              cells: <DataCell>[
                                DataCell(
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(element.name,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            softWrap: true),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 6,
                                        child: Text(element.name,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            softWrap: true),
                                      ),
                                      Expanded(
                                        flex: 0,
                                        child: Tooltip(
                                          message:
                                              'Редактировать наименование элемента информационной панели',
                                          child: TextButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStateProperty.all(
                                                      Colors.transparent),
                                              foregroundColor:
                                                  WidgetStateProperty.all(
                                                      Colors.black),
                                              overlayColor:
                                                  WidgetStateProperty.all(
                                                      Colors.black12),
                                              shape: WidgetStateProperty.all(
                                                CircleBorder(
                                                    side: BorderSide(
                                                        color: Colors
                                                            .transparent)),
                                              ),
                                            ),
                                            onPressed: () {
                                              showHeaderItemDialog();
                                            },
                                            child: Icon(Icons.edit),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 0,
                                        child: Tooltip(
                                          message:
                                              'Отображать элемент информационной панели',
                                          child: Checkbox(
                                            value: element.isVisible,
                                            onChanged: (value) {
                                              setState(() {
                                                element.isVisible =
                                                    value == true;
                                              });

                                              DbHelper.saveSettings(
                                                  _currentSettings);
                                            },
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              selected: element == _selectedHeaderItem,
                              onSelectChanged: (bool? value) {
                                if (value == true) {
                                  setState(() {
                                    _selectedHeaderItem = element;
                                  });
                                }
                              },
                            )),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void upTableHeaderItem() {
    var index = _currentSettings.tableViewSettings.headerItems
        .indexOf(_selectedHeaderItem);

    if (index >= 1) {
      _currentSettings.tableViewSettings.headerItems[index - 1].orderNum += 1;
      _selectedHeaderItem.orderNum -= 1;

      setState(() {
        _currentSettings.tableViewSettings.headerItems
            .sort((a, b) => a.orderNum.compareTo(b.orderNum));
      });
    }
  }

  void downTableHeaderItem() {
    var index = _currentSettings.tableViewSettings.headerItems
        .indexOf(_selectedHeaderItem);

    if (index < _votingModes.length) {
      _currentSettings.tableViewSettings.headerItems[index + 1].orderNum -= 1;
      _selectedHeaderItem.orderNum += 1;

      setState(() {
        _currentSettings.tableViewSettings.headerItems
            .sort((a, b) => a.orderNum.compareTo(b.orderNum));
      });
    }
  }

  void upSignal() {
    var index = _signals.indexOf(_selectedSignal!);

    if (index >= 1) {
      _signals[index - 1].orderNum += 1;
      _selectedSignal!.orderNum -= 1;

      http
          .put(
              Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                  '/signals/${_signals[index - 1].id}'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: json.encode(_signals[index - 1].toJson()))
          .then((response) {});
      http
          .put(
              Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                  '/signals/${_selectedSignal!.id}'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: json.encode(_selectedSignal!.toJson()))
          .then((response) {
        setState(() {
          _signals.sort((a, b) => a.orderNum.compareTo(b.orderNum));
        });
      });
    }
  }

  void downSignal() {
    var index = _signals.indexOf(_selectedSignal!);

    if (index < _signals.length) {
      _signals[index + 1].orderNum -= 1;
      _selectedSignal!.orderNum += 1;

      http
          .put(
              Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                  '/signals/${_selectedSignal!.id}'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: json.encode(_selectedSignal!.toJson()))
          .then((response) {});
      http
          .put(
              Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                  '/signals/${_signals[index + 1].id}'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: json.encode(_signals[index + 1].toJson()))
          .then((response) {
        setState(() {
          _signals.sort((a, b) => a.orderNum.compareTo(b.orderNum));
        });
      });
    }
  }

  void upInterval() {
    var index = _intervals.indexOf(_selectedInterval);

    if (index >= 1) {
      _intervals[index - 1].orderNum += 1;
      _selectedInterval.orderNum -= 1;

      http
          .put(
              Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                  '/intervals/${_intervals[index - 1].id}'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: json.encode(_signals[index - 1].toJson()))
          .then((response) {});
      http
          .put(
              Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                  '/intervals/${_selectedInterval.id}'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: json.encode(_selectedInterval.toJson()))
          .then((response) {
        setState(() {
          _intervals.sort((a, b) => a.orderNum.compareTo(b.orderNum));
        });
      });
    }
  }

  void downInterval() {
    var index = _intervals.indexOf(_selectedInterval);

    if (index < _intervals.length) {
      _intervals[index + 1].orderNum -= 1;
      _selectedInterval.orderNum += 1;

      http
          .put(
              Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                  '/intervals/${_selectedInterval.id}'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: json.encode(_selectedInterval.toJson()))
          .then((response) {});
      http
          .put(
              Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
                  '/intervals/${_intervals[index + 1].id}'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: json.encode(_intervals[index + 1].toJson()))
          .then((response) {
        setState(() {
          _intervals.sort((a, b) => a.orderNum.compareTo(b.orderNum));
        });
      });
    }
  }

  Widget getQuestionGroupWidget(QuestionGroupSettings questionGroupSettings) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: getStringSettingItem((value) {
                questionGroupSettings.descriptionCaption1 = value;
              },
                  questionGroupSettings.descriptionCaption1,
                  'Заголовок первого абзаца',
                  'Заголовок первого абзаца',
                  emptyStringFieldValidator),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Row(
                children: [
                  Checkbox(
                    value: questionGroupSettings.showCaption1OnStoreboard,
                    onChanged: (bool? value) {
                      setState(() {
                        questionGroupSettings.showCaption1OnStoreboard =
                            value == true;
                      });

                      DbHelper.saveSettings(_currentSettings);
                    },
                  ),
                  Text('Отображать на табло'),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Row(
                children: [
                  Checkbox(
                    value: questionGroupSettings.showCaption1InReports,
                    onChanged: (bool? value) {
                      setState(() {
                        questionGroupSettings.showCaption1InReports =
                            value == true;
                      });

                      DbHelper.saveSettings(_currentSettings);
                    },
                  ),
                  Text('Отображать в отчете'),
                ],
              ),
            ),
            Container(
              width: 40,
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: getStringSettingItem((value) {
                questionGroupSettings.descriptionCaption2 = value;
              },
                  questionGroupSettings.descriptionCaption2,
                  'Заголовок второго абзаца',
                  'Заголовок второго абзаца',
                  emptyStringFieldValidator),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Row(
                children: [
                  Checkbox(
                    value: questionGroupSettings.showCaption2OnStoreboard,
                    onChanged: (bool? value) {
                      setState(() {
                        questionGroupSettings.showCaption2OnStoreboard =
                            value == true;
                      });

                      DbHelper.saveSettings(_currentSettings);
                    },
                  ),
                  Text('Отображать на табло'),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Row(
                children: [
                  Checkbox(
                    value: questionGroupSettings.showCaption2InReports,
                    onChanged: (bool? value) {
                      setState(() {
                        questionGroupSettings.showCaption2InReports =
                            value == true;
                      });

                      DbHelper.saveSettings(_currentSettings);
                    },
                  ),
                  Text('Отображать в отчете'),
                ],
              ),
            ),
            Container(
              width: 40,
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: getStringSettingItem((value) {
                questionGroupSettings.descriptionCaption3 = value;
              },
                  questionGroupSettings.descriptionCaption3,
                  'Заголовок третьего абзаца',
                  'Заголовок третьего абзаца',
                  emptyStringFieldValidator),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Row(
                children: [
                  Checkbox(
                    value: questionGroupSettings.showCaption3OnStoreboard,
                    onChanged: (bool? value) {
                      setState(() {
                        questionGroupSettings.showCaption3OnStoreboard =
                            value == true;
                      });

                      DbHelper.saveSettings(_currentSettings);
                    },
                  ),
                  Text('Отображать на табло'),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Row(
                children: [
                  Checkbox(
                    value: questionGroupSettings.showCaption3InReports,
                    onChanged: (bool? value) {
                      setState(() {
                        questionGroupSettings.showCaption3InReports =
                            value == true;
                      });

                      DbHelper.saveSettings(_currentSettings);
                    },
                  ),
                  Text('Отображать в отчете'),
                ],
              ),
            ),
            Container(
              width: 40,
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: getStringSettingItem((value) {
                questionGroupSettings.descriptionCaption4 = value;
              },
                  questionGroupSettings.descriptionCaption4,
                  'Заголовок четвертого абзаца',
                  'Заголовок четвертого абзаца',
                  emptyStringFieldValidator),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Row(
                children: [
                  Checkbox(
                    value: questionGroupSettings.showCaption4OnStoreboard,
                    onChanged: (bool? value) {
                      setState(() {
                        questionGroupSettings.showCaption4OnStoreboard =
                            value == true;
                      });

                      DbHelper.saveSettings(_currentSettings);
                    },
                  ),
                  Text('Отображать на табло'),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Row(
                children: [
                  Checkbox(
                    value: questionGroupSettings.showCaption4InReports,
                    onChanged: (bool? value) {
                      setState(() {
                        questionGroupSettings.showCaption4InReports =
                            value == true;
                      });

                      DbHelper.saveSettings(_currentSettings);
                    },
                  ),
                  Text('Отображать в отчете'),
                ],
              ),
            ),
            Container(
              width: 40,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> showHeaderItemDialog() async {
    final formKey = GlobalKey<FormState>();

    _tecEditHeaderItemName.text = _selectedHeaderItem.name;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Изменение наименования элемента информационной панели'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: _tecEditHeaderItemName,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Наименование элемента информационной панели',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите наименование элемента информационной панели';
                      }
                      if (_currentSettings.tableViewSettings.headerItems.any(
                          (element) =>
                              element.name == value &&
                              element != _selectedHeaderItem)) {
                        return 'Элемента информационной панели с таким именем уже существует';
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
              padding: EdgeInsets.fromLTRB(0, 0, 20, 10),
              child: TextButton(
                child: Text('Отмена'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 20, 10),
              child: TextButton(
                child: Text('Ок'),
                onPressed: () {
                  if (formKey.currentState?.validate() != true) {
                    return;
                  }

                  setState(() {
                    _selectedHeaderItem.name = _tecEditHeaderItemName.text;
                  });

                  DbHelper.saveSettings(_currentSettings);

                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> showVotingModeDialog(bool isNew) async {
    final formKey = GlobalKey<FormState>();

    _tecEditVotingModeName.text = isNew ? '' : _selectedVotingMode.name;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isNew
              ? 'Создание режима голосования'
              : 'Изменение режима голосования'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: _tecEditVotingModeName,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Наименование режима голосования',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите наименование режима голосования';
                      }
                      if (_votingModes
                          .any((element) => element.name == value)) {
                        return 'Режим голосования с таким именем уже существует';
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
              padding: EdgeInsets.fromLTRB(0, 0, 20, 10),
              child: TextButton(
                child: Text('Отмена'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 20, 10),
              child: TextButton(
                child: Text('Ок'),
                onPressed: () {
                  if (formKey.currentState?.validate() != true) {
                    return;
                  }

                  if (isNew) {
                    int orderNum = 0;

                    if (_selectedVotingMode != null) {
                      _votingModes.forEach((element) {
                        if (element.orderNum > _selectedVotingMode.orderNum) {
                          element.orderNum += 1;

                          http.put(
                              Uri.http(
                                  ServerConnection.getHttpServerUrl(
                                      GlobalConfiguration()),
                                  '/voting_modes/${element.id}'),
                              headers: <String, String>{
                                'Content-Type':
                                    'application/json; charset=UTF-8',
                              },
                              body: json.encode(element.toJson()));
                        }
                      });
                      orderNum = _selectedVotingMode.orderNum + 1;
                    } else {
                      if (_votingModes.length > 0) {
                        orderNum = _votingModes.last.orderNum + 1;
                      }
                    }

                    setState(() {
                      var newVotingMode = VotingMode(
                        id: 0,
                        name: _tecEditVotingModeName.text,
                        orderNum: orderNum,
                        defaultDecision: DecisionModeHelper.getStringValue(
                            DecisionMode.MajorityOfLawMembers),
                        includedDecisions: getDefaultIncludedDecisions(),
                      );

                      http
                          .post(
                              Uri.http(
                                  ServerConnection.getHttpServerUrl(
                                      GlobalConfiguration()),
                                  '/voting_modes'),
                              headers: <String, String>{
                                'Content-Type':
                                    'application/json; charset=UTF-8',
                              },
                              body: json.encode(newVotingMode.toJson()))
                          .then((response) {
                        loadData();

                        Navigator.of(context).pop();
                      }).catchError((e) {
                        Navigator.of(context).pop();

                        Utility().showMessageOkDialog(context,
                            title: 'Ошибка',
                            message: TextSpan(
                              text:
                                  'В ходе создания режима голосования ${newVotingMode.name} возникла ошибка: $e',
                            ),
                            okButtonText: 'Ок');
                      });
                    });
                  } else {
                    setState(() {
                      _selectedVotingMode.name = _tecEditVotingModeName.text;
                    });
                    http
                        .put(
                            Uri.http(
                                ServerConnection.getHttpServerUrl(
                                    GlobalConfiguration()),
                                '/voting_modes/${_selectedVotingMode.id}'),
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: json.encode(_selectedVotingMode.toJson()))
                        .then((response) {});

                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> showSignalDialog(Signal signal) async {
    final formKey = GlobalKey<FormState>();

    var tecSignalName = TextEditingController(text: signal.name);
    var tecDuration = TextEditingController(text: signal.duration.toString());
    Color signalColor = Color(signal.color);
    String signalSoundPath = signal.soundPath;
    double signalVolume = signal.volume;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setStateForDialog) {
          _setStateForDialog = setStateForDialog;
          return AlertDialog(
            title: Container(
              color: Colors.blue,
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  Text(
                    signal.id == null ? 'Создать сигнал' : 'Измененить сигнал',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                ],
              ),
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: TextFormField(
                        controller: tecSignalName,
                        maxLength: 20,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Наименование',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите наименование';
                          }

                          return null;
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: TextFormField(
                        controller: tecDuration,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Продолжительность цветовой индикации, c',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите цветовой индикации';
                          }
                          if (int.tryParse(value.toString()) == null) {
                            return 'Введите целое число';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                              'Цвет индикации',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Container(width: 20),
                          Container(
                            width: 260,
                            height: 50,
                            decoration: BoxDecoration(
                              color: signalColor,
                              border: Border.all(
                                color: Colors.black54,
                                width: 1,
                              ),
                            ),
                          ),
                          Container(width: 20),
                          Tooltip(
                            message: 'Изменить цвет индикации',
                            child: TextButton(
                              style: ButtonStyle(
                                shape: WidgetStateProperty.all(
                                  CircleBorder(
                                      side: BorderSide(
                                          color: Colors.transparent)),
                                ),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Выберите цвет индикации'),
                                      content: SingleChildScrollView(
                                        child: ColorPicker(
                                          pickerColor: signalColor,
                                          onColorChanged: (value) {
                                            signalColor = value;
                                          },
                                        ),
                                      ),
                                      actions: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              child: Text('Отмена',
                                                  style:
                                                      TextStyle(fontSize: 20)),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            Container(
                                              width: 20,
                                            ),
                                            TextButton(
                                              child: Text('Ок',
                                                  style:
                                                      TextStyle(fontSize: 20)),
                                              onPressed: () {
                                                setStateForDialog(() {
                                                  signalColor = signalColor;
                                                });
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        )
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Icon(Icons.edit),
                            ),
                          ),
                          Tooltip(
                            message: 'Удалить цвет',
                            child: TextButton(
                              style: ButtonStyle(
                                shape: WidgetStateProperty.all(
                                  CircleBorder(
                                      side: BorderSide(
                                          color: Colors.transparent)),
                                ),
                              ),
                              onPressed: () {
                                setStateForDialog(() {
                                  signalColor = Colors.transparent;
                                });
                              },
                              child: Icon(Icons.clear),
                            ),
                          ),
                        ],
                      ),
                    ),
                    getFileSettingItem(
                      (value) {
                        setStateForDialog(() {
                          signalSoundPath = value.trim();
                        });
                      },
                      signalSoundPath ?? '',
                      'Звуковой сигнал',
                      emptyStringFieldValidator,
                    ),
                    Slider(
                      value: signalVolume ?? 0,
                      max: 100,
                      divisions: 20,
                      label: signalVolume?.round()?.toString(),
                      onChanged: (double value) {
                        setStateForDialog(() {
                          signalVolume = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 20, 10),
                child: TextButton(
                  child: Text('Отмена'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 20, 10),
                child: TextButton(
                  child: Text('Ок'),
                  onPressed: () {
                    if (formKey.currentState?.validate() != true) {
                      return;
                    }

                    if (signal.id == null) {
                      int orderNum = 0;

                      if (_selectedSignal != null) {
                        _signals.forEach((element) {
                          if (element.orderNum > _selectedSignal!.orderNum) {
                            element.orderNum += 1;

                            http.put(
                                Uri.http(
                                    ServerConnection.getHttpServerUrl(
                                        GlobalConfiguration()),
                                    '/signals/${element.id}'),
                                headers: <String, String>{
                                  'Content-Type':
                                      'application/json; charset=UTF-8',
                                },
                                body: json.encode(element.toJson()));
                          }
                        });
                        orderNum = _selectedSignal!.orderNum + 1;
                      } else {
                        if (_signals.length > 0) {
                          orderNum = _signals.last.orderNum + 1;
                        }
                      }

                      setState(() {
                        signal.orderNum = orderNum;
                        signal.name = tecSignalName.text;
                        signal.duration = int.parse(tecDuration.text);
                        signal.soundPath = signalSoundPath;
                        signal.color = signalColor.value;
                        signal.volume = signalVolume;
                        http
                            .post(
                                Uri.http(
                                    ServerConnection.getHttpServerUrl(
                                        GlobalConfiguration()),
                                    '/signals'),
                                headers: <String, String>{
                                  'Content-Type':
                                      'application/json; charset=UTF-8',
                                },
                                body: json.encode(signal.toJson()))
                            .then((response) {
                          loadData();

                          Navigator.of(context).pop();
                        }).catchError((e) {
                          Navigator.of(context).pop();

                          Utility().showMessageOkDialog(context,
                              title: 'Ошибка',
                              message: TextSpan(
                                text:
                                    'В ходе создания сигнала выступления возникла ошибка: $e',
                              ),
                              okButtonText: 'Ок');
                        });
                      });
                    } else {
                      setState(() {
                        signal.name = tecSignalName.text;
                        signal.duration = int.parse(tecDuration.text);
                        signal.color = signalColor.value;
                        signal.soundPath = signalSoundPath;
                        signal.volume = signalVolume;
                      });
                      http
                          .put(
                              Uri.http(
                                  ServerConnection.getHttpServerUrl(
                                      GlobalConfiguration()),
                                  '/signals/${signal.id}'),
                              headers: <String, String>{
                                'Content-Type':
                                    'application/json; charset=UTF-8',
                              },
                              body: json.encode(signal.toJson()))
                          .then((response) {});

                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            ],
          );
        });
      },
    ).then((value) {
      _setStateForDialog = null;
    });
  }

  Future<void> showIntervalDialog(
      ais.Interval interval, List<ais.Interval> intervals) async {
    final formKey = GlobalKey<FormState>();

    var tecIntervalName = TextEditingController(text: interval.name);
    var tecduration = TextEditingController(text: interval.duration.toString());

    var startSignal = interval.startSignal;
    var endSignal = interval.endSignal;
    var isActive = interval.isActive;
    var isAutoEnd = interval.isAutoEnd;

    tecduration.addListener(() {
      if (_setStateForDialog != null) {
        _setStateForDialog!(() {
          if (tecduration.text == null ||
              tecduration.text.isEmpty ||
              int.tryParse(tecduration.text) == null ||
              int.tryParse(tecduration.text) == 0) {
            isAutoEnd = false;
          }
        });
      }
    });

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setStateForDialog) {
          _setStateForDialog = setStateForDialog;
          return AlertDialog(
            title: Container(
              color: Colors.blue,
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  Text(
                    interval.id == null
                        ? 'Создать интервал'
                        : 'Измененить интервал',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                ],
              ),
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: TextFormField(
                        controller: tecIntervalName,
                        maxLength: 20,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Наименование',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите наименование';
                          }

                          return null;
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: TextFormField(
                        controller: tecduration,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Продолжительность интервала, с',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите продолжительность интервала';
                          }
                          if (int.tryParse(value.toString()) == null) {
                            return 'Введите целое число';
                          }
                          return null;
                        },
                      ),
                    ),
                    getSignalsSelector((value) {
                      setStateForDialog(() {
                        startSignal = value;
                      });
                    }, startSignal?.id, 'Сигнал с начала интервала'),
                    getSignalsSelector((value) {
                      setStateForDialog(() {
                        endSignal = value;
                      });
                    }, endSignal?.id, 'Сигнал окончания интервала'),
                    Container(
                      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isAutoEnd,
                            onChanged: (tecduration.text.isEmpty ||
                                    int.tryParse(tecduration.text) == null ||
                                    int.tryParse(tecduration.text) == 0)
                                ? null
                                : (bool? value) {
                                    setStateForDialog(() {
                                      isAutoEnd = value == true;
                                    });
                                  },
                          ),
                          Text('Авт. выкл.'),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isActive,
                            onChanged: (bool? value) {
                              setStateForDialog(() {
                                isActive = value == true;
                              });
                            },
                          ),
                          Text('Быстрый выбор'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 20, 10),
                child: TextButton(
                  child: Text('Отмена'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 20, 10),
                child: TextButton(
                  child: Text('Ок'),
                  onPressed: () {
                    if (formKey.currentState?.validate() != true) {
                      return;
                    }

                    if (interval.id == null) {
                      if (isActive &&
                          intervals.length > 0 &&
                          intervals
                                  .where((element) => element.isActive)
                                  .length >=
                              3) {
                        Utility().showMessageOkDialog(context,
                            title: 'Ошибка',
                            message: TextSpan(
                              text:
                                  'Максимальное количество активных интервалов 3.',
                            ),
                            okButtonText: 'Ок');

                        return;
                      }
                      int orderNum = 0;

                      if (_selectedInterval != null) {
                        _intervals.forEach((element) {
                          if (element.orderNum > _selectedInterval.orderNum) {
                            element.orderNum += 1;

                            http.put(
                                Uri.http(
                                    ServerConnection.getHttpServerUrl(
                                        GlobalConfiguration()),
                                    '/intervals/${element.id}'),
                                headers: <String, String>{
                                  'Content-Type':
                                      'application/json; charset=UTF-8',
                                },
                                body: json.encode(element.toJson()));
                          }
                        });
                        orderNum = _selectedInterval.orderNum + 1;
                      } else {
                        if (_intervals.length > 0) {
                          orderNum = _intervals.last.orderNum + 1;
                        }
                      }

                      setState(() {
                        interval.orderNum = orderNum;
                        interval.name = tecIntervalName.text;
                        interval.duration = int.parse(tecduration.text);
                        interval.startSignal = startSignal;
                        interval.endSignal = endSignal;
                        interval.isActive = isActive;
                        interval.isAutoEnd = isAutoEnd;

                        http
                            .post(
                                Uri.http(
                                    ServerConnection.getHttpServerUrl(
                                        GlobalConfiguration()),
                                    '/intervals'),
                                headers: <String, String>{
                                  'Content-Type':
                                      'application/json; charset=UTF-8',
                                },
                                body: json.encode(interval.toJson()))
                            .then((response) {
                          loadData();

                          Navigator.of(context).pop();
                        }).catchError((e) {
                          //Navigator.of(context).pop();

                          Utility().showMessageOkDialog(context,
                              title: 'Ошибка',
                              message: TextSpan(
                                text:
                                    'В ходе создания сигнала выступления возникла ошибка: $e',
                              ),
                              okButtonText: 'Ок');
                        });
                      });
                    } else {
                      if (isActive &&
                          intervals.length > 0 &&
                          intervals
                                  .where((element) =>
                                      element.isActive &&
                                      element.id != interval.id)
                                  .length >=
                              3) {
                        Utility().showMessageOkDialog(context,
                            title: 'Ошибка',
                            message: TextSpan(
                              text:
                                  'Максимальное количество активных интервалов 3.',
                            ),
                            okButtonText: 'Ок');

                        return;
                      }

                      setState(() {
                        interval.name = tecIntervalName.text;
                        interval.duration = int.parse(tecduration.text);
                        interval.startSignal = startSignal;
                        interval.endSignal = endSignal;
                        interval.isActive = isActive;
                        interval.isAutoEnd = isAutoEnd;
                      });

                      http
                          .put(
                              Uri.http(
                                  ServerConnection.getHttpServerUrl(
                                      GlobalConfiguration()),
                                  '/intervals/${interval.id}'),
                              headers: <String, String>{
                                'Content-Type':
                                    'application/json; charset=UTF-8',
                              },
                              body: json.encode(interval.toJson()))
                          .then((response) {});

                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            ],
          );
        });
      },
    ).then((value) {
      _setStateForDialog = null;
    });
  }

  String getDefaultIncludedDecisions() {
    return DecisionModeHelper.getStringValue(
            DecisionMode.MajorityOfLawMembers) +
        ';' +
        DecisionModeHelper.getStringValue(DecisionMode.TwoThirdsOfLawMembers) +
        ';' +
        DecisionModeHelper.getStringValue(DecisionMode.OneThirdsOfLawMembers) +
        ';' +
        DecisionModeHelper.getStringValue(
            DecisionMode.MajorityOfChosenMembers) +
        ';' +
        DecisionModeHelper.getStringValue(
            DecisionMode.TwoThirdsOfChosenMembers) +
        ';' +
        DecisionModeHelper.getStringValue(
            DecisionMode.OneThirdsOfChosenMembers) +
        ';' +
        DecisionModeHelper.getStringValue(
            DecisionMode.MajorityOfRegistredMembers) +
        ';' +
        DecisionModeHelper.getStringValue(
            DecisionMode.TwoThirdsOfRegistredMembers) +
        ';' +
        DecisionModeHelper.getStringValue(
            DecisionMode.OneThirdsOfRegistredMembers) +
        ';';
  }

  Widget getStoreboardSettingsTab() {
    if (!_isLoadingComplete) {
      return CommonWidgets().getLoadingStub();
    }

    var scrollContoller = ScrollController();

    return Scrollbar(
      thumbVisibility: true,
      controller: scrollContoller,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: scrollContoller,
        child: Center(
          child: Column(
            children: [
              getHeader('Палитра табло'),
              getLegendItem((value) {
                _currentSettings.storeboardSettings.backgroundColor = value;
              }, _currentSettings.storeboardSettings.backgroundColor,
                  'Цвет фона:', 'цвет фона'),
              getLegendItem((value) {
                _currentSettings.storeboardSettings.textColor = value;
              }, _currentSettings.storeboardSettings.textColor, 'Цвет текста:',
                  'цвет текста'),
              getLegendItem((value) {
                _currentSettings.storeboardSettings.decisionAcceptedColor =
                    value;
              }, _currentSettings.storeboardSettings.decisionAcceptedColor,
                  'Цвет \"Решение принято\":', 'Цвет \"Решение  принято\"'),
              getLegendItem((value) {
                _currentSettings.storeboardSettings.decisionDeclinedColor =
                    value;
              }, _currentSettings.storeboardSettings.decisionDeclinedColor,
                  'Цвет \"Решение не принято\"', 'Цвет \"Решение не принято\"'),
              getHeader('Размеры табло'),
              getIntSettingItem((value) {
                _currentSettings.storeboardSettings.height = value;
              }, _currentSettings.storeboardSettings.height, 'Высота табло',
                  'высоту табло'),
              getIntSettingItem((value) {
                _currentSettings.storeboardSettings.width = value;
              }, _currentSettings.storeboardSettings.width, 'Ширина табло',
                  'ширину табло'),
              getHeader('Отступы по краям'),
              getIntSettingItem((value) {
                _currentSettings.storeboardSettings.paddingLeft = value;
              }, _currentSettings.storeboardSettings.paddingLeft,
                  'Отступ слева', 'отступ слева'),
              getIntSettingItem((value) {
                _currentSettings.storeboardSettings.paddingTop = value;
              }, _currentSettings.storeboardSettings.paddingTop,
                  'Отступ сверху', 'отступ сверху'),
              getIntSettingItem((value) {
                _currentSettings.storeboardSettings.paddingRight = value;
              }, _currentSettings.storeboardSettings.paddingRight,
                  'Отступ справа', 'отступ справа'),
              getIntSettingItem((value) {
                _currentSettings.storeboardSettings.paddingBottom = value;
              }, _currentSettings.storeboardSettings.paddingBottom,
                  'Отступ снизу', 'отступ снизу'),
              getHeader('Настройки по умолчанию'),
              getStringSettingItem((value) {
                _currentSettings.storeboardSettings.meetingDescriptionTemplate =
                    value;
              },
                  _currentSettings
                      .storeboardSettings.meetingDescriptionTemplate,
                  'Шаблон описания заседания',
                  'шаблон описания заседания',
                  defaultStringFieldValidator,
                  multiline: true),
              getStringSettingItem(
                (value) {
                  _currentSettings.storeboardSettings.noDataText = value;
                },
                _currentSettings.storeboardSettings.noDataText,
                'Текст "Нет данных"',
                'текст "Нет данных"',
                defaultStringFieldValidator,
              ),
              getIntSettingItem((value) {
                _currentSettings.storeboardSettings.speakerInterval = value;
              },
                  _currentSettings.storeboardSettings.speakerInterval,
                  'Длительность выступления, сек.',
                  'длительность выступления, сек.'),
              getIntSettingItem((value) {
                _currentSettings.storeboardSettings.breakInterval = value;
              }, _currentSettings.storeboardSettings.breakInterval,
                  'Длительность перерыва, сек.', 'длительность перерыва, сек.'),
              getHeader('Настройки текста'),
              getIntSettingItem((value) {
                _currentSettings.storeboardSettings.meetingDescriptionFontSize =
                    value;
              },
                  _currentSettings
                      .storeboardSettings.meetingDescriptionFontSize,
                  'Размер шрифта описания заседания',
                  'размер шрифта описания заседания'),
              getIntSettingItem((value) {
                _currentSettings.storeboardSettings.meetingFontSize = value;
              },
                  _currentSettings.storeboardSettings.meetingFontSize,
                  'Размер шрифта наименования заседания',
                  'размер шрифта наименования заседания'),
              getIntSettingItem((value) {
                _currentSettings.storeboardSettings.groupFontSize = value;
              },
                  _currentSettings.storeboardSettings.groupFontSize,
                  'Размер шрифта наименования группы',
                  'размер шрифта наименования группы'),
              getIntSettingItem((value) {
                _currentSettings.storeboardSettings.customCaptionFontSize =
                    value;
              },
                  _currentSettings.storeboardSettings.customCaptionFontSize,
                  'Размер шрифта заголовка произвольного текста',
                  'Размер шрифта заголовка произвольного текста'),
              getIntSettingItem((value) {
                _currentSettings.storeboardSettings.customTextFontSize = value;
              },
                  _currentSettings.storeboardSettings.customTextFontSize,
                  'Размер шрифта произвольного текста',
                  'Размер шрифта произвольного текста'),
              getIntSettingItem((value) {
                _currentSettings.storeboardSettings.resultItemsFontSize = value;
              },
                  _currentSettings.storeboardSettings.resultItemsFontSize,
                  'Размер шрифта количества проголосовавших/зарегистрированных',
                  'размер шрифта количества проголосовавших/зарегистрированных'),
              getIntSettingItem((value) {
                _currentSettings.storeboardSettings.resultTotalFontSize = value;
              },
                  _currentSettings.storeboardSettings.resultTotalFontSize,
                  'размер шрифта результата голосования/регистрации',
                  'размер шрифта результата голосования/регистрации'),
              getIntSettingItem((value) {
                _currentSettings.storeboardSettings.timersFontSize = value;
              },
                  _currentSettings.storeboardSettings.timersFontSize,
                  'Размер шрифта таймеров голосования/регистрации',
                  'размер шрифта таймеров голосования/регистрации'),
              getIntSettingItem((value) {
                _currentSettings
                    .storeboardSettings.questionDescriptionFontSize = value;
              },
                  _currentSettings
                      .storeboardSettings.questionDescriptionFontSize,
                  'Размер шрифта описания вопроса',
                  'размер шрифта описания вопроса'),
              Container(
                padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: Row(
                  children: [
                    Checkbox(
                      value: _currentSettings
                          .storeboardSettings.justifyQuestionDescription,
                      onChanged: (bool? value) {
                        setState(() {
                          _currentSettings.storeboardSettings
                              .justifyQuestionDescription = value == true;
                        });

                        DbHelper.saveSettings(_currentSettings);
                      },
                    ),
                    Text('Растягивать текст вопроса по ширине экрана'),
                  ],
                ),
              ),
              getIntSettingItem((value) {
                _currentSettings.storeboardSettings.clockFontSize = value;
              }, _currentSettings.storeboardSettings.clockFontSize,
                  'Размер шрифта часов', 'размер шрифта часов'),
              Container(
                padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: Row(
                  children: [
                    Checkbox(
                      value: _currentSettings.storeboardSettings.clockFontBold,
                      onChanged: (bool? value) {
                        setState(() {
                          _currentSettings.storeboardSettings.clockFontBold =
                              value == true;
                        });

                        DbHelper.saveSettings(_currentSettings);
                      },
                    ),
                    Text('Жирный текст часов'),
                  ],
                ),
              ),
              getHeader('Настройки поимённых результатов'),
              getIntSettingItem((value) {
                _currentSettings.storeboardSettings.detailsAnimationDuration =
                    value;
              },
                  _currentSettings.storeboardSettings.detailsAnimationDuration,
                  'Время перехода между страницами (секунды)',
                  'Время перехода между страницами (секунды)'),
              getIntSettingItem((value) {
                _currentSettings.storeboardSettings.detailsRowsCount = value;
              },
                  _currentSettings.storeboardSettings.detailsRowsCount,
                  'Количество строк на странице',
                  'количество строк на странице'),
              getIntSettingItem((value) {
                _currentSettings.storeboardSettings.detailsFontSize = value;
              }, _currentSettings.storeboardSettings.detailsFontSize,
                  'Размер шрифта результатов', 'размер шрифта результатов'),
            ],
          ),
        ),
      ),
    );
  }

  Widget getSignalsTab() {
    if (!_isLoadingComplete) {
      return CommonWidgets().getLoadingStub();
    }

    var scrollContoller = ScrollController();

    return Scrollbar(
      thumbVisibility: true,
      controller: scrollContoller,
      child: Scrollbar(
        thumbVisibility: true,
        controller: scrollContoller,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: scrollContoller,
          child: Center(
            child: Column(
              children: [
                getHeader('Воспроизведение звука'),
                Container(
                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _currentSettings
                            .signalsSettings.isOperatorPlaySound,
                        onChanged: (bool? value) {
                          setState(() {
                            _currentSettings.signalsSettings
                                .isOperatorPlaySound = value == true;
                          });

                          DbHelper.saveSettings(_currentSettings);
                        },
                      ),
                      Text('Воспроизводить звук на месте оператора'),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _currentSettings
                            .signalsSettings.isStoreboardPlaySound,
                        onChanged: (bool? value) {
                          setState(() {
                            _currentSettings.signalsSettings
                                .isStoreboardPlaySound = value == true;
                          });

                          DbHelper.saveSettings(_currentSettings);
                        },
                      ),
                      Text('Воспроизводить звук на табло'),
                    ],
                  ),
                ),
                getHeader('Настройки гимна'),
                getFileSettingItem(
                  (value) {
                    _currentSettings.signalsSettings.hymnStart = value;
                  },
                  _currentSettings.signalsSettings.hymnStart,
                  'Гимн 1',
                  emptyStringFieldValidator,
                ),
                getFileSettingItem(
                  (value) {
                    _currentSettings.signalsSettings.hymnEnd = value;
                  },
                  _currentSettings.signalsSettings.hymnEnd,
                  'Гимн 2',
                  emptyStringFieldValidator,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        padding: EdgeInsets.fromLTRB(10, 18, 10, 17),
                        color: Colors.lightBlue,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Сигналы',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20),
                              ),
                            ),
                            _selectedSignal == null
                                ? Container()
                                : Tooltip(
                                    message:
                                        'Переместить выбранный сигнал вверх',
                                    child: TextButton(
                                      style: ButtonStyle(
                                        shape: WidgetStateProperty.all(
                                          CircleBorder(
                                              side: BorderSide(
                                                  color: Colors.transparent)),
                                        ),
                                      ),
                                      onPressed: () {
                                        upSignal();
                                      },
                                      child: Icon(Icons.arrow_upward),
                                    ),
                                  ),
                            _selectedSignal == null
                                ? Container()
                                : Tooltip(
                                    message:
                                        'Переместить выбранный сигнал вниз',
                                    child: TextButton(
                                      style: ButtonStyle(
                                        shape: WidgetStateProperty.all(
                                          CircleBorder(
                                              side: BorderSide(
                                                  color: Colors.transparent)),
                                        ),
                                      ),
                                      onPressed: () {
                                        downSignal();
                                      },
                                      child: Icon(Icons.arrow_downward),
                                    ),
                                  ),
                            Tooltip(
                              message: 'Добавить сигнал',
                              child: TextButton(
                                style: ButtonStyle(
                                  shape: WidgetStateProperty.all(
                                    CircleBorder(
                                        side: BorderSide(
                                            color: Colors.transparent)),
                                  ),
                                ),
                                onPressed: () {
                                  showSignalDialog(Signal(
                                    id: 0,
                                    name: '',
                                  ));
                                },
                                child: Icon(Icons.add),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                getSignalsTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getSignalsTable() {
    return Scrollbar(
      thumbVisibility: true,
      controller: _signalsScrollController,
      child: SingleChildScrollView(
        controller: _signalsScrollController,
        child: DataTable(
          columnSpacing: 1,
          horizontalMargin: 10,
          showCheckboxColumn: false,
          headingRowColor: WidgetStateProperty.all(Colors.black12),
          columns: [
            DataColumn(
              label: Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text(
                  'Наименование',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            DataColumn(
              label: Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text(
                  'Цвет',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            DataColumn(
              label: Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text(
                  'Продолжительность, с',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            DataColumn(
              label: Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text(
                  'Звук',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            DataColumn(
              label: Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text(
                  'Громкость',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            DataColumn(
              label: Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                width: 200,
              ),
            ),
          ],
          rows: _signals
              .map(
                ((element) => DataRow(
                      color: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                        if (element == _selectedSignal) {
                          return Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3);
                        }
                        return Colors.transparent;
                      }),
                      cells: <DataCell>[
                        DataCell(
                          Text(element.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              softWrap: true),
                        ),
                        DataCell(
                          Container(
                            width: 260,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color(element.color ?? 0),
                              border: Border.all(
                                color: Colors.black54,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              Expanded(
                                child: Container(),
                              ),
                              Text(element.duration.toString(),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  softWrap: true),
                              Expanded(
                                child: Container(),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(element.soundPath ?? "",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              softWrap: true),
                        ),
                        DataCell(
                          Row(
                            children: [
                              Slider(
                                value: element.volume ?? 0,
                                max: 100,
                                divisions: 20,
                                label: element.volume?.round()?.toString(),
                                onChanged: (double value) {
                                  setState(() {
                                    element.volume = value;
                                  });

                                  http.put(
                                      Uri.http(
                                          ServerConnection.getHttpServerUrl(
                                              GlobalConfiguration()),
                                          '/signals/${element.id}'),
                                      headers: <String, String>{
                                        'Content-Type':
                                            'application/json; charset=UTF-8',
                                      },
                                      body: json.encode(element.toJson()));
                                },
                              ),
                              SizedBox(
                                height: 15,
                                width: 40,
                                child: Text(
                                  (element.volume ?? 0).round().toString() +
                                      '%',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              Tooltip(
                                message: 'Проверить звуковой сигнал',
                                child: TextButton(
                                  style: ButtonStyle(
                                    foregroundColor: _connection
                                                    .getServerState.playSound !=
                                                null &&
                                            _connection.getServerState
                                                .playSound!.isNotEmpty &&
                                            _connection
                                                    .getServerState.playSound ==
                                                element.soundPath
                                        ? WidgetStateProperty.all(
                                            Colors.lightGreenAccent)
                                        : WidgetStateProperty.all(Colors.white),
                                    shape: WidgetStateProperty.all(
                                      CircleBorder(
                                          side: BorderSide(
                                              color: Colors.transparent)),
                                    ),
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      SoundPlayer.playSignal(element,
                                          isInternal: false);
                                    });
                                  },
                                  child: Icon(Icons.volume_up),
                                ),
                              ),
                              Tooltip(
                                message: 'Изменить сигнал',
                                child: TextButton(
                                  style: ButtonStyle(
                                    shape: WidgetStateProperty.all(
                                      CircleBorder(
                                          side: BorderSide(
                                              color: Colors.transparent)),
                                    ),
                                  ),
                                  onPressed: () async {
                                    await showSignalDialog(element);
                                  },
                                  child: Icon(Icons.edit),
                                ),
                              ),
                              Tooltip(
                                message: 'Удалить сигнал',
                                child: TextButton(
                                  style: ButtonStyle(
                                    shape: WidgetStateProperty.all(
                                      CircleBorder(
                                          side: BorderSide(
                                              color: Colors.transparent)),
                                    ),
                                  ),
                                  onPressed: () async {
                                    var noButtonPressed = false;
                                    var title = 'Удалить сигнал';

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

                                    removeSignal(element);
                                  },
                                  child: Icon(Icons.clear),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      selected: element == _selectedSignal,
                      onSelectChanged: (bool? value) {
                        if (value == true) {
                          setState(() {
                            _selectedSignal = element;
                          });
                        }
                      },
                    )),
              )
              .toList(),
        ),
      ),
    );
  }

  void removeSignal(Signal element) {
    http
        .delete(
      Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
          '/signals/${element.id}'),
    )
        .then((response) {
      loadData();
    });
  }

  Widget getIntervalsTab() {
    if (!_isLoadingComplete) {
      return CommonWidgets().getLoadingStub();
    }

    var scrollContoller = ScrollController();

    return Scrollbar(
      thumbVisibility: true,
      controller: scrollContoller,
      child: Scrollbar(
        thumbVisibility: true,
        controller: scrollContoller,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: scrollContoller,
          child: Center(
            child: Column(
              children: [
                getHeader('Стандартные интервалы'),
                getIntervalSelector((value) {
                  _currentSettings.intervalsSettings
                      .defaultRegistrationIntervalId = value?.id;
                },
                    _currentSettings
                        .intervalsSettings.defaultRegistrationIntervalId,
                    'Стандартный интервал регистрации'),
                getIntervalSelector((value) {
                  _currentSettings.intervalsSettings.defaultVotingIntervalId =
                      value?.id;
                }, _currentSettings.intervalsSettings.defaultVotingIntervalId,
                    'Стандартный интервал голосования'),
                getIntervalSelector((value) {
                  _currentSettings.intervalsSettings.defaultSpeakerIntervalId =
                      value?.id;
                }, _currentSettings.intervalsSettings.defaultSpeakerIntervalId,
                    'Стандартный интервал выступления'),
                getIntervalSelector((value) {
                  _currentSettings.intervalsSettings
                      .defaultAskWordQueueIntervalId = value?.id;
                },
                    _currentSettings
                        .intervalsSettings.defaultAskWordQueueIntervalId,
                    'Стандартный интервал записи в очередь выступлений'),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        padding: EdgeInsets.fromLTRB(10, 18, 10, 17),
                        color: Colors.lightBlue,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Интервалы',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20),
                              ),
                            ),
                            _selectedSignal == null
                                ? Container()
                                : Tooltip(
                                    message:
                                        'Переместить выбранный интервал вверх',
                                    child: TextButton(
                                      style: ButtonStyle(
                                        shape: WidgetStateProperty.all(
                                          CircleBorder(
                                              side: BorderSide(
                                                  color: Colors.transparent)),
                                        ),
                                      ),
                                      onPressed: () {
                                        upInterval();
                                      },
                                      child: Icon(Icons.arrow_upward),
                                    ),
                                  ),
                            _selectedSignal == null
                                ? Container()
                                : Tooltip(
                                    message:
                                        'Переместить выбранный интервал вниз',
                                    child: TextButton(
                                      style: ButtonStyle(
                                        shape: WidgetStateProperty.all(
                                          CircleBorder(
                                              side: BorderSide(
                                                  color: Colors.transparent)),
                                        ),
                                      ),
                                      onPressed: () {
                                        downInterval();
                                      },
                                      child: Icon(Icons.arrow_downward),
                                    ),
                                  ),
                            Tooltip(
                              message: 'Добавить интервал',
                              child: TextButton(
                                style: ButtonStyle(
                                  shape: WidgetStateProperty.all(
                                    CircleBorder(
                                        side: BorderSide(
                                            color: Colors.transparent)),
                                  ),
                                ),
                                onPressed: () {
                                  showIntervalDialog(
                                      ais.Interval(), _intervals);
                                },
                                child: Icon(Icons.add),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                getIntervalsTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getIntervalsTable() {
    return Scrollbar(
      thumbVisibility: true,
      controller: _intervalsScrollController,
      child: SingleChildScrollView(
        controller: _intervalsScrollController,
        child: DataTable(
          columnSpacing: 1,
          horizontalMargin: 10,
          showCheckboxColumn: false,
          headingRowColor: WidgetStateProperty.all(Colors.black12),
          columns: [
            DataColumn(
              label: Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text(
                  'Наименование',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            DataColumn(
              label: Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text(
                  'Продолжительность, с',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            DataColumn(
              label: Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text(
                  'Сигнал начала',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            DataColumn(
              label: Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text(
                  'Сигнал окончания',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            DataColumn(
              label: Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text(
                  'Авт. выкл.',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            DataColumn(
              label: Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text(
                  'Быстрый выбор',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            DataColumn(
              label: Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                width: 200,
              ),
            ),
          ],
          rows: _intervals
              .map(
                ((element) => DataRow(
                      color: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                        if (element == _selectedInterval) {
                          return Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3);
                        }
                        return Colors.transparent;
                      }),
                      cells: <DataCell>[
                        DataCell(
                          Text(element.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              softWrap: true),
                        ),
                        DataCell(
                          Row(
                            children: [
                              Expanded(
                                child: Container(),
                              ),
                              Text(element.duration.toString(),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  softWrap: true),
                              Expanded(
                                child: Container(),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          ModelWidgets().getSignalWidget(element.startSignal),
                        ),
                        DataCell(
                          ModelWidgets().getSignalWidget(element.endSignal),
                        ),
                        DataCell(
                          Row(
                            children: [
                              Expanded(
                                child: Container(),
                              ),
                              Checkbox(
                                value: element.isAutoEnd,
                                onChanged: null,
                              ),
                              Expanded(
                                child: Container(),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              Expanded(
                                child: Container(),
                              ),
                              Checkbox(
                                value: element.isActive,
                                onChanged: null,
                              ),
                              Expanded(
                                child: Container(),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              Tooltip(
                                message: 'Изменить интервал',
                                child: TextButton(
                                  style: ButtonStyle(
                                    shape: WidgetStateProperty.all(
                                      CircleBorder(
                                          side: BorderSide(
                                              color: Colors.transparent)),
                                    ),
                                  ),
                                  onPressed: () async {
                                    await showIntervalDialog(
                                        element, _intervals);
                                  },
                                  child: Icon(Icons.edit),
                                ),
                              ),
                              Tooltip(
                                message: 'Удалить интервал',
                                child: TextButton(
                                  style: ButtonStyle(
                                    shape: WidgetStateProperty.all(
                                      CircleBorder(
                                          side: BorderSide(
                                              color: Colors.transparent)),
                                    ),
                                  ),
                                  onPressed: () async {
                                    var noButtonPressed = false;
                                    var title = 'Удалить интервал';

                                    await Utility().showYesNoDialog(
                                      context,
                                      title: title,
                                      message: TextSpan(
                                        text:
                                            'Вы уверены, что хотите удалить ${title.toLowerCase()}?',
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

                                    removeInterval(element);
                                  },
                                  child: Icon(Icons.clear),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      selected: element == _selectedInterval,
                      onSelectChanged: (bool? value) {
                        if (value == true) {
                          setState(() {
                            _selectedInterval = element;
                          });
                        }
                      },
                    )),
              )
              .toList(),
        ),
      ),
    );
  }

  void removeInterval(ais.Interval element) {
    http
        .delete(
      Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
          '/intervals/${element.id}'),
    )
        .then((response) {
      loadData();
    });
  }

  Widget getSignalsSelector(
    void setValue(Signal? value),
    int? signalId,
    String title,
  ) {
    Signal currentSignal =
        _signals.firstWhere((element) => element.id == signalId);
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        children: [
          Container(
            width: 250,
            alignment: Alignment.centerRight,
            child: Text(title),
          ),
          Container(
            width: 20,
          ),
          DropdownButton<Signal>(
            value: currentSignal,
            icon: Icon(Icons.arrow_downward),
            iconSize: 32,
            elevation: 24,
            itemHeight: 60,
            style: TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (Signal? newValue) {
              if (newValue != null) {
                setState(() {
                  setValue(newValue);
                });
                DbHelper.saveSettings(_currentSettings);
              }
            },
            items: _signals.map<DropdownMenuItem<Signal>>((Signal value) {
              return DropdownMenuItem<Signal>(
                value: value,
                child: ModelWidgets().getSignalWidget(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget getIntervalSelector(
    void setValue(ais.Interval? value),
    int? intervalId,
    String title,
  ) {
    var currentInterval =
        _intervals.firstWhereOrNull((element) => element.id == intervalId);
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        children: [
          Text(title),
          Container(
            width: 20,
          ),
          DropdownButton<ais.Interval>(
            value: currentInterval,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (ais.Interval? newValue) {
              if (newValue != null) {
                setState(() {
                  setValue(newValue);
                });
                DbHelper.saveSettings(_currentSettings);
              }
            },
            items: _intervals
                .map<DropdownMenuItem<ais.Interval>>((ais.Interval value) {
              return DropdownMenuItem<ais.Interval>(
                value: value,
                child: Text(value.name),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget getMeetingRegimSelector(
    void setValue(String value),
    String interval,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        children: [
          Text('Вид голосования:'),
          Container(
            width: 20,
          ),
          DropdownButton<String>(
            value: interval,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String? newValue) {
              setState(() {
                setValue(newValue ?? '');
              });
              DbHelper.saveSettings(_currentSettings);
            },
            items: <String>['Поименное', 'Тайное']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget getLicenseSettingsTab() {
    if (!_isLoadingComplete) {
      return CommonWidgets().getLoadingStub();
    }
    return Column(
      children: [
        getHeader('Лицензионный ключ'),
        getStringSettingItem(
          (value) {
            _currentSettings.licenseSettings.licenseKey = value;
          },
          _currentSettings.licenseSettings.licenseKey,
          'Лицензионный ключ',
          'лицензионный ключ',
          licenseKeyValidator,
        ),
        LicenseManager(_currentSettings).getLicenseInfo(
            Provider.of<WebSocketConnection>(context, listen: true)
                .getServerState),
        getHeader('Версии клиентов'),
        Expanded(
          child: getVersionsTable(),
        ),
      ],
    );
  }

  Widget getVersionsTable() {
    var versions = Provider.of<WebSocketConnection>(context, listen: true)
        .getServerState
        .versions;
    var rowNumber = 0;

    if (versions.isEmpty) {
      return Container();
    }

    return Scrollbar(
      thumbVisibility: true,
      controller: _versionsScrollController,
      child: SingleChildScrollView(
        controller: _versionsScrollController,
        child: DataTable(
          columnSpacing: 1,
          horizontalMargin: 10,
          showCheckboxColumn: false,
          headingRowColor: WidgetStateProperty.all(Colors.black12),
          columns: [
            DataColumn(
              label: Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text(
                  '№',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            DataColumn(
              label: Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text(
                  'Тип подключения',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            DataColumn(
              label: Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text(
                  'Ид терминала',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            DataColumn(
              label: Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text(
                  'Пользователь',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            DataColumn(
              label: Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text(
                  'Версия',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
          ],
          rows: versions.entries.map(((element) {
            rowNumber++;
            var type = element.key.split(';')[0].replaceAll('type:', '');

            if (type == 'guest' || type == 'unknown_client') {
              type = 'Гость';
            } else if (type == 'operator') {
              type = 'Оператор';
            } else if (type == 'storeboard') {
              type = 'Табло';
            } else if (type == 'deputy') {
              type = 'Депутат';
            } else if (type == 'manager') {
              type = 'Председатель';
            } else if (type == 'stream_player') {
              type = 'Стрим плеер';
            } else if (type == 'vissonic_client') {
              type = 'Клиент Vissonic';
            }

            var terminalId =
                element.key.split(';')[1].replaceAll('terminalId:', '');
            var userText = element.key.split(';')[2].replaceAll('userId:', '');

            var userId = int.tryParse(userText);
            if (userId != null) {
              var user = widget.users
                  .firstWhereOrNull((element) => element.id == userId);

              if (user != null) {
                userText = user.getShortName();
              }
            }

            var version = element.value;

            return DataRow(
              cells: <DataCell>[
                DataCell(
                  Text(rowNumber.toString(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      softWrap: true),
                ),
                DataCell(
                  Text(type,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      softWrap: true),
                ),
                DataCell(
                  Row(
                    children: [
                      Expanded(
                        child: Container(),
                      ),
                      Text(terminalId,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          softWrap: true),
                      Expanded(
                        child: Container(),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      Expanded(
                        child: Container(),
                      ),
                      Text(userText,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          softWrap: true),
                      Expanded(
                        child: Container(),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      Expanded(
                        child: Container(),
                      ),
                      Text(
                        version,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        softWrap: true,
                        style: TextStyle(
                            color: version == _packageInfo.version
                                ? Colors.green
                                : Colors.red),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          })).toList(),
        ),
      ),
    );
  }

  String? licenseKeyValidator(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Введите $fieldName';
    }

    if (Settings().licenseSettings.licenseKeyRegex.stringMatch(value) !=
        value) {
      return 'Лицензионный ключ должен иметь формат:\n${Settings().licenseSettings.licenseKey}';
    }

    return null;
  }

  Widget getSettingsTab() {
    if (!_isLoadingComplete) {
      return CommonWidgets().getLoadingStub();
    }
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
                padding: EdgeInsets.fromLTRB(10, 18, 10, 17),
                color: Colors.lightBlue,
                child: Text(
                  'Шаблоны настроек',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 20),
                ),
              ),
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: HorizontalDataTable(
            verticalScrollbarStyle: ScrollbarStyle(
              isAlwaysShown: true,
            ),
            leftHandSideColumnWidth: 0,
            rightHandSideColumnWidth: MediaQuery.of(context).size.width,
            isFixedHeader: true,
            headerWidgets: _getTitleWidget(),
            leftSideItemBuilder: TableHelper().generateFirstColumnRow,
            rightSideItemBuilder: _generateRightHandSideColumnRow,
            itemCount: _settingsTemplates.length,
            rowSeparatorWidget: const Divider(
              color: Colors.black54,
              height: 1.0,
              thickness: 0.0,
            ),
            leftHandSideColBackgroundColor: Color(0xFFFFFFFF),
            rightHandSideColBackgroundColor: Color(0xFFFFFFFF),
          ),
          height: MediaQuery.of(context).size.height - 208,
        ),
      ],
    );
  }

  List<Widget> _getTitleWidget() {
    return [
      Container(
        height: 0.0,
        width: 0,
      ),
      Container(
        color: Colors.grey[350],
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 10,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.transparent),
                  foregroundColor: WidgetStateProperty.all(Colors.black),
                  overlayColor: WidgetStateProperty.all(Colors.black12),
                  padding: WidgetStateProperty.all(EdgeInsets.all(0)),
                ),
                child: Text('Наименование'),
                //  Container(
                //   child: Text(
                //     'Наименование' +
                //         (sortType == sortName
                //             ? (isAscending ? '  ↓' : '  ↑')
                //             : ''),
                //     style: TextStyle(fontWeight: FontWeight.bold),
                //   ),
                //   height: 56,
                //   padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                //   alignment: Alignment.centerLeft,
                // ),
                onPressed: () {
                  //sortUsers();
                },
              ),
            ),
            TableHelper().getTitleItemWidget('Дата создания', 5),
            Container(
              child: Text('', style: TextStyle(fontWeight: FontWeight.bold)),
              width: 165,
              height: 56,
              padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
              alignment: Alignment.centerLeft,
            ),
          ],
        ),
      ),
    ];
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: Container(
            child: Text(_settingsTemplates[index].toString()),
            height: 52,
            padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
            alignment: Alignment.centerLeft,
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            child: Text(DateFormat('dd.MM.yyyy')
                .format(_settingsTemplates[index].createdDate)),
            width: 300,
            height: 52,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
          ),
        ),
        Container(
          width: 165,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 15, 0),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(child: Container()),
              Tooltip(
                message: 'Удалить',
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(Colors.transparent),
                    overlayColor: WidgetStateProperty.all(Colors.black12),
                    shape: WidgetStateProperty.all(
                      CircleBorder(side: BorderSide(color: Colors.transparent)),
                    ),
                  ),
                  child: Icon(Icons.clear, color: Colors.blue),
                  onPressed: () {
                    removeSettings(_settingsTemplates[index]);
                  },
                ),
              ),
              Container(
                width: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void removeSettings(Settings setting) {
    http.delete(
        Uri.http(ServerConnection.getHttpServerUrl(GlobalConfiguration()),
            '/settings/${setting.id.toString()}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        }).then((value) => loadData());
  }

  @override
  void dispose() {
    AppState().refreshDialog = null;

    _tecVotingRegistrationTime.dispose();
    _tecLawUsersCount.dispose();
    _tecEditVotingModeName.dispose();

    _headerItemsScrollController.dispose();
    _votingModesScrollController.dispose();
    _votingDecisionsScrollController.dispose();
    _tabController.dispose();

    super.dispose();
  }
}
