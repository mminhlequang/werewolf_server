import '../werewolf_server.dart';

class ConfigController extends ResourceController {

  @Operation.get()
  Future<Response> getConfig() async {
    try {
      final int count = await AppDatabase.colConfig.count();
      if (count < 1) {
        await Config().insert();
      }
    } catch (e) {
      print("Error getConfig: $e");
    }
    final data = await AppDatabase.colConfig.findOne();
    return Response.ok(ResponseConstant.responseSuccess(data));
  }
}
