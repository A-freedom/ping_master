import 'dart:math';
import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/foundation.dart';
import '../provider/ping_data_provider.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';

import 'Host.dart';
import 'PingResult.dart';

class PingHosts {
  bool _pause = false;

  late final BuildContext _context;

  get getPingResultControllers => _pingResultControllers;

  set pause(bool pause) => _pause == pause;
  final Map<Host, StreamController<PingResult>> _pingResultControllers = {};
  final Map<Host, bool> _pingInProgress = {};

  PingHosts._(context) {
    _context = context;
    _createPingStreamControllers();
    _startPingUpdates();
  }

  static PingHosts? _instance;

  factory PingHosts(BuildContext context) {
    // If the instance doesn't exist, create it; otherwise, return the existing instance.
    _instance ??= PingHosts._(context);
    return _instance!;
  }

  void refresh() {
    _createPingStreamControllers();
  }

  void _createPingStreamControllers() {
    final currentHosts = _context.watch<HostDataProvider>().hosts.toSet();

    for (final host in _pingResultControllers.keys.toList()) {
      if (!currentHosts.contains(host)) {
        // Remove controllers for hosts that were removed
        // _pingResultControllers[host]!.close(); // Close the controller
        _pingResultControllers.remove(host); // Remove it from the map
        _pingInProgress.remove(host); // Remove any associated data
      }
    }

    for (final host in currentHosts) {
      if (!_pingResultControllers.containsKey(host)) {
        final controller = StreamController<PingResult>.broadcast();
        _pingResultControllers[host] = controller;
        _pingInProgress[host] = false;
      }
    }
  }



  void _startPingUpdates() {
    const pingUpdateInterval = Duration(milliseconds: 100);
    Timer.periodic(pingUpdateInterval, (timer) async {
      try {
        for (final host in _pingResultControllers.keys) {
          if (!_pingInProgress[host]! && !_pause) {
            _pingInProgress[host] =
                true; // Set the flag to true when starting a ping
            final result = await _runPing(host.ipAddress, 20);
            if (!_pause) {
              _pingInProgress[host] =
                  false; // Set the flag back to false when the ping is done
              _pingResultControllers[host]?.sink.add(result);
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    });
  }

  Future<double?> _simplePing(String hostName) async {
    final result = await Ping(hostName, count: 1).stream.first;
    return result.response?.time?.inMicroseconds.toDouble();
  }

  Future<PingResult> _runPing(String hostName, int count,
      {int interval = 50}) async {
    PingResult result = PingResult();
    final List<Future<double?>> futures = [];

    for (int i = 0; i < count; i++) {
      futures.add(_simplePing(hostName));
      await Future.delayed(Duration(milliseconds: interval));
    }
    final rowResults = await Future.wait(futures);

    List<double> successResults = [];
    for (var element in rowResults) {
      if (element == null) continue;
      successResults.add(element / 1000);
    }
    // Deal with this later
    final fail = rowResults.length - successResults.length;
    result.packetLoos = (fail).toDouble() / count * 100;

    if (successResults.isNotEmpty) {
      result.min = successResults.reduce((a, b) => min(a, b));
      result.max = successResults.reduce((a, b) => max(a, b));

      final sum = successResults.fold(0.0, (a, b) => a + b);
      result.avg = sum / successResults.length;

      result.succeed = true;
    }
    return result;
  }

  void dispose() {
    _pause = true;
    for (final controller in _pingResultControllers.values) {
      controller.close();
    }
  }
}
