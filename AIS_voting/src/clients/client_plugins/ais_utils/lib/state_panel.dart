import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ais_model/ais_model.dart';
import 'package:ais_model/ais_model.dart' as ais;
import 'package:intl/intl.dart';

import 'license_manager.dart';
import 'license_widget.dart';

class StatePanelWidget extends StatefulWidget {
  final Settings settings;
  final ServerState serverState;
  final Meeting meeting;
  final List<ais.Interval> intervals;
  final ais.Interval selectedInterval;
  final bool autoEnd;
  final double volume;
  final bool isOperatorView;

  final void Function(StoreboardState storeboardState, String storeboardParams)
      setStoreboardStatus;
  final void Function(ais.Interval interval) setInterval;
  final void Function(bool autoEnd) setAutoEnd;
  final void Function(double value) setVolume;
  final void Function() navigateLicenseTab;
  final void Function() changeView;

  StatePanelWidget({
    Key key,
    this.settings,
    this.serverState,
    this.meeting,
    this.intervals,
    this.selectedInterval,
    this.autoEnd,
    this.volume,
    this.setStoreboardStatus,
    this.setAutoEnd,
    this.setInterval,
    this.setVolume,
    this.navigateLicenseTab,
    this.changeView,
    this.isOperatorView,
  }) : super(key: key);

  @override
  _StatePanelWidgetState createState() => _StatePanelWidgetState();
}

class _StatePanelWidgetState extends State<StatePanelWidget> {
  bool _isBlockMicButton = false;
  bool _isControlSound = false;
  bool _isBlockConnectButton = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isOperatorView) {
      _isControlSound = widget.settings.operatorSchemeSettings.controlSound;
    } else {
      _isControlSound = widget.settings.managerSchemeSettings.controlSound;
    }

    String lastUpdatedInfo = '';

    if (widget.meeting != null) {
      lastUpdatedInfo = '\r\nСтатус заседания: ${widget.meeting.status}' +
          ' от ${DateFormat('dd.MM.yyyy HH:mm:ss').format(widget.meeting.lastUpdated)}';
    }
    if (widget.serverState != null) {
      lastUpdatedInfo = '\r\nПоследнее изменение состояния системы: ' +
          '${DateFormat('dd.MM.yyyy HH:mm:ss').format(widget.serverState.timestamp)}';
    }

    bool isLoadingDocuments = widget.serverState != null &&
        json.decode(widget.serverState.params)['isLoadingDocuments'] == true;

    String isLoadingDocumentStatus =
        isLoadingDocuments ? '\r\nИдет загрузка документов' : '';

    return Column(
      children: [
        widget.isOperatorView ? Container() : getButtonsPanel(),
        Container(
          height: 50,
          color: Colors.lightBlueAccent.withOpacity(0.3),
          child: Row(
            children: [
              Container(
                width: 10,
              ),
              Tooltip(
                message:
                    'Сервер онлайн' + isLoadingDocumentStatus + lastUpdatedInfo,
                child: Stack(
                  children: [
                    isLoadingDocuments
                        ? Container(
                            width: 24,
                            height: 24,
                            margin: EdgeInsets.fromLTRB(0, 15, 0, 15),
                            child: CircularProgressIndicator(
                              color: Colors.green,
                            ),
                          )
                        : Container(
                            width: 24,
                          ),
                    Container(
                      width: 20,
                      height: 50,
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Icon(
                        Icons.circle,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 10,
              ),
              LicenseWidget(
                serverState: widget.serverState,
                settings: widget.settings,
                navigateLicenseTab: widget.navigateLicenseTab,
              ),
              Container(
                width: 20,
              ),
              SizedBox(
                height: 50,
                width: 44,
                child: Tooltip(
                  message: 'Изменить вид схемы',
                  child: TextButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                          EdgeInsets.fromLTRB(5, 0, 5, 0)),
                    ),
                    onPressed: () {
                      widget.changeView();
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.table_chart,
                          size: 32.0,
                          color: widget
                                  .settings.operatorSchemeSettings.useTableView
                              ? Colors.greenAccent
                              : Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: 3,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    getAutoEndWidget(),
                    Container(
                      width: 15,
                    ),
                    getIntervalPanel(),
                    Container(
                      width: 20,
                    ),
                    getSystemVolumePanel(),
                  ],
                ),
              ),
              widget.meeting?.status == null
                  ? Container()
                  : Row(
                      children: [
                        Container(
                          width: 20,
                        ),
                        SizedBox(
                          height: 50,
                          width: 44,
                          child: Tooltip(
                            message: 'Показать число присутсвующих',
                            child: TextButton(
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.fromLTRB(10, 0, 10, 0)),
                              ),
                              onPressed: () {
                                widget.setStoreboardStatus(
                                    StoreboardState.Completed, null);
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.touch_app,
                                    color: widget.serverState.storeboardState ==
                                            StoreboardState.Completed
                                        ? Colors.greenAccent
                                        : Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 3,
                        ),
                        SizedBox(
                          height: 50,
                          width: 44,
                          child: Tooltip(
                            message: 'Установить "ЗАСЕДАНИЕ ОТКРЫТО" на табло',
                            child: TextButton(
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.fromLTRB(5, 0, 5, 0)),
                              ),
                              onPressed: () {
                                widget.setStoreboardStatus(
                                    StoreboardState.Started, null);
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.play_arrow,
                                    size: 32.0,
                                    color: widget.serverState.storeboardState ==
                                            StoreboardState.Started
                                        ? Colors.greenAccent
                                        : Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 3,
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ],
    );
    ;
  }

  Widget getButtonsPanel() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(10),
            color: Colors.lightBlueAccent.withOpacity(0.3),
            child: Row(
              children: [
                Tooltip(
                  message: 'Добавить время выступления',
                  child: Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: TextButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                          EdgeInsets.all(14),
                        ),
                      ),
                      onPressed: () {
                        addSpeakerTime(30);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.add),
                          Text('30 сек.'),
                        ],
                      ),
                    ),
                  ),
                ),
                Tooltip(
                  message: 'Добавить время выступления',
                  child: Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: TextButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                          EdgeInsets.all(14),
                        ),
                      ),
                      onPressed: () {
                        addSpeakerTime(60);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.add),
                          Text('1 мин.'),
                        ],
                      ),
                    ),
                  ),
                ),
                Tooltip(
                  message: 'Добавить время выступления',
                  child: Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: TextButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                          EdgeInsets.all(14),
                        ),
                      ),
                      onPressed: () {
                        addSpeakerTime(120);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.add),
                          Text('2 мин.'),
                        ],
                      ),
                    ),
                  ),
                ),
                Tooltip(
                  message: 'Добавить время выступления',
                  child: Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: TextButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                          EdgeInsets.all(14),
                        ),
                      ),
                      onPressed: () {
                        addSpeakerTime(300);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.add),
                          Text('5 мин.'),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: TextButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                        EdgeInsets.all(14),
                      ),
                    ),
                    onPressed: () {},
                    child: Row(
                      children: [
                        Icon(Icons.folder),
                        Container(
                          width: 3,
                        ),
                        Text('Шаблоны'),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: TextButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                        EdgeInsets.all(14),
                      ),
                    ),
                    onPressed: () {},
                    child: Row(
                      children: [
                        Icon(Icons.monitor),
                        Container(
                          width: 3,
                        ),
                        Text('Табло'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void addSpeakerTime(int seconds) {}

  Widget getIntervalPanel() {
    int intervalsMaxCount =
        widget.intervals.length > 3 ? 3 : widget.intervals.length;

    var intervals = widget.intervals.sublist(0, intervalsMaxCount).toList();

    return Row(
      children: [
        Row(
          children: [
            Wrap(
              spacing: 15.0,
              children: List<Widget>.generate(
                intervals.length,
                (int index) {
                  return ChoiceChip(
                    label: Text(intervals[index].name),
                    selected: widget.selectedInterval == intervals[index],
                    selectedColor: Colors.blue,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected == true) {
                          widget.setInterval(intervals[index]);
                        } else {
                          widget.setInterval(null);
                        }
                      });
                    },
                  );
                },
              ).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget getAutoEndWidget() {
    return Row(
      children: [
        Text(
          'Авт.\nВЫКЛ.',
          textAlign: TextAlign.right,
        ),
        Container(
          width: 5,
        ),
        Checkbox(
          value: isAutoEndWidgetDisabled() ? false : widget.autoEnd,
          onChanged: isAutoEndWidgetDisabled()
              ? null
              : (bool value) {
                  setState(() {
                    widget.setAutoEnd(value);
                  });
                },
        ),
      ],
    );
  }

  bool isAutoEndWidgetDisabled() {
    return widget.selectedInterval != null &&
        widget.selectedInterval.duration == 0;
  }

  Widget getSystemVolumePanel() {
    return Tooltip(
      message: 'Общий уровень звука',
      child: Row(
        children: [
          Slider(
            value: widget.volume ?? 0,
            max: 100,
            divisions: 20,
            label: widget.volume?.round()?.toString(),
            onChanged: (double value) {
              widget.setVolume(value);
            },
          ),
          SizedBox(
            height: 15,
            width: 40,
            child: Text(
              widget.volume?.round()?.toString() + '%',
              textAlign: TextAlign.center,
            ),
          ),
          Icon(Icons.speaker),
          SizedBox(
            height: 35,
            width: 35,
            child: Tooltip(
              message: 'Уменьшить общий уровень звука на 10%',
              child: TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                      EdgeInsets.fromLTRB(5, 0, 5, 0)),
                ),
                onPressed: () {
                  widget.setVolume(
                      widget.volume - 10 <= 0 ? 0 : widget.volume - 10);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.remove,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 35,
            width: 35,
            child: Tooltip(
              message: 'Увеличить общий уровень звука на 10%',
              child: TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                      EdgeInsets.fromLTRB(5, 0, 5, 0)),
                ),
                onPressed: () {
                  widget.setVolume(
                      widget.volume + 10 >= 100 ? 100 : widget.volume + 10);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.add,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
