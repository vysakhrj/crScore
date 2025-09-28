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

  const WicketDialog({
    required this.currentStriker,
    required this.currentNonStriker,
  });

  @override
  _WicketDialogState createState() => _WicketDialogState();
}

class _WicketDialogState extends State<WicketDialog> {
  int _runsOnWicketBall = 0;
  WicketType? _selectedWicketType;
  Player? _runOutPlayer;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'WICKET DETAILS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),

              /// Runs
              const Text('Runs scored on this ball:'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      setState(() {
                        if (_runsOnWicketBall > 0) _runsOnWicketBall--;
                      });
                    },
                  ),
                  Text(
                    '$_runsOnWicketBall',
                    style: const TextStyle(fontSize: 28),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      setState(() => _runsOnWicketBall++);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              /// Wicket Type
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Type of Wicket:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<WicketType>(
                value: _selectedWicketType,
                decoration: InputDecoration(
                  hintText: 'Select Wicket Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: WicketType.values.map((type) {
                  final formatted = type
                      .toString()
                      .split('.')
                      .last
                      .replaceAllMapped(
                          RegExp(r'([A-Z])'), (m) => ' ${m.group(1)}')
                      .trim();
                  return DropdownMenuItem<WicketType>(
                    value: type,
                    child: Text(formatted),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedWicketType = newValue;
                    if (newValue != WicketType.runOut) {
                      _runOutPlayer = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 20),

              /// Run Out - Player Selection
              if (_selectedWicketType == WicketType.runOut) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Who was run out?',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Player>(
                  value: _runOutPlayer,
                  decoration: InputDecoration(
                    hintText: 'Select Player',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: [
                    DropdownMenuItem<Player>(
                      value: widget.currentStriker,
                      child: Text('${widget.currentStriker.name} (Striker)'),
                    ),
                    DropdownMenuItem<Player>(
                      value: widget.currentNonStriker,
                      child: Text(
                          '${widget.currentNonStriker.name} (Non-Striker)'),
                    ),
                  ],
                  onChanged: (Player? newValue) {
                    setState(() => _runOutPlayer = newValue);
                  },
                ),
                const SizedBox(height: 20),
              ],

              /// Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, null),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black87,
                      ),
                      child: const Text('CANCEL'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_selectedWicketType != null &&
                              (_selectedWicketType != WicketType.runOut ||
                                  _runOutPlayer != null))
                          ? () {
                              Navigator.pop(context, {
                                'runs': _runsOnWicketBall,
                                'wicketType': _selectedWicketType,
                                'runOutPlayerId': _runOutPlayer?.id,
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (_selectedWicketType != null &&
                                (_selectedWicketType != WicketType.runOut ||
                                    _runOutPlayer != null))
                            ? Colors.black87
                            : Colors.grey[400],
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text('CONFIRM',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1.2,
                              color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
