import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:storeboard/Pages/viewStream.dart';
import 'package:storeboard/Pages/viewVideo.dart';
import 'package:window_manager/window_manager.dart';
import 'Pages/storeboard.dart';
import 'State/AppState.dart';
import 'State/SoundPlayer.dart';
import 'State/WebSocketConnection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Necessary initialization for package:media_kit.
  MediaKit.ensureInitialized();

  await GlobalConfiguration()
      .loadFromAsset('app_settings')
      .then((value) => runApp(StoreboardApp()));

  await windowManager.waitUntilReadyToShow().then((value) async {
    await windowManager.setSize(Size(
      int.parse(GlobalConfiguration().getValue('width')).toDouble(),
      int.parse(GlobalConfiguration().getValue('height')).toDouble(),
    ));
  });
}

class StoreboardApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  @override
  _StoreboardAppState createState() => _StoreboardAppState();
}

class _StoreboardAppState extends State<StoreboardApp> {
  @override
  void initState() {
    super.initState();

    SoundPlayer.init();
    WebSocketConnection.init(widget.navigatorKey);

    WebSocketConnection.stopSound = SoundPlayer.cancelSound;
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
                create: (_) => WebSocketConnection.getInstance(), lazy: false),
          ],
          child: MaterialApp(
            title: 'Табло АИС Голосование',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: false,
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              textTheme: GoogleFonts.ubuntuTextTheme(
                Theme.of(context).textTheme,
              ),
            ),
            home: StoreboardPage(),
            navigatorKey: widget.navigatorKey,
            onGenerateRoute: _getRoute,
          ),
        );
      },
    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    if (settings.name == '/storeboard') {
      return _buildRoute(settings, new StoreboardPage());
    }
    if (settings.name == '/viewStream') {
      return _buildRoute(settings, new ViewStreamPage());
    }
    if (settings.name == '/viewVideo') {
      return _buildRoute(settings, new ViewVideoPage());
    }

    return _buildRoute(settings, new StoreboardPage());
  }

  CustomPageRoute _buildRoute(RouteSettings settings, Widget builder) {
    return new CustomPageRoute(
      builder: (ctx) => builder,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class CustomPageRoute extends MaterialPageRoute {
  CustomPageRoute({builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}
