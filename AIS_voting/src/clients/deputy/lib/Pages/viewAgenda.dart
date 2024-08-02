import 'dart:convert' show json;
import 'package:ais_model/ais_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:deputy/Utils/table_utils.dart';
import 'package:global_configuration/global_configuration.dart';
import '../Utils/utils.dart';
import '../Widgets/voting_utils.dart';
import '/State/WebSocketConnection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ais_utils/ais_utils.dart';
import '../State/AppState.dart';

class ViewAgendaPage extends StatefulWidget {
  ViewAgendaPage({Key? key}) : super(key: key);

  @override
  _ViewAgendaPageState createState() => _ViewAgendaPageState();
}

class _ViewAgendaPageState extends State<ViewAgendaPage> {
  late ScrollController _questionsTableScrollController;
  late ScrollController _questionDescriptionScrollController;
  late ScrollController _questionFilesTableScrollController;
  late ScrollController _unregistredTableScrollController;

  late List<Question> _questions;
  late Question _firstQuestion;
  late Question? _highlightedQuestion;
  late Question? _selectedQuestion;
  late QuestionFile? _selectedQuestionFile;

  late bool _showRightPanel;
  late bool _isFirstQuestionPage;
  late bool _isSelectedQuestionPage;
  late bool _useNavigation;
  late bool _showTopPanel;
  late bool _showTopPanelOnFirstPage;
  late bool _showExitButtonTop;
  late bool _showExitButtonRight;
  late bool _showDebugInfo;

  late bool _showUnregistred;
  late int _defaultButtonsHeight;
  late int _defaultButtonsWidth;
  AutoSizeGroup autoSizeGroup = AutoSizeGroup();

  @override
  void initState() {
    super.initState();

    _showUnregistred =
        GlobalConfiguration().getValue('agenda_view_show_unregistred') ==
            'true';
    _showRightPanel =
        GlobalConfiguration().getValue('agenda_view_show_right_panel') ==
            'true';
    _isFirstQuestionPage =
        GlobalConfiguration().getValue('agenda_view_first_question_page') ==
            'true';
    _isSelectedQuestionPage =
        GlobalConfiguration().getValue('agenda_view_selected_question_page') ==
            'true';
    _useNavigation =
        GlobalConfiguration().getValue('agenda_view_use_navigation') == 'true';
    _showTopPanel =
        GlobalConfiguration().getValue('agenda_view_show_top_panel') == 'true';
    _showTopPanelOnFirstPage = GlobalConfiguration()
            .getValue('agenda_view_first_question_page_show_top_panel') ==
        'true';
    _showExitButtonTop = GlobalConfiguration()
            .getValue('agenda_view_top_panel_show_exit_button') ==
        'true';
    _showExitButtonRight = GlobalConfiguration()
            .getValue('agenda_view_right_panel_show_exit_button') ==
        'true';
    _showDebugInfo = GlobalConfiguration()
            .getValue('agenda_view_top_panel_show_debug_info') ==
        'true';
    _defaultButtonsHeight =
        int.parse(GlobalConfiguration().getValue('default_buttons_height'));
    _defaultButtonsWidth =
        int.parse(GlobalConfiguration().getValue('default_buttons_width'));

    if (AppState().getCurrentMeeting() != null) {
      _questions = AppState().getCurrentMeeting()!.agenda!.questions.toList();
      _firstQuestion = _questions.first;
      if (_isFirstQuestionPage) {
        _questions = _questions.sublist(1);
      }
    }

    _questionsTableScrollController = ScrollController(
        initialScrollOffset: AppState().getAgendaScrollPosition() ?? 0.0,
        keepScrollOffset: true);
    _questionsTableScrollController.addListener(scrollPosition);
    _questionDescriptionScrollController = new ScrollController();
    _questionFilesTableScrollController = new ScrollController();
    _unregistredTableScrollController = new ScrollController();

    if (AppState().getCurrentDocument() != null) {
      if (AppState().canUserNavigate()) {
        Provider.of<WebSocketConnection>(context, listen: false)
            .navigateToPage('/viewDocument');
      }
    }

    if (!_isSelectedQuestionPage) {
      setSelectedQuestion(AppState().getCurrentQuestion() ?? _questions.first);
    } else {
      setSelectedQuestion(AppState().getCurrentQuestion());
    }

    if (AppState().getAgendaDocument() != null) {
      _selectedQuestionFile = AppState().getAgendaDocument();
    }

    //initRenderers();
    //connectVideoPlayer(context);

    WebSocketConnection.updateAgenda = updateAgenda;
  }

  void updateAgenda() {
    setState(() {
      _questions = AppState().getCurrentMeeting()!.agenda!.questions.toList();
      _firstQuestion = _questions.first;
      if (_isFirstQuestionPage) {
        _questions = _questions.sublist(1);
      }

      setSelectedQuestion(null);
      _questionsTableScrollController.animateTo(0,
          duration: Duration(milliseconds: 200), curve: Curves.ease);
    });
  }

  scrollPosition() async {
    AppState().setAgendaScrollPosition(
        _questionsTableScrollController.position.pixels);
  }

  void setSelectedQuestion(Question? question) {
    if (question != null) {
      if (_questions.contains(question)) {
        _highlightedQuestion = question;
      }
      question.files.sort((a, b) => a.id.compareTo(b.id));
    } else {
      if (_questions.contains(_selectedQuestion)) {
        _highlightedQuestion = _selectedQuestion;
      }
    }

    if (!_questions.contains(_highlightedQuestion)) {
      _highlightedQuestion = _questions.first;
    }

    _selectedQuestion =
        question ?? (_isSelectedQuestionPage ? null : _highlightedQuestion);

    AppState().setCurrentQuestion(_selectedQuestion);
    AppState().setAgendaDocument(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
      backgroundColor: Colors.white,
    );
  }

  Widget body() {
    if (AppState().getCurrentMeeting() == null ||
        AppState().getSettings() == null) {
      return Container();
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: leftPanel(),
        ),
        !_showRightPanel
            ? Container()
            : Row(
                children: [
                  Container(width: 2, color: Colors.lightBlue),
                  Container(
                    width: AppState()
                        .getSettings()
                        .storeboardSettings
                        .width
                        .toDouble(),
                    child: rightPanel(),
                  ),
                ],
              ),
      ],
    );
  }

  Widget leftPanel() {
    Widget leftPanelContent;

    if (isFirstPage()) {
      leftPanelContent = getFirstQuestionTab();
    } else if (_selectedQuestion != null &&
        _isSelectedQuestionPage &&
        _useNavigation) {
      leftPanelContent = getSelectedQuestionDetailedTab();
    } else if (_isSelectedQuestionPage) {
      leftPanelContent = getQuestionsPanel();
    } else {
      leftPanelContent = getDetailedAgenda();
    }

    return Column(
      children: [
        !_showTopPanel || isFirstPage() && !_showTopPanelOnFirstPage
            ? Container()
            : getLeftPanelHeader(),
        Expanded(
          child: leftPanelContent,
        ),
        isFirstPage() ? Container() : getLeftPanelFooter(),
        Container(
          color: Colors.blue,
          height: 2,
        ),
      ],
    );
  }

  bool isFirstPage() {
    return _selectedQuestion == _firstQuestion && _isFirstQuestionPage;
  }

  Widget getFirstQuestionTab() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(0, 30, 0, 30),
          child: Row(children: [
            Expanded(
              child: Container(),
            ),
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 5,
                  ),
                ),
                child: VotingUtils().getExpandedButton(
                  context,
                  'Повестка заседания',
                  () {
                    setState(() {
                      setSelectedQuestion(null);
                    });
                  },
                  AutoSizeGroup(),
                  _defaultButtonsHeight,
                ),
              ),
            ),
            Expanded(
              child: Container(),
            ),
          ]),
        ),
        getHeader('Регламентные вопросы', EdgeInsets.fromLTRB(10, 30, 10, 30)),
        Expanded(
          child: getQuestionFilesList(),
        ),
        Container(
          height: 20,
        ),
      ],
    );
  }

  Widget getSelectedQuestionDetailedTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            children: [
              getHeader(
                _selectedQuestion.toString(),
                EdgeInsets.fromLTRB(10, 30, 10, 30),
              ),
              getQuestionDescription(),
              Container(
                height: 15,
              ),
              getHeader('Файлы вопроса (${_selectedQuestion!.files.length})',
                  EdgeInsets.fromLTRB(10, 30, 10, 30)),
              Expanded(
                child: getQuestionFilesList(),
              ),
              Container(
                height: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget getLeftPanelHeader() {
    // Provider should be observable for askword button refresh
    final connection = Provider.of<WebSocketConnection>(context, listen: true);
    var topPanelFontSize = AppState()
            .getSettings()
            .managerSchemeSettings
            .deputyFontSize
            .toDouble() *
        2;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(10),
            color: Colors.black54,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        AppState().getCurrentUser() == null
                            ? (AppState().getCurrentGuest().isEmpty)
                                ? 'Гость'
                                : AppState().getCurrentGuest()
                            : AppState().getCurrentUser().toString(),
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                AppState().getServerState().isStreamStarted &&
                        AppState().getServerState().streamControl == 'user'
                    ? TextButton(
                        onPressed: () {
                          AppState().setExitStream(false);
                          connection.processNavigation();
                        },
                        child: Text(
                          'Стрим',
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      )
                    : Container(),
                Container(
                  width: 10,
                ),
                !_showDebugInfo
                    ? Container()
                    : Tooltip(
                        message: AppState().getIsRegistred()
                            ? 'Зарегистрирован'
                            : 'Не зарегистрирован',
                        child: Icon(
                          Icons.people,
                          size: topPanelFontSize,
                          color: Color(AppState().getIsRegistred()
                              ? AppState()
                                  .getSettings()
                                  .palletteSettings
                                  .iconDocumentsDownloadedColor
                              : AppState()
                                  .getSettings()
                                  .palletteSettings
                                  .iconDocumentsNotDownloadedColor),
                        ),
                      ),
                !_showDebugInfo
                    ? Container()
                    : Tooltip(
                        message: AppState().getIsDocumentsDownloaded()
                            ? 'Документы не загружены'
                            : 'Документы загружены',
                        child: Icon(
                          Icons.file_present,
                          size: topPanelFontSize,
                          color: Color(AppState().getIsLoadingInProgress()
                              ? Colors.yellow.value
                              : AppState().getIsDocumentsDownloaded()
                                  ? AppState()
                                      .getSettings()
                                      .palletteSettings
                                      .iconDocumentsDownloadedColor
                                  : AppState()
                                      .getSettings()
                                      .palletteSettings
                                      .iconDocumentsNotDownloadedColor),
                        ),
                      ),
                !_showExitButtonTop || !connection.getIsManualLogin
                    ? Container()
                    : Tooltip(
                        message: 'Выход из гостевого режима',
                        child: TextButton(
                          onPressed: () {
                            Provider.of<WebSocketConnection>(context,
                                    listen: false)
                                .onUserExit();
                          },
                          child: Row(
                            children: [
                              Text(
                                'ВЫЙТИ',
                                style: TextStyle(
                                  fontSize: 24,
                                ),
                              ),
                              Container(
                                width: 20,
                              ),
                              Icon(
                                Icons.exit_to_app,
                                color: Colors.white,
                                size: 32,
                              ),
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

  Widget getNavigationButton() {
    bool showFirstQuestonNavigationButton = _isFirstQuestionPage;
    bool showQuestionListNavigationButton =
        _isSelectedQuestionPage && _selectedQuestion != null && _useNavigation;

    if (showQuestionListNavigationButton) {
      return Expanded(
        flex: 2,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: VotingUtils().getExpandedButton(
            context,
            'Повестка заседания',
            () {
              setState(() {
                setSelectedQuestion(null);
              });
            },
            AutoSizeGroup(),
            _defaultButtonsHeight,
          ),
        ),
      );
    }
    if (showFirstQuestonNavigationButton) {
      return Expanded(
        flex: 2,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: VotingUtils().getExpandedButton(
            context,
            'К регламентным вопросам',
            () {
              setState(() {
                setSelectedQuestion(_firstQuestion);
              });
            },
            AutoSizeGroup(),
            _defaultButtonsHeight,
          ),
        ),
      );
    }

    return Container();
  }

  Widget getLeftPanelFooter() {
    return Row(
      children: [
        Expanded(
          child: Container(),
        ),
        getNavigationButton(),
        _showRightPanel
            ? Container()
            : Expanded(
                flex: 2,
                child: Utils().getIsAskWordButtonDisabled()
                    ? Container()
                    : VotingUtils().getAskWordButton(
                        context,
                        setState,
                        AutoSizeGroup(),
                        _defaultButtonsHeight,
                        _defaultButtonsWidth,
                        false,
                      ),
              ),
        Expanded(
          child: Container(),
        ),
      ],
    );
  }

  Widget getDetailedAgenda() {
    return Row(
      children: [
        Container(
          width: 40 +
              StoreboardTextUtils(AppState().getSettings())
                  .textSize(
                      'Вопросы повестки',
                      TextStyle(
                          fontSize: AppState()
                              .getSettings()
                              .managerSchemeSettings
                              .deputyCaptionFontSize
                              .toDouble()))
                  .width,
          child: getQuestionsPanel(),
        ),
        Expanded(
          child: getQuestionDescriptionPanel(),
        ),
      ],
    );
  }

  Widget getQuestionsPanel() {
    return Column(
      children: [
        getHeader('Вопросы повестки', EdgeInsets.fromLTRB(10, 30, 10, 30)),
        Expanded(
          child: getQuestionsList(),
        ),
      ],
    );
  }

  Widget getQuestionDescriptionPanel() {
    return Column(
      children: [
        Expanded(
          child: getQuestionDescription(),
        ),
        Container(
          height: 15,
        ),
        getHeader('Документы (${_selectedQuestion!.files.length})',
            EdgeInsets.fromLTRB(10, 15, 10, 15)),
        Expanded(
          child: getQuestionFilesList(),
        ),
        Container(
          height: 10,
        ),
        // _showRightPanel
        //     ? Container()
        //     : Row(
        //         children: [
        //           Expanded(
        //             child: Container(),
        //           ),
        //           Expanded(
        //             flex: 2,
        //             child: isAskWordButtonDisabled()
        //                 ? Container()
        //                 : VotingUtils().getAskWordButton(
        //                     context,
        //                     setState,
        //                     AutoSizeGroup(),
        //                     _defaultButtonsHeight,
        //                     _defaultButtonsWidth,
        //                   ),
        //           ),
        //           Expanded(
        //             child: Container(),
        //           ),
        //         ],
        //       ),
        // Container(
        //   height: 10,
        // ),
      ],
    );
  }

  Widget getHeader(String headerName, EdgeInsetsGeometry padding) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: padding,
            color: Colors.lightBlue,
            child: Text(
              headerName,
              maxLines: 1,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: AppState()
                      .getSettings()
                      .managerSchemeSettings
                      .deputyCaptionFontSize
                      .toDouble()),
            ),
          ),
        ),
      ],
    );
  }

  Widget getQuestionsList() {
    return Scrollbar(
      thumbVisibility: true,
      controller: _questionsTableScrollController,
      child: ListView.builder(
        key: PageStorageKey(0),
        controller: _questionsTableScrollController,
        itemCount: _questions.length,
        itemBuilder: (BuildContext context, int index) {
          var element = _questions[index];
          return InkWell(
            onTapDown: (tapDownDetails) {
              setState(() {
                setSelectedQuestion(element);
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: element == _highlightedQuestion
                    ? Colors.blueAccent.withAlpha(64)
                    : Colors.white,
                border: Border.all(
                  color: element == _highlightedQuestion
                      ? Colors.blueAccent
                      : Colors.grey,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: AppState()
                        .getSettings()
                        .managerSchemeSettings
                        .deputyNumberFontSize
                        .toDouble(),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: IgnorePointer(
                            ignoring: false,
                            child: _isSelectedQuestionPage
                                ? AgendaUtil.getQuestionDescriptionText(
                                    element,
                                    AppState()
                                        .getSettings()
                                        .managerSchemeSettings
                                        .deputyFontSize
                                        .toDouble(),
                                    lineHeight: 1,
                                    withQuestionNumber: true,
                                    listSettings: <QuestionGroupSettings>[
                                      AppState()
                                          .getSettings()
                                          .questionListSettings
                                          .mainQuestion
                                    ],
                                    numberFontSize: AppState()
                                        .getSettings()
                                        .managerSchemeSettings
                                        .deputyNumberFontSize
                                        .toDouble(),
                                    textAlign: TextAlign.justify,
                                  )
                                : Text(
                                    element.toString(),
                                    style: TextStyle(
                                      fontSize: AppState()
                                          .getSettings()
                                          .managerSchemeSettings
                                          .deputyNumberFontSize
                                          .toDouble(),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: AppState()
                        .getSettings()
                        .managerSchemeSettings
                        .deputyNumberFontSize
                        .toDouble(),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget getQuestionDescription() {
    return Scrollbar(
      thumbVisibility: true,
      controller: _questionDescriptionScrollController,
      child: SingleChildScrollView(
        controller: _questionDescriptionScrollController,
        scrollDirection: Axis.vertical,
        child: Container(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: AgendaUtil.getQuestionDescriptionText(
                      _selectedQuestion,
                      AppState()
                          .getSettings()
                          .managerSchemeSettings
                          .deputyFontSize
                          .toDouble(),
                      lineHeight: 1,
                      isAutoSize: true,
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
              ]),
        ),
      ),
    );
  }

  Widget getQuestionFilesList() {
    return Scrollbar(
      thumbVisibility: true,
      controller: _questionFilesTableScrollController,
      child: ListView.builder(
          controller: _questionFilesTableScrollController,
          itemCount: _selectedQuestion!.files.length,
          itemBuilder: (BuildContext context, int index) {
            var element = _selectedQuestion!.files[index];
            return InkWell(
              onTap: () {
                viewFile(element);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: element == _selectedQuestionFile
                      ? Colors.blueAccent.withAlpha(64)
                      : Colors.white,
                  border: Border.all(
                    color: element == _selectedQuestionFile
                        ? Colors.blueAccent
                        : Colors.grey,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 60,
                      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Wrap(children: [
                              IgnorePointer(
                                ignoring: true,
                                child: Text(
                                  element.description,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  softWrap: true,
                                  style: TextStyle(
                                      fontSize: AppState()
                                          .getSettings()
                                          .managerSchemeSettings
                                          .deputyNumberFontSize
                                          .toDouble()),
                                ),
                              ),
                            ]),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Icon(
                              Icons.event_note,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Future<void> viewFile(QuestionFile file) async {
    if (AppState().canUserNavigate()) {
      setState(() {
        _selectedQuestionFile = file;

        AppState().setCurrentDocument(_selectedQuestionFile);
        AppState().setAgendaDocument(_selectedQuestionFile);
      });

      Provider.of<WebSocketConnection>(context, listen: false)
          .navigateToPage('/viewDocument');
    }
  }

  Widget rightPanel() {
    Provider.of<AppState>(context, listen: true);
    final connection = Provider.of<WebSocketConnection>(context, listen: false);
    var playerHeight = MediaQuery.of(context).size.height -
        AppState().getSettings().storeboardSettings.height -
        200;
    playerHeight = playerHeight > 0 ? playerHeight : 0;

    var emblemHeight = MediaQuery.of(context).size.height -
        (Utils().getIsAskWordButtonDisabled()
            ? 0
            : _defaultButtonsHeight * 1.5 + 22) -
        ((!_showExitButtonRight || !connection.getIsManualLogin)
            ? 0
            : _defaultButtonsHeight * 1.5 + 22) -
        AppState().getSettings().storeboardSettings.height;

    emblemHeight = emblemHeight < 0 ? 0 : emblemHeight;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Container(
            color: Colors.blue[100],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _showUnregistred
                    ? TableUtils().getUnregistredTable(
                        _unregistredTableScrollController,
                        flex: 10)
                    : Container(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              maxHeight: emblemHeight, minHeight: emblemHeight),
                          child: VotingUtils().getEmblemButton(),
                        ),
                      ),
                Row(
                  children: [
                    Expanded(
                      child: Utils().getIsAskWordButtonDisabled()
                          ? Container()
                          : VotingUtils().getAskWordButton(
                              context,
                              setState,
                              AutoSizeGroup(),
                              (_defaultButtonsHeight * 0.8).ceil(),
                              _defaultButtonsWidth,
                              false,
                            ),
                    ),
                  ],
                ),
                !_showExitButtonRight || !connection.getIsManualLogin
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight: 100,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(AppState()
                                  .getSettings()
                                  .palletteSettings
                                  .buttonTextColor),
                              width: 5,
                            ),
                          ),
                          child: VotingUtils().getExpandedButton(
                            context,
                            'ВЫЙТИ',
                            () {
                              Provider.of<WebSocketConnection>(context,
                                      listen: false)
                                  .onUserExit();
                            },
                            AutoSizeGroup(),
                            _defaultButtonsHeight,
                          ),
                        ),
                      ),
                Container(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
        StoreboardWidget(
          serverState: AppState().getServerState(),
          meeting: AppState().getCurrentMeeting()!,
          question: AppState()
              .getCurrentMeeting()!
              .agenda!
              .questions
              .firstWhereOrNull((element) =>
                  element.id ==
                  json.decode(
                      AppState().getServerState().params)['selectedQuestion']),
          settings: AppState().getSettings(),
          timeOffset: AppState().getTimeOffset(),
          votingModes: AppState().getVotingModes(),
          users: AppState().getUsers(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _questionsTableScrollController.removeListener(() {
      scrollPosition();
    });

    _questionsTableScrollController.dispose();
    _questionFilesTableScrollController.dispose();
    _questionDescriptionScrollController.dispose();

    WebSocketConnection.updateAgenda = null;

    super.dispose();
  }
}
