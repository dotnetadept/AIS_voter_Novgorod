import 'dart:io';
import 'dart:ui';

import 'package:deputy/Utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart';

import 'Pages/viewStream.dart';
import 'Pages/waitingMeeting.dart';
import 'State/AppState.dart';
import 'Pages/waiting.dart';
import 'Pages/login.dart';
import 'Pages/registration.dart';
import 'Pages/voting.dart';
import 'Pages/viewAgenda.dart';
import 'Pages/viewDocument.dart';
import 'Pages/viewGroup.dart';
import 'Pages/viewVideo.dart';
import 'Pages/reconnect.dart';
import 'Pages/loading.dart';
import 'Pages/insertCard.dart';
import 'State/CurrentUser.dart';
import 'State/WebSocketConnection.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;

  windowManager.ensureInitialized();

  windowManager.setFullScreen(true);

  await GlobalConfiguration()
      .loadFromAsset('app_settings')
      .then((value) => runApp(MyApp()));

  Directory.current = GlobalConfiguration().getValue('folder_path');
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  static bool _isWindowPositionSet = false;

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();

    AppState().loadData(null);

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
              scaffoldMessengerKey: rootScaffoldMessengerKey,
              title: 'Депутат',
              scrollBehavior: MyCustomScrollBehavior(),
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.blue,
                visualDensity: VisualDensity.adaptivePlatformDensity,
                textTheme: GoogleFonts.ubuntuTextTheme(
                  Theme.of(context).textTheme,
                ),
                tooltipTheme: TooltipThemeData(
                  textStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                scrollbarTheme: ScrollbarThemeData(
                  thumbVisibility: MaterialStateProperty.all(true),
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
    if (settings.name == '/waitingMeeting') {
      return _buildRoute(settings, new WaitingMeetingPage());
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
    if (settings.name == '/viewVideo') {
      return _buildRoute(settings, new ViewVideoPage());
    }
    if (settings.name == '/viewStream') {
      return _buildRoute(settings, new ViewStreamPage());
    }
    if (settings.name == '/viewVideo') {
      return _buildRoute(settings, new ViewVideoPage());
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

  CustomPageRoute _buildRoute(RouteSettings settings, Widget builder) {
    return new CustomPageRoute(
      builder: (ctx) => builder,
    );
  }

  @override
  void onWindowResize() async {
    if (!AppState().getIsLoadingComplete()) {
      return;
    }

    var windowHeight = Utils().showBottomPanel() ? 60 : 0.1;

    await windowManager.getSize().then((size) async {
      if (size.height == windowHeight) {
        await windowManager.isAlwaysOnTop().then((value) {
          if (!value) {
            windowManager.setAlwaysOnTop(true);
          }
        });

        if (!_isWindowPositionSet) {
          _isWindowPositionSet = true;
          await getCurrentScreen().then((screen) async {
            await windowManager.getPosition().then((position) async {
              if (position.dx !=
                  screen.visibleFrame.height - windowHeight / 2) {
                await windowManager.setAlignment(Alignment.topCenter);
                await windowManager.setPosition(
                    Offset(0, screen.visibleFrame.height - windowHeight / 2));
              }
            });
          });
        }
      }
    });
  }

  @override
  void onWindowEnterFullScreen() async {
    await windowManager.setAlwaysOnTop(false);
  }

  @override
  void onWindowLeaveFullScreen() async {
    if (!AppState().getIsLoadingComplete()) {
      return;
    }

    var windowHeight = Utils().showBottomPanel() ? 60.0 : 0.1;
    await getCurrentScreen().then((screen) async {
      await windowManager
          .setSize(Size(screen.visibleFrame.width, windowHeight));
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }
}

class CustomPageRoute extends MaterialPageRoute {
  CustomPageRoute({builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}
