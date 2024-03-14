import 'dart:io';
import 'dart:ui';

import 'package:global_configuration/global_configuration.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart';

import 'State/AppState.dart';
import 'Pages/waiting.dart';
import 'Pages/login.dart';
import 'Pages/registration.dart';
import 'Pages/voting.dart';
import 'Pages/viewAgenda.dart';
import 'Pages/reconnect.dart';
import 'Pages/loading.dart';
import 'State/WebSocketConnection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await GlobalConfiguration().loadFromAsset('app_settings');
  if (Platform.isWindows) {
    await initWindowsWindow();
  } else if (Platform.isLinux) {
    await initLinuxWindow();
  }

  runApp(new MediaQuery(data: new MediaQueryData(), child: MyApp()));
}

Future<void> initWindowsWindow() async {
  Screen screen = await getCurrentScreen();

  double windowWidth =
      int.parse(GlobalConfiguration().getValue('window_width').toString())
          .toDouble();
  double windowHeight =
      int.parse(GlobalConfiguration().getValue('window_height').toString())
          .toDouble();

  double screenWidth = screen.frame.width;
  double screenHeight = screen.frame.height;

  AppState().setDisplayScale(screen.scaleFactor);

  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setAsFrameless();
    await windowManager.setSize(Size(AppState().getScaledSize(windowWidth),
        AppState().getScaledSize(windowHeight)));
    await windowManager.setPosition(Offset(
        AppState().getScaledSize(screenWidth - windowWidth) - 1,
        AppState().getScaledSize(screenHeight -
            windowHeight -
            screen.scaleFactor *
                int.parse(GlobalConfiguration()
                    .getValue('bottom_margin')
                    .toString()))));
    await windowManager.setAlwaysOnTop(true);

    await windowManager.show();
  });
}

Future<void> initLinuxWindow() async {
  AppState().setDisplayScale(1);

  windowManager.waitUntilReadyToShow().then((_) async {
    //await windowManager.setAsFrameless();
    //await windowManager.setFullScreen(true);
    //await windowManager.setAlwaysOnTop(true);

    await windowManager.show();
  });
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
    WebSocketConnection.onShow = showWindow;
    WebSocketConnection.onHide = hideWindow;
    WebSocketConnection.init(widget.navigatorKey);

    super.initState();
  }

  void hideWindow() {
    windowManager.minimize();
  }

  void showWindow() {
    windowManager.show();
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
            ],
            child: MaterialApp(
              title: 'Депутат',
              scrollBehavior: MyCustomScrollBehavior(),
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.blue,
                visualDensity: VisualDensity.compact,
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
                    padding: MaterialStateProperty.all(
                        EdgeInsets.all(AppState().getHalfScaledSize(20))),
                    overlayColor: MaterialStateProperty.all(Colors.blueAccent),
                  ),
                ),
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
    if (settings.name == '/voting') {
      return _buildRoute(settings, new VotingPage());
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
