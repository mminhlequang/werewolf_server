import 'package:werewolf_server/extensions/string_extention.dart';
import 'package:werewolf_server/werewolf_server.dart';

class SignUpController extends Controller {
  @Operation.post()
  @override
  FutureOr<RequestOrResponse> handle(Request request) async {
    final Map<String, List<String>> body = await request.body.decode();
    print(body.toString());
    if (!body.containsKey("username") ||
        !body.containsKey("password") ||
        !body.containsKey("email"))
      return Response.ok(ResponseConstant.reponseError(
          msg: "Username, email, password is required!", translate: false));
    final String username = body["username"][0];
    final String password = body["password"][0];
    final String email = body["email"][0];
    if (!email.isValidEmail())
      return Response.ok(ResponseConstant.reponseError(
          msg: "Email must valid!", translate: false));
    if (password != null && password.trim().length < 6)
      return Response.ok(ResponseConstant.reponseError(
          msg: "Password must valid!", translate: false));
    try {
      if (await AppDatabase.colUser.findOne(where.eq("username", username)) !=
          null)
        return Response.ok(ResponseConstant.reponseError(
            msg: "Username already exists!", translate: false));
      if (await AppDatabase.colUser.findOne(where.eq("email", email)) != null)
        return Response.ok(ResponseConstant.reponseError(
            msg: "Email already exists!", translate: false));
      final user = User(
          id: DateTime.now().microsecondsSinceEpoch,
          username: username,
          password: password,
          email: email,
          fullName: "Wolf member");
      await user.insert();
      final accessToken = AppJWT.generator(user.asMap());
      return Response.ok(ResponseConstant.reponseSuccess(
          {"user": user.asMap(), "accessToken": accessToken}));
    } catch (e) {
      print(e);
      return Response.ok(ResponseConstant.reponseError());
    }
  }
}
