import '../werewolf_server.dart';

class ProfileController extends ResourceController {
  @Bind.header('Authorization')
  String accessToken;

  @Operation.get()
  Future<Response> getProfile() async {
    final JWTResponse response = AppJWT.verify(accessToken);
    return Response.ok(ResponseConstant.responseSuccess(response.data));
  }
}
