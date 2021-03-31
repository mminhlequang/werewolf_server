import 'package:werewolf_server/werewolf_server.dart';

class SignInController extends Controller {
  @Operation.post()
  @override
  FutureOr<RequestOrResponse> handle(Request request) async {
    final Map<String, List<String>> body = await request.body.decode();
    print(body.toString());
    if (!body.containsKey("type"))
      return Response.ok(ResponseConstant.reponseError(
          msg: "Type is required!", translate: false));
    final String type = body["type"][0];
    switch (type) {
      case "normal":
        if (!body.containsKey("username") || !body.containsKey("password"))
          return Response.ok(ResponseConstant.reponseError(
              msg: "Username, password is required!", translate: false));
        final String username = body["username"][0];
        final String password = body["password"][0];
        if (password != null && password.trim().length < 6)
          return Response.ok(ResponseConstant.reponseError(
              msg: "Password must valid!", translate: false));
        Map<String, dynamic> response;
        try {
          final String hash = User.convertPassword(password);
          final user = await AppDatabase.colUser.findOne((where
                  .eq("username", username)
                  .and(where.eq("password", hash)))
              .or(where.eq("email", username).and(where.eq("password", hash))));
          User _user = User();
          _user.readFromMap(user);
          final accessToken = AppJWT.generator(_user);
          if (user != null)
            response = ResponseConstant.reponseSuccess(
                {"user": user, "accessToken": accessToken});
          else
            response = ResponseConstant.reponseError(
                msg: "Not match", translate: false);
        } catch (e) {
          print(e);
          response = ResponseConstant.reponseError();
        }
        return Response.ok(response);
        break;
      default:
        return Response.ok(ResponseConstant.reponseError());
    }
  }
}
