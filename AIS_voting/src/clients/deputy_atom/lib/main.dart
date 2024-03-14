import 'dart:ui';

import 'package:global_configuration/global_configuration.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'State/AppState.dart';
import 'Pages/waiting.dart';
import 'Pages/login.dart';
import 'Pages/registration.dart';
import 'Pages/voting.dart';
import 'Pages/viewAgenda.dart';
import 'Pages/viewDocument.dart';
import 'Pages/viewGroup.dart';
import 'Pages/viewStream.dart';
import 'Pages/reconnect.dart';
import 'Pages/loading.dart';
import 'Pages/insertCard.dart';
import 'State/CurrentUser.dart';
import 'State/WebSocketConnection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GlobalConfiguration()
      .loadFromAsset('app_settings')
      .then((value) => runApp(MyApp()));
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    WebSocketConnection.init(widget.navigatorKey);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: WebSocketConnection.connect(),
        builder: (context, snapshot) {
          return MultiProvider(
            providers: [
              ListenableProvider<AppState>(create: (_) => AppState()),
              ListenableProvider<WebSocketConnection>(
                  create: (_) => WebSocketConnection.getInstance(),
                  lazy: false),
              ListenableProvider<CurrentUser>(
                  create: (_) => CurrentUser(AppState().getCurrentUser())),
            ],
            child: MaterialApp(
              title: 'Депутат',
              scrollBehavior: MyCustomScrollBehavior(),
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.blue,
                visualDensity: VisualDensity.adaptivePlatformDensity,
                tooltipTheme: TooltipThemeData(
                  textStyle: TextStyle(fontSize: 14, color: Colors.white),
                ),
                scrollbarTheme: ScrollbarThemeData(
                  isAlwaysShown: true,
                  thickness: MaterialStateProperty.all(20),
                ),
                textButtonTheme: TextButtonThemeData(
                    style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  padding: MaterialStateProperty.all(EdgeInsets.all(20)),
                  overlayColor: MaterialStateProperty.all(Colors.blueAccent),
                )),
              ),
              home: LoadingPage(),
              navigatorKey: widget.navigatorKey,
              onGenerateRoute: _getRoute,
            ),
          );
        });
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    if (settings.name == '/reconnect') {
      return _buildRoute(settings, new ReconnectPage());
    }
    if (settings.name == '/loading') {
      return _buildRoute(settings, new LoadingPage());
    }
    if (settings.name == '/login') {
      return _buildRoute(settings, new LoginPage());
    }
    if (settings.name == '/waiting') {
      return _buildRoute(settings, new WaitingPage());
    }
    if (settings.name == '/registration') {
      return _buildRoute(settings, new RegistrationPage());
    }
    if (settings.name == '/viewAgenda') {
      return _buildRoute(settings, new ViewAgendaPage());
    }
    if (settings.name == '/viewDocument') {
      return _buildRoute(settings, new ViewDocumentPage());
    }
    if (settings.name == '/viewStream') {
      return _buildRoute(settings, new ViewStreamPage());
    }
    if (settings.name == '/viewGroup') {
      return _buildRoute(settings, new ViewGroupPage());
    }
    if (settings.name == '/voting') {
      return _buildRoute(settings, new VotingPage());
    }
    if (settings.name == '/insertCard') {
      return _buildRoute(settings, new InsertCardPage());
    }

    return null;
  }

  MaterialPageRoute _buildRoute(RouteSettings settings, Widget builder) {
    return new MaterialPageRoute(
      settings: settings,
      builder: (ctx) => builder,
    );
  }
}
