import '../werewolf_server.dart';

class MiddlewareController extends Controller {
  @override
  Future<RequestOrResponse> handle(Request request) async {
    final accessToken = request.raw.headers.value("Authorization");
    if (!AppJWT.isValid(accessToken))
      return Response.ok(ResponseConstant.responseForbidden());
    return request;
  }
}
