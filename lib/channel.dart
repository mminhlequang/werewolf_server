import 'werewolf_server.dart';

class WerewolfServerChannel extends ApplicationChannel {
  WereWolfConfiguration config;
  @override
  Future prepare() async {
    config = options.context['config'];
    AppJWT.init(secretKey: config.secretKey, expiredInDay: 30);
    await AppDatabase.init(
        username: config.username,
        password: config.password,
        databaseName: config.databaseName,
        host: config.host);
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @override
  Controller get entryPoint {
    final router =
        Router(notFoundHandler: notFoundHandler, basePath: config.apiBaseURL);

    router.route("/token/verify").linkFunction((request) async {
      final accessToken = request.raw.headers.value("Authorization");
      return Response.ok(ResponseConstant.responseSuccess(
          AppJWT.verify(accessToken).data?.toJson()));
    });

    router.route("/migrate").link(() => MigrateController());

    router.route("/get/config").link(() => ConfigController());

    router.route("/post/signUp").link(() => SignUpController());

    router.route("/post/signIn").link(() => SignInController());

    router.route("/get/profile").link(() => MiddlewareController()).link(() => ProfileController());

    router.route("/get/roles").link(() => RolesController());

    return router;
  }

  Future notFoundHandler(Request req) async {
    final response = Response.notFound();
    if (req.acceptsContentType(ContentType.html)) {
      response
        ..body = ResponseConstant.responseNotFound()
        ..contentType = ContentType.json;
    }

    await req.respond(response);
  }
}
