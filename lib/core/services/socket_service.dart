import 'package:rincon_sabor_flutter/config.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final IO.Socket _socket = IO.io(
    Config.apiUrl,
    IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build(),
  );

  static void initSocket(Function onMesasActualizadas) {
    _socket.connect();

    _socket.onConnect((_) {
      print('✅ Socket conectado');
    });

    _socket.on('mesas_actualizadas', (_) async {
      print('📢 Evento mesas_actualizadas recibido');
      await onMesasActualizadas(); // Aquí puedes volver a obtener las mesas y setState
    });

    _socket.onDisconnect((_) {
      print('🔌 Socket desconectado');
    });
  }

  static void onMesasActualizadasListener(void Function() callback) {
    _socket.on('mesas_actualizadas', (_) => callback());
  }

  static void onMenusActualizadosListener(Function onMenusActualizados) {
    _socket.on('menus_actualizados', (_) async {
      print('📢 Evento menus_actualizados recibido');
      await onMenusActualizados();
    });
  }

  static void dispose() => _socket.dispose();
}
