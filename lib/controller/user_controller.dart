import '../werewolf_server.dart';

class UserController extends ResourceController {
  UserController() {
    acceptedContentTypes = [
      ContentType.json,
      ContentType("multipart", "form-data", charset: "utf-8"),
    ];
  }

  @Bind.header('Authorization')
  String accessToken;

  @Operation.get()
  Future<Response> getProfile() async {
    if (AppJWT.isValid(accessToken))
      return Response.ok(ResponseConstant.responseSuccess({"OK": true}));
    else
      return Response.forbidden(body: ResponseConstant.responseForbidden());
  }

  @Operation.post()
  Future<Response> createProfile() async {
    try {
      User user = User(
          id: DateTime.now().microsecondsSinceEpoch,
          username: "mminh",
          password: "123456",
          email: "mminh@gmail.com",
          fullName: "Minh Minh");
      await user.insert();
      return Response.ok(ResponseConstant.responseSuccess({"OK": true}));
    } catch (e) {
      return Response.ok(ResponseConstant.responseError());
    }
  }

  @Operation.put()
  Future<Response> updateProfile() async {
    try {
      User user = User(
          id: 1616641250255674,
          username: "mminh",
          password: "123456",
          email: "mminh@gmaail.com",
          fullName: "Minh Minh1");
      await user.update();
      return Response.ok(ResponseConstant.responseSuccess({"OK": true}));
    } catch (e) {
      return Response.ok(
          ResponseConstant.responseError(msg: e.toString(), translate: false));
    }
  }
}
