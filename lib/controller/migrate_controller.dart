import 'package:werewolf_server/constants/migrate_constant.dart';

import '../werewolf_server.dart';

class MigrateController extends ResourceController {
  @Operation.get()
  Future<Response> constantValues({@Bind.query('action') String action}) async {
    if (action == 'default')
      return Response.ok(ResponseConstant.responseSuccess({
        "languages": LANGUAGES,
        'sectarians': SECTARIANS,
        'roles_classic': ROLES_CLASSIC,
        'roles_modern': []
      }));
    else if (action == 'view') {
      final languages = await AppDatabase.colLanguage.find().toList();
      final sectarians = await AppDatabase.colSectarian.find().toList();
      final rolesClassic = await AppDatabase.colRole
          .find(where.eq('type', describeEnum(RoleType.classic)))
          .toList();
      final rolesModern = await AppDatabase.colRole
          .find(where.eq('type', describeEnum(RoleType.modern)))
          .toList();
      return Response.ok(ResponseConstant.responseSuccess({
        "languages": languages,
        'sectarians': sectarians,
        'roles_classic': rolesClassic,
        'roles_modern': rolesModern
      }));
    } else if (action == 'run') {
      await AppDatabase.colLanguage
          .remove(where.match('name', 'r^[a-z]|[A-Z]|[0-9]'));
      await AppDatabase.colLanguage
          .insertAll(LANGUAGES.map((e) => e.toJson()).toList());
      await AppDatabase.colSectarian
          .remove(where.match('name', 'r^[a-z]|[A-Z]|[0-9]'));
      await AppDatabase.colSectarian
          .insertAll(SECTARIANS.map((e) => e.toJson()).toList());
      await AppDatabase.colRole
          .remove(where.match('name', 'r^[a-z]|[A-Z]|[0-9]'));
      await AppDatabase.colRole
          .insertAll(ROLES_CLASSIC.map((e) => e.toJson()).toList());
      return Response.ok(ResponseConstant.responseSuccess({}));
    } else
      return Response.ok(ResponseConstant.responseError());
  }
}
