import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webxhack/utils/constants.dart';

class SocketService {
  late IO.Socket socket;
  final String api = AppConstants.baseUrlSocket; // Add this to your constants

  // Initialize socket connection
  Future<void> initSocket(Function(Map<String, dynamic>) onVoteRequestReceived) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print('No user ID found for socket connection');
      return;
    }

    socket = IO.io(api, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      print('✅ Connected to socket server');
      // Join room with user ID
      socket.emit('join', {'userId': userId});
    });

    socket.onDisconnect((_) => print('❌ Disconnected from socket'));

    // Listen for new vote requests
    socket.on('voterequest/$userId', (data) {
      print('New vote request received: $data');
      if (data is Map<String, dynamic>) {
        onVoteRequestReceived(data);
      }
    });

    socket.onError((error) => print('Socket error: $error'));
  }

  void disconnect() {
    socket.disconnect();
  }
}