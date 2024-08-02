import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ais_model/ais_model.dart';

class SchemeLegendWidget extends StatefulWidget {
  final Settings settings;
  final ServerState serverState;
  final Group group;
  final bool isOperatorView;
  final bool isSmallView;

  SchemeLegendWidget({
    Key? key,
    required this.settings,
    required this.serverState,
    required this.group,
    required this.isOperatorView,
    required this.isSmallView,
  }) : super(key: key);

  @override
  _SchemeLegendWidgetState createState() => _SchemeLegendWidgetState();
}

class _SchemeLegendWidgetState extends State<SchemeLegendWidget> {
  var _autoSizeGroup = AutoSizeGroup();
  var _autoSizeGroup2 = AutoSizeGroup();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        !widget.isOperatorView
            ? Container()
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Container()),
                  getLegendIconItem(
                    'Онлайн',
                    Icon(
                      Icons.circle,
                      color: Color(
                          widget.settings.palletteSettings.iconOnlineColor),
                    ),
                    widget.isSmallView ? 120 : 200,
                  ),
                  Expanded(child: Container()),
                  getLegendIconItem(
                    'Оффлайн',
                    Icon(
                      Icons.circle,
                      color: Color(
                          widget.settings.palletteSettings.iconOfflineColor),
                    ),
                    widget.isSmallView ? 120 : 200,
                  ),
                  Expanded(child: Container()),
                  getLegendIconItem(
                    'Файлы загружены',
                    Icon(
                      Icons.file_present,
                      color: Color(widget.settings.palletteSettings
                          .iconDocumentsDownloadedColor),
                    ),
                    200,
                  ),
                  Expanded(child: Container()),
                  getLegendIconItem(
                      'Файлы не загружены',
                      Icon(
                        Icons.file_present,
                        color: Color(widget.settings.palletteSettings
                            .iconDocumentsNotDownloadedColor),
                      ),
                      200),
                  Expanded(child: Container()),
                  getLegendIconItem(
                    'Выступление',
                    Icon(
                      Icons.monitor,
                      color: Colors.green,
                    ),
                    widget.isSmallView ? 140 : 200,
                  ),
                  Expanded(child: Container()),
                ],
              ),
        Container(
          height: 10,
        ),
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 15,
              ),
              getLegendColorItem(
                'Не зарегистрирован',
                Color(widget.settings.palletteSettings.unRegistredColor),
              ),
              Container(
                width: 15,
              ),
              getLegendColorItem(
                'Зарегистрирован',
                Color(widget.settings.palletteSettings.registredColor),
              ),
              Container(
                width: 15,
              ),
              getLegendColorItem(
                'За',
                Color(widget.settings.palletteSettings.voteYesColor),
              ),
              Container(
                width: 15,
              ),
              getLegendColorItem(
                'Против',
                Color(widget.settings.palletteSettings.voteNoColor),
              ),
              Container(
                width: 15,
              ),
              getLegendColorItem(
                'Воздержался',
                Color(widget.settings.palletteSettings.voteIndifferentColor),
              ),
              Container(
                width: 15,
              ),
              getLegendColorItem(
                'Прошу слова',
                Color(widget.settings.palletteSettings.askWordColor),
              ),
              Container(
                width: 15,
              ),
            ],
          ),
        ),
        Container(
          height: 10,
        ),
        widget.isOperatorView ||
                widget.settings.managerSchemeSettings.useTableView
            ? Container()
            : Row(
                children: [
                  Container(
                    width: 15,
                  ),
                  AutoSizeText(
                    'Установлено: ${widget.group.lawUsersCount.toString()}',
                    maxLines: 1,
                    group: _autoSizeGroup,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  AutoSizeText(
                    'Избрано: ${widget.group.chosenCount.toString()}',
                    maxLines: 1,
                    group: _autoSizeGroup,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  AutoSizeText(
                    'Кворум: ${widget.group.quorumCount.toString()}',
                    maxLines: 1,
                    group: _autoSizeGroup,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  AutoSizeText(
                    'Присутствуют: ${widget.serverState.usersRegistered.length}',
                    maxLines: 1,
                    group: _autoSizeGroup,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  AutoSizeText(
                    'Отсутствуют: ${widget.group.chosenCount - widget.serverState.usersRegistered.length}',
                    maxLines: 1,
                    group: _autoSizeGroup,
                    style:
                        TextStyle(fontSize: 300, fontWeight: FontWeight.w600),
                  ),
                  Container(
                    width: 15,
                  ),
                ],
              ),
      ],
    );
  }

  Widget getLegendIconItem(String name, Widget icon, double width) {
    return Container(
      constraints: BoxConstraints(
        minWidth: 120,
        maxWidth: 200,
      ),
      margin: EdgeInsets.fromLTRB(10, 10, 5, 5),
      width: width,
      height: 26,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black87, width: 1),
          color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          icon,
          Container(
            width: 5,
          ),
        ],
      ),
    );
  }

  Widget getLegendColorItem(String name, Color background) {
    return Expanded(
      child: Container(
        height: 35,
        decoration: BoxDecoration(
          color: background,
        ),
        child: Center(
          child: AutoSizeText(
            name,
            maxLines: 1,
            group: _autoSizeGroup,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 300,
              color:
                  background == Colors.black87 ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
