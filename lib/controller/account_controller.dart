import '../werewolf_server.dart';

class AccountController extends ResourceController {
  @override
  List<ContentType> get acceptedContentTypes => [
        ContentType("multipart", "form-data"),
        ContentType("application", "x-www-form-urlencoded")
      ];

  @Bind.header('Authorization')
  String accessToken;

  @Operation.post()
  Future<Response> signIn() async {
    // if (AppJWT.isValid(accessToken))
    //   return Response.ok(ResponseConstant.reponseSuccess({"OK": true}));
    print("Start");
    Map<String, List<String>> body = await request.body.decode();
    print("- decode");
    print(body.toString());
    return Response.ok(ResponseConstant.reponseSuccess({"OK": true}));
  }

  @override
  Future handleError(Request request, caughtValue, StackTrace trace) {
    print("Handle error!");
    return super.handleError(request, caughtValue, trace);
  }
}
