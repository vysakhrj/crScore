
import 'package:cricket_scorer/models/player.dart';
import 'package:flutter/material.dart';

class NewBatterDialog extends StatefulWidget {
  final List<Player> availableBatters;

  NewBatterDialog({required this.availableBatters});

  @override
  _NewBatterDialogState createState() => _NewBatterDialogState();
}

class _NewBatterDialogState extends State<NewBatterDialog> {
  Player? _selectedBatter;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select New Batter'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<Player>(
            hint: Text('Select Batter'),
            value: _selectedBatter,
            onChanged: (Player? newValue) {
              setState(() {
                _selectedBatter = newValue;
              });
            },
            items: widget.availableBatters.map((player) {
              return DropdownMenuItem<Player>(
                value: player,
                child: Text(player.name),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, _selectedBatter?.id);
          },
          child: Text('Confirm'),
        ),
      ],
    );
  }
}
