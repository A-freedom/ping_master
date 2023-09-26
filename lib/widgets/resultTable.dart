import 'package:provider/provider.dart';

import '../functionality/MyPing.dart';
import '../functionality/PingResult.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

import '../functionality/Host.dart';
import '../provider/ping_data_provider.dart';


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
      dataTextStyle: Theme.of(context).textTheme.bodyLarge,
      headingTextStyle:  Theme.of(context).textTheme.titleMedium,
      headingRowColor: MaterialStateColor.resolveWith((states) {
        return Theme.of(context).colorScheme.inversePrimary ?? Colors.white;
      }),
      // sortColumnIndex: 0,
      // sortAscending: true,
      columns: const [
        DataColumn(
          label: Text('Host',maxLines: 1,overflow: TextOverflow.clip,),
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
        DataColumn(
          label: Text('', textAlign: TextAlign.center),
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
              DataCell(IconButton(icon: const Icon(Icons.delete_forever), onPressed: () {
                context.read<PingDataProvider>().removeHost(index) ;
              },))
              
            ],
          );
        },
      ),
    );
  }
}