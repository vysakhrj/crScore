import 'package:flutter/material.dart';

class ExtraRunsDialog extends StatefulWidget {
  final String extraType;

  const ExtraRunsDialog({required this.extraType});

  @override
  _ExtraRunsDialogState createState() => _ExtraRunsDialogState();
}

class _ExtraRunsDialogState extends State<ExtraRunsDialog> {
  int _extraRuns = 0;

  @override
  Widget build(BuildContext context) {
    final label = widget.extraType == 'wd' ? 'Wide' : 'No-Ball';
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ADD RUNS FOR $label',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.black54)),
            const SizedBox(height: 16),
            const Text('Additional runs:'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    setState(() {
                      if (_extraRuns > 0) _extraRuns--;
                    });
                  },
                ),
                Text('$_extraRuns', style: const TextStyle(fontSize: 28)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    setState(() => _extraRuns++);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, _extraRuns),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text('ADD',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.2,
                      color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
