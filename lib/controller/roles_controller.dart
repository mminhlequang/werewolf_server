import '../werewolf_server.dart';

class RolesController extends ResourceController {
  @Operation.get()
  Future<Response> constantValues({@Bind.query('type') String type}) async {
    if (type == 'classic')
      return Response.ok(ResponseConstant.responseSuccess(
          await AppDatabase.colRole.find().toList()));
    else if (type == 'all')
      return Response.ok(ResponseConstant.responseSuccess(
          await AppDatabase.colRole.find().toList()));
    else
      return Response.ok(ResponseConstant.responseError());
  }
}
