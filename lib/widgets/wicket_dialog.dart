import 'package:cricket_scorer/models/player.dart';
import 'package:flutter/material.dart';

enum WicketType {
  bowled,
  caught,
  lbw,
  runOut,
  stumped,
  hitWicket,
  obstructingTheField,
  retiredOut,
  timedOut,
  handledTheBall,
}

class WicketDialog extends StatefulWidget {
  final Player currentStriker;
  final Player currentNonStriker;

  WicketDialog({required this.currentStriker, required this.currentNonStriker});

  @override
  _WicketDialogState createState() => _WicketDialogState();
}

class _WicketDialogState extends State<WicketDialog> {
  int _runsOnWicketBall = 0;
  WicketType? _selectedWicketType;
  Player? _runOutPlayer;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Wicket Details'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Runs scored on this ball:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (_runsOnWicketBall > 0) _runsOnWicketBall--;
                    });
                  },
                ),
                Text('$_runsOnWicketBall', style: TextStyle(fontSize: 24)),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      _runsOnWicketBall++;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('Type of Wicket:'),
            DropdownButton<WicketType>(
              value: _selectedWicketType,
              hint: Text('Select Wicket Type'),
              onChanged: (WicketType? newValue) {
                setState(() {
                  _selectedWicketType = newValue;
                  if (newValue != WicketType.runOut) {
                    _runOutPlayer = null; // Reset if not run out
                  }
                });
              },
              items: WicketType.values.map((type) {
                return DropdownMenuItem<WicketType>(
                  value: type,
                  child: Text(
                      '${type.toString().split('.').last.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}').trim()}'),
                );
              }).toList(),
            ),
            if (_selectedWicketType == WicketType.runOut) ...[
              SizedBox(height: 20),
              Text('Who was run out?'),
              DropdownButton<Player>(
                value: _runOutPlayer,
                hint: Text('Select Player'),
                onChanged: (Player? newValue) {
                  setState(() {
                    _runOutPlayer = newValue;
                  });
                },
                items: [
                  DropdownMenuItem<Player>(
                    value: widget.currentStriker,
                    child: Text('${widget.currentStriker.name} (Striker)'),
                  ),
                  DropdownMenuItem<Player>(
                    value: widget.currentNonStriker,
                    child:
                        Text('${widget.currentNonStriker.name} (Non-Striker)'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, null); // Cancel
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_selectedWicketType != null &&
                (_selectedWicketType != WicketType.runOut ||
                    _runOutPlayer != null)) {
              Navigator.pop(context, {
                'runs': _runsOnWicketBall,
                'wicketType': _selectedWicketType,
                'runOutPlayerId': _runOutPlayer?.id,
              });
            }
          },
          child: Text('Confirm'),
        ),
      ],
    );
  }
}
