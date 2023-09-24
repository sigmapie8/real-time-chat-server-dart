import 'dart:io';

class ChatServer {
  late ServerSocket server;
  final List<Socket> _clients = [];

  ChatServer.init({int port = 8080}) {
    ServerSocket.bind(InternetAddress.anyIPv4, port).then((value) {
      server = value;
      print(
          "Server is running at <${server.address.asString()}:${server.port}>\n");

      server.listen(
        (client) {
          handleNewClient(client);
        },
        onDone: () {
          server.close();
          print("Server closed.");
        },
      );
    });
  }

  void handleNewClient(Socket client) {
    connectClient(client);
    writeToClients(
        message:
            "<${client.remoteAddress.asString()}:${client.remotePort}> entered the chat.\n");

    client.listen(
      (message) {
        writeToClients(
            message:
                "<${client.remoteAddress.asString()}:${client.remotePort}>: ${String.fromCharCodes(message)}",
            exception: client);
      },
      onDone: () {
        removeClient(client);
        writeToClients(
            message:
                "<${client.remoteAddress.asString()}:${client.remotePort}> left the chat.\n");
      },
    );
  }

  void connectClient(Socket client) {
    _clients.add(client);
    print(
        "<${client.remoteAddress.asString()}:${client.remotePort}> connected.");
  }

  void removeClient(Socket client) {
    _clients.remove(client);
    print(
        "<${client.remoteAddress.asString()}:${client.remotePort}> disconnected.");
    client.close();
  }

  void writeToClients({
    required String message,
    Socket? exception,
  }) {
    for (Socket member in _clients) {
      if (member != exception) {
        member.write(message);
      }
    }
  }
}

extension InternetAddressX on InternetAddress {
  String asString() {
    return this.rawAddress.join(".");
  }
}
