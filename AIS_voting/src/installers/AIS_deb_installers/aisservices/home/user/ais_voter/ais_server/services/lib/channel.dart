import 'services.dart';
import 'controllers/controllers.dart';

/// This type initializes an application.
class ServicesChannel extends ApplicationChannel {
  ManagedContext _context;
  WebSocketServer _wsServer;

  @override
  Future prepare() async {
    RequestBody.maxSize = 1024 * 1024 * 1024;
    // init managed context
    final persistentStore = PostgreSQLPersistentStore.fromConnectionInfo(
        PSQL_USER, PSQL_PASSWORD, PSQL_SERVER, PSQL_PORT, PSQL_DATABASE);
    _context = ManagedContext(
        ManagedDataModel.fromCurrentMirrorSystem(), persistentStore);

    _wsServer = WebSocketServer(ADDRESS, WEB_SOCKET_PORT, _context);

    // init web socket server
    await _wsServer.load();
    _wsServer.bind();

    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @override
  Controller get entryPoint {
    final router = Router();

    router
        .route('/storeboardtemplates/[:id]')
        .link(() => StoreboardTemplateController(_context));
    router.route('/users/[:id]').link(() => UsersController(_context));
    router.route('/groups/[:id]').link(() => GroupsController(_context));
    router.route('/meetings/[:id]').link(() => MeetingsController(_context));
    router
        .route('/meeting_sessions/')
        .link(() => MeetingSessionsController(_context));
    router.route('/agendas/[:id]').link(() => AgendasController(_context));
    router.route('/questions/[:id]').link(() => QuestionController(_context));
    router
        .route('/questionfiles/[:id]')
        .link(() => QuestionFileController(_context));
    router
        .route('/questionDescription/[:id]')
        .link(() => QuestionDescriptionController(_context));

    router.route('/files/*').link(() => FileController('documents/'));
    router.route('/upload').link(() => DocumentUploadController());
    router
        .route('/voting_modes/[:id]')
        .link(() => VotingModeController(_context));
    router.route('/settings').link(() => SettingsController(_context));
    router
        .route('/questionsessions/[:meeting_session_id]')
        .link(() => QuestionSessionsController(_context));
    router
        .route('/registrationsessions/[:meeting_id]')
        .link(() => RegistrationSessionsController(_context));

    return router;
  }
}