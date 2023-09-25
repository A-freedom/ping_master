import '../functionality/Host.dart';
import 'package:flutter/foundation.dart';


class PingDataProvider extends ChangeNotifier {
  // Define your state variables here
  // Example:
  List<Host> hosts = [
    '10.95.12.1',
    '10.95.12.2',
    '10.95.12.11',
    '10.95.12.12',
    '10.95.12.13',
    // '10.95.12.96',
    // 'google.com',
    // 'facebook.com',
    // 'github.com'
  ].map((e) => Host(e)).toList();

  void addHost(String hostName) {
    hosts.add(Host(hostName));
    notifyListeners();
  }

  void removeHost(int index){
    hosts.removeAt;
    notifyListeners();
  }
}
