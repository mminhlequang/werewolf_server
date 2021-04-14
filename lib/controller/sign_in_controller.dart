import 'package:werewolf_server/werewolf_server.dart';

class SignInController extends Controller {
  @Operation.post()
  @override
  FutureOr<RequestOrResponse> handle(Request request) async {
    final Map<String, List<String>> body = await request.body.decode();
    print(body.toString());
    if (!body.containsKey("type"))
      return Response.ok(ResponseConstant.responseError(
          msg: "Type is required!", translate: false));
    final String type = body["type"][0];
    switch (type) {
      case "normal":
        if (!body.containsKey("username") || !body.containsKey("password"))
          return Response.ok(ResponseConstant.responseError(
              msg: "Username, password is required!", translate: false));
        final String username = body["username"][0];
        final String password = body["password"][0];
        if (password != null && password.trim().length < 6)
          return Response.ok(ResponseConstant.responseError(
              msg: "Password must valid!", translate: false));
        Map<String, dynamic> response;
        try {
          final String hash = User.convertPassword(password);
          final user = await AppDatabase.colUser.findOne((where
                  .eq("username", username)
                  .and(where.eq("password", hash)))
              .or(where.eq("email", username).and(where.eq("password", hash))));

          final accessToken = AppJWT.generator(User.fromJson(user));
          if (user != null)
            response = ResponseConstant.responseSuccess(
                {"user": user, "accessToken": accessToken});
          else
            response = ResponseConstant.responseError(
                msg: "Not match", translate: false);
        } catch (e) {
          print(e);
          response = ResponseConstant.responseError();
        }
        return Response.ok(response);
        break;
      default:
        return Response.ok(ResponseConstant.responseError());
    }
  }
}
