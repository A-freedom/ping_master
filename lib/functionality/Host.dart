import 'package:dart_ping/dart_ping.dart';


class Host {
  String _domainOrIP = '';
  String _ipAddress = '';

  String get hostName => _domainOrIP;
  String get ipAddress => _ipAddress;

  Host(String domainOrIP) {
    _domainOrIP = domainOrIP;
    _ipAddress = domainOrIP; // Default to the provided domainOrIP

    _resolveIpAddress();
  }

  Future<void> _resolveIpAddress() async {
    const ipPattern =
        r'^(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)$';
    final ipv4RegExp = RegExp(ipPattern);

    if (!ipv4RegExp.hasMatch(_domainOrIP)) {
      final result = await Ping(_domainOrIP, count: 1).stream.first;
      final ip = result.response?.ip;
      if (ip != null) {
        _ipAddress = ip;
      }
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Host && _domainOrIP == other._domainOrIP;
  }

  @override
  int get hashCode => _domainOrIP.hashCode;
}


// class Host.dart {
//   late final String _domainOrIP;
//   late final String _ipAddress;
//
//   String get domainOrIP => _domainOrIP;
//
//   String get ipAddress => _ipAddress;
//
//
//
//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//
//     return other is Host.dart && _domainOrIP == other._domainOrIP;
//   }
//
//   @override
//   int get hashCode => _domainOrIP.hashCode;
// }

