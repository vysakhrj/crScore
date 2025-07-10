
import 'package:flutter/material.dart';

class ExtraRunsDialog extends StatefulWidget {
  final String extraType;

  ExtraRunsDialog({required this.extraType});

  @override
  _ExtraRunsDialogState createState() => _ExtraRunsDialogState();
}

class _ExtraRunsDialogState extends State<ExtraRunsDialog> {
  int _extraRuns = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Runs for ${widget.extraType == 'wd' ? 'Wide' : 'No-Ball'}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Additional runs:'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    if (_extraRuns > 0) _extraRuns--;
                  });
                },
              ),
              Text('$_extraRuns', style: TextStyle(fontSize: 24)),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    _extraRuns++;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, _extraRuns);
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
