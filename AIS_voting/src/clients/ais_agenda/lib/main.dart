import 'package:ais_agenda/Model/agenda/question.dart';
import 'package:ais_agenda/Model/base/base_item.dart';
import 'package:ais_agenda/Model/entity/restricted_item.dart';
import 'package:ais_agenda/Model/subject/user.dart';
import 'package:ais_agenda/View/Pages/Common/loading.dart';
import 'package:ais_agenda/View/Pages/Common/login.dart';
import 'package:ais_agenda/View/Pages/Common/not_found.dart';
import 'package:ais_agenda/View/Pages/Menu/Agenda/agenda.dart';
import 'package:ais_agenda/View/Pages/Menu/Agenda/agendas.dart';
import 'package:ais_agenda/View/Pages/Menu/Forms/form.dart';
import 'package:ais_agenda/View/Pages/Menu/Forms/forms.dart';
import 'package:ais_agenda/View/Pages/Menu/Groups/groups.dart';
import 'package:ais_agenda/View/Pages/Menu/Users/user.dart';
import 'package:ais_agenda/View/Pages/Menu/Users/users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:provider/provider.dart';
//import 'package:pwa/client.dart' as pwa;

import 'Model/agenda/agenda.dart';
import 'Model/entity/aisform.dart';

import 'State/app_state.dart';
import 'View/Pages/Common/rights.dart';
import 'View/Pages/Menu/Agenda/question.dart';
import 'View/Pages/Menu/Calendar/calendar.dart';
import 'View/Pages/Menu/Journal/journal.dart';
import 'View/Pages/Menu/Settings/settings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //pwa.Client();

  runApp(MyApp());
}

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    AppState.init(widget.navigatorKey);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(builder: (context, snapshot) {
      return MultiProvider(
        providers: [
          ListenableProvider<AppState>(create: (_) => AppState.getInstance()),
        ],
        child: MaterialApp(
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          title: 'Мои совещания',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            FormBuilderLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: FormBuilderLocalizations.delegate.supportedLocales,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            tooltipTheme: const TooltipThemeData(
              textStyle: TextStyle(fontSize: 22, color: Colors.white),
            ),
            scrollbarTheme: ScrollbarThemeData(
              thumbVisibility: MaterialStateProperty.all(false),
              thickness: MaterialStateProperty.all(20),
            ),
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
                overlayColor: MaterialStateProperty.all(Colors.blueAccent),
                textStyle:
                    MaterialStateProperty.all(const TextStyle(fontSize: 22)),
              ),
            ),
            appBarTheme: const AppBarTheme(
              toolbarHeight: 80,
              centerTitle: true,
            ),
          ),
          home: const LoadingPage(),
          navigatorKey: widget.navigatorKey,
          onGenerateRoute: _getRoute,
        ),
      );
    });
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    if (settings.name == '/loading') {
      return _buildRoute(settings, const LoadingPage());
    }

    if (settings.name == '/login') {
      return _buildRoute(settings, const LoginPage());
    }

    if (settings.name == '/users') {
      return _buildRoute(settings, const UsersPage());
    }
    if (settings.name == '/user') {
      return _buildRoute(settings, UserPage(settings.arguments as User));
    }
    if (settings.name == '/groups') {
      return _buildRoute(settings, const GroupsPage());
    }

    if (settings.name == '/forms') {
      return _buildRoute(settings, const FormsPage());
    }
    if (settings.name == '/form') {
      return _buildRoute(settings, FormPage(settings.arguments as AisForm));
    }

    if (settings.name == '/agendas') {
      return _buildRoute(settings, const AgendasPage());
    }
    if (settings.name == '/agenda') {
      return _buildRoute(settings, AgendaPage(settings.arguments as Agenda));
    }
    if (settings.name == '/agendaItem') {
      var args = settings.arguments as List<BaseItem>;
      return _buildRoute(
          settings, QuestionPage(args[0] as Agenda, args[1] as Question));
    }

    if (settings.name == '/calendar') {
      return _buildRoute(settings, const CalendarPage());
    }

    if (settings.name == '/rights') {
      return _buildRoute(
          settings, RightsPage(settings.arguments as RestrictedItem));
    }

    if (settings.name == '/journal') {
      return _buildRoute(settings, const JournalPage());
    }

    if (settings.name == '/settings') {
      return _buildRoute(settings, const SettingsPage());
    }

    return _buildRoute(settings, const NotFoundPage());
  }

  MaterialPageRoute _buildRoute(RouteSettings settings, Widget builder) {
    return MaterialPageRoute(
      settings: settings,
      builder: (ctx) => builder,
    );
  }
}
