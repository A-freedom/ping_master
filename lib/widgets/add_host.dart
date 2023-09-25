import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/ping_data_provider.dart';

class AddHost extends StatefulWidget {
  const AddHost({super.key});

  @override
  State<AddHost> createState() => _AddHostState();
}

class _AddHostState extends State<AddHost> {
  final TextEditingController _textController = TextEditingController();

  final _validationKey = GlobalKey<FormState>();

  bool _textIsValid = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a host'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Form(
            key: _validationKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: TextFormField(
              onChanged: (value) => setState(() {}),
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Type something...',
              ),
              validator: myValidator,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: !_textIsValid
              ? null
              : () {
                  final enteredText = _textController.text;
                  context.read<PingDataProvider>().addHost(enteredText);
                  Navigator.of(context).pop();
                },
          child: const Text('Submit'),
        ),
      ],
    );
  }

  String? myValidator(String? value) {
    if (value == null) {
      _textIsValid = false;
      return 'filed can\'t be empty';
    }

    const ipPattern =
        r'^(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)$';
    final RegExp ipRegExp = RegExp(ipPattern);

    const domainPattern =
        r'^((?!-)[A-Za-z0-9-]{1,63}(?<!-)\.?)+(?:[A-Za-z]{2,}|xn--[A-Za-z0-9]+)$';
    final RegExp domainRegExp = RegExp(domainPattern);
    if (!(domainRegExp.hasMatch(value) || ipRegExp.hasMatch(value))) {
      _textIsValid = false;
      return 'this isn\'t a valid IP or a domain';
    }
    _textIsValid = true;
    return null;
  }
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

