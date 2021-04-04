import 'werewolf_server.dart';

class WerewolfServerChannel extends ApplicationChannel {
  WereWolfConfiguration config;
  @override
  Future prepare() async {
    config = WereWolfConfiguration(options.configurationFilePath);
    AppJWT.init(secretKey: config.secretKey, expiredsInDay: 30);
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

    router.route("/token/generator").linkFunction((request) async {
      return Response.ok(ResponseConstant.responseSuccess(
          AppJWT.generator(User(fullName: "Minh Minh"))));
    });

    router.route("/token/verify").linkFunction((request) async {
      final accessToken = request.raw.headers.value("Authorization");
      return Response.ok(ResponseConstant.responseSuccess(
          AppJWT.verify(accessToken).data?.toJson()));
    });

    router.route("/migrate").link(() => MigrateController());

    router.route("/getConfig").link(() => ConfigController());

    router.route("/post/signUp").link(() => SignUpController());

    router.route("/post/signIn").link(() => SignInController());

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
