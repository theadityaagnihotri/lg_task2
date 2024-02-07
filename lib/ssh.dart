// TODO 2: Import 'dartssh2' package
import 'package:dartssh2/dartssh2.dart';
import 'package:lg_task2/kml_entity.dart';
import 'package:lg_task2/screen_overlay.dart';
import 'dart:async';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class SSH {
  late String _host;
  late String _port;
  late String _username;
  late String _passwordOrKey;
  late String _numberOfRigs;
  SSHClient? _client;

  // Initialize connection details from shared preferences
  Future<void> initConnectionDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('ipAddress') ?? 'default_host';
    _port = prefs.getString('sshPort') ?? '22';
    _username = prefs.getString('username') ?? 'lg';
    _passwordOrKey = prefs.getString('password') ?? 'lg';
    _numberOfRigs = prefs.getString('numberOfRigs') ?? '3';
  }

  // Connect to the Liquid Galaxy system
  Future<bool?> connectToLG() async {
    await initConnectionDetails();

    try {
      //TODO 3: Connect to Liquid Galaxy system, using examples from https://pub.dev/packages/dartssh2#:~:text=freeBlocks%7D%27)%3B-,%F0%9F%AA%9C%20Example%20%23,-SSH%20client%3A
      final socket = await SSHSocket.connect(_host, int.parse(_port));

      _client = SSHClient(
        socket,
        username: _username,
        onPasswordRequest: () => _passwordOrKey,
      );

      return true;
    } on SocketException catch (e) {
      print('Failed to connect: $e');
      return false;
    }
  }

  Future<SSHSession?> execute() async {
    try {
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      final execResult =
          await _client!.execute('echo "search=Shahjahanpur" > /tmp/query.txt');
      return execResult;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

  Future<SSHSession?> rebootLG() async {
    try {
      if (_client == null) {
        print('SSH client is not initialised.');
        return null;
      }
      for (var i = int.parse(_numberOfRigs); i > 0; i--) {
        await _client!.execute(
            'sshpass -p $_passwordOrKey ssh -t lg$i "echo $_passwordOrKey | sudo -S reboot"');
      }
      return null;
    } catch (error) {
      print('Error Occured');
      return null;
    }
  }

  int get balloonScreen {
    int screenAmount = int.parse(_numberOfRigs);
    if (screenAmount == 1) {
      return 1;
    }

    // Gets the most right screen.
    return (screenAmount / 2).floor() + 1;
  }

  Future<void> setLogos(
      {String name = 'CST-logos',
      String content = '<name>Logos</name>'}) async {
    final screenOverlay = ScreenOverlayEntity.logos();

    final kml = KMLEntity(
      name: name,
      content: content,
      screenOverlay: screenOverlay.tag,
    );

    try {
      await sendKMLToSlave(balloonScreen, kml.body);
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendKMLToSlave(int screen, String content) async {
    try {
      await _client!
          .execute("echo '$content' > /var/www/html/kml/slave_$screen.kml");
    } catch (e) {
      print(e);
    }
  }
  // DEMO above, all the other functions below
//   TODO 11: Make functions for each of the tasks in the home screen
}
