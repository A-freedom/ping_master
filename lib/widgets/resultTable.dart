import 'dart:async';

import 'package:provider/provider.dart';

import '../functionality/MyPing.dart';
import '../functionality/PingResult.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

import '../functionality/Host.dart';
import '../provider/ping_data_provider.dart';


class PingTable extends StatefulWidget {
  const PingTable({super.key});


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
        return Theme.of(context).colorScheme.inversePrimary;
      }),
      // sortColumnIndex: 0,
      // sortAscending: true,
      columns: const [
        DataColumn(
          label: Text('Host', textAlign:  TextAlign.center,),
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
      rows: generateDataRows(pingResultControllers),
    );
  }

  List<DataRow> generateDataRows(pingResultControllers) {
    final List<Host> hosts = pingResultControllers.keys.toList();

    return List<DataRow>.generate(
      hosts.length,
          (index) {
        final Host host = hosts[index];
        final StreamController<PingResult>? controller = pingResultControllers[host];

        return DataRow(
          cells: [
            DataCell(Text(host.hostName)),
            DataCell(buildPingResultWidget(controller, (pingResult) => pingResult.max.toStringAsFixed(0))),
            DataCell(buildPingResultWidget(controller, (pingResult) => pingResult.avg.toStringAsFixed(0))),
            DataCell(buildPingResultWidget(controller, (pingResult) => pingResult.min.toStringAsFixed(0))),
            DataCell(buildPingResultWidget(controller, (pingResult) => pingResult.packetLoos.toStringAsFixed(0))),
            DataCell(
              IconButton(
                icon: const Icon(Icons.delete_forever),
                onPressed: () {
                  context.read<HostDataProvider>().removeHost(index);
                },
              ),
            ),
          ],
        );
      },
    );
  }


  Widget buildPingResultWidget(StreamController<PingResult>? controller, String Function(PingResult) valueExtractor) {
    return  StreamBuilder<PingResult>(
      stream: controller?.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}',maxLines: 1,overflow: TextOverflow.clip,);
        } else if (!snapshot.hasData) {
          return const Text('N/A',maxLines: 1,overflow: TextOverflow.clip,);
        }

        final pingResult = snapshot.data;
        return Text(valueExtractor(pingResult!),maxLines: 1,overflow: TextOverflow.clip,);
      },
    );
  }
}

