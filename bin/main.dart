import 'package:socket_io/socket_io.dart';
import 'package:werewolf_server/socket/socket_controller.dart';
import 'package:werewolf_server/socket/socket_manager.dart';
import 'package:werewolf_server/werewolf_server.dart';

Future main() async {
  final WereWolfConfiguration config = WereWolfConfiguration('config.yaml');
  AppJWT.init(secretKey: config.secretKey, expiredInDay: 30);
  final app = Application<WerewolfServerChannel>()
    ..options.context = {'config': config}
    ..options.port = config.portWebservice;
  await AppDatabase.init(
      username: config.username,
      password: config.password,
      databaseName: config.databaseName,
      host: config.host);

  // final count = Platform.numberOfProcessors ~/ 2;
  // await app.start(numberOfInstances: count > 0 ? count : 1);
  await app.start();

  print("Application started on port: ${config.portWebservice}.");

  // Dart server
  final io = Server();
  final SocketManager manager = SocketManager()..init(io);

  io.on('connection', (client) {
    print('Connection: ${client.id}');

    client.on('disconnect', (_data) {
      print('Disconnect: ${client.id}');
      manager.clientDisconnect(client as Socket);
    });

    _verifyToken(client as Socket);

    return client;
  });
  io.listen(config.portSocket);
}

Future _verifyToken(Socket client) async {
  final String accessToken = client.handshake['query']['accessToken'] as String;
  final JWTResponse response = AppJWT.verify(accessToken);
  if (response.isSuccess) {
    client.user = response.data;
    SocketController(client);
  } else
    client.disconnect();
}
