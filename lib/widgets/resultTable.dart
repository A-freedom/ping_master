import '../functionality/MyPing.dart';
import '../functionality/PingResult.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

import '../functionality/Host.dart';


class PingTable extends StatefulWidget {
  const PingTable({Key? key});

  @override
  _PingTableState createState() => _PingTableState();
}


class _PingTableState extends State<PingTable> {
  late PingHosts pingHosts ;
  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
    pingHosts.dispose();
  }

  @override
  Widget build(BuildContext context) {
    pingHosts = PingHosts(context)..refresh();
    var pingResultControllers = pingHosts.getPingResultControllers ;
    return DataTable2(
        dataTextStyle: const TextStyle(
          fontSize: 16, // Adjust the font size
          fontWeight: FontWeight.normal,
          color: Colors.black87,
        ),
        headingTextStyle: const TextStyle(
          fontSize: 18, // Adjust the font size for headings
          fontWeight: FontWeight.bold,
          color: Colors.white, // Change heading text color
        ),
        headingRowColor: MaterialStateColor.resolveWith((states) {
          return Theme.of(context).primaryColor;
        }),
        // sortColumnIndex: 0,
        // sortAscending: true,
        columns: const [
          DataColumn(
            label: Text('Host'),
          ),
          DataColumn(
            label: Text('Max', textAlign: TextAlign.center),
          ),
          DataColumn(
            label: Text('Avg', textAlign: TextAlign.center),
          ),
          DataColumn(
            label: Text('Min', textAlign: TextAlign.center),
          ),
          DataColumn(
            label: Text('Packet', textAlign: TextAlign.center),
          ),
        ],
        rows: List<DataRow>.generate(
          pingResultControllers.keys.length,
              (index) {
            final Host host = pingResultControllers.keys.toList()[index];
            return DataRow(
              cells: [
                DataCell(Text(host.hostName)),
                DataCell(
                  StreamBuilder<PingResult>(
                    stream: pingResultControllers[host]?.stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.data!.succeed) {
                        return const Text('N/A');
                      }

                      final pingResult = snapshot.data;
                      return Text(pingResult!.max.toStringAsFixed(2));
                    },
                  ),
                ),
                DataCell(
                  StreamBuilder<PingResult>(
                    stream: pingResultControllers[host]?.stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.data!.succeed) {
                        return const Text('N/A');
                      }

                      final pingResult = snapshot.data;
                      return Text(pingResult!.avg.toStringAsFixed(2));
                    },
                  ),
                ),
                DataCell(
                  StreamBuilder<PingResult>(
                    stream: pingResultControllers[host]?.stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.data!.succeed) {
                        return const Text('N/A');
                      }

                      final pingResult = snapshot.data;
                      return Text(pingResult!.min.toStringAsFixed(2));
                    },
                  ),
                ),
                DataCell(
                  StreamBuilder<PingResult>(
                    stream: pingResultControllers[host]?.stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData) {
                        return const Text('N/A');
                      }

                      final pingResult = snapshot.data;
                      return Text(pingResult!.packetLoos.toString());
                    },
                  ),
                ),
              ],
            );
          },
        ),
      );
  }
}

