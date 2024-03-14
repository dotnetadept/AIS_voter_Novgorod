import 'package:global_configuration/global_configuration.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Pages/viewDocument.dart';
import 'State/AppState.dart';
import 'Pages/viewAgenda.dart';
import 'Pages/reconnect.dart';
import 'Pages/loading.dart';
import 'package:pwa/client.dart' as pwa;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  new pwa.Client();

  await GlobalConfiguration()
      .loadFromAsset('app_settings')
      .then((value) => runApp(MyApp()));
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
          title: 'Мои совещания',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            tooltipTheme: TooltipThemeData(
              textStyle: TextStyle(fontSize: 22, color: Colors.white),
            ),
            scrollbarTheme: ScrollbarThemeData(
              isAlwaysShown: false,
              thickness: MaterialStateProperty.all(20),
            ),
            textButtonTheme: TextButtonThemeData(
                style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              padding: MaterialStateProperty.all(EdgeInsets.all(10)),
              overlayColor: MaterialStateProperty.all(Colors.blueAccent),
              textStyle: MaterialStateProperty.all(TextStyle(fontSize: 22)),
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
    if (settings.name == '/viewAgenda') {
      return _buildRoute(settings, new ViewAgendaPage());
    }
    if (settings.name == '/viewDocument') {
      return _buildRoute(settings, new ViewDocumentPage());
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
