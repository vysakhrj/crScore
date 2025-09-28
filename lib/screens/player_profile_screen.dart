import 'package:cricket_scorer/models/player.dart';
import 'package:flutter/material.dart';

class PlayerProfileScreen extends StatelessWidget {
  final Player player;

  PlayerProfileScreen({required this.player});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PLAYER PROFILE',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 20,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Player Name Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[200],
                    child: Text(
                      player.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    player.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Batting Statistics
            _buildSectionHeader('BATTING STATISTICS'),
            const SizedBox(height: 16),
            _buildBattingStats(),
            const SizedBox(height: 32),

            // Bowling Statistics
            _buildSectionHeader('BOWLING STATISTICS'),
            const SizedBox(height: 16),
            _buildBowlingStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w300,
        color: Colors.grey[700],
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildBattingStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildStatRow('Runs Scored', player.runs.toString()),
          _buildStatRow('Balls Faced', player.ballsFaced.toString()),
          _buildStatRow('Fours', player.fours.toString()),
          _buildStatRow('Sixes', player.sixes.toString()),
          _buildStatRow('Dismissals', player.dismissals.toString()),
          _buildStatRow('Not Outs', player.notOuts.toString()),
          const Divider(height: 24),
          _buildStatRow(
              'Batting Average', player.battingAverage.toStringAsFixed(2)),
          _buildStatRow(
              'Strike Rate', '${player.battingStrikeRate.toStringAsFixed(2)}%'),
        ],
      ),
    );
  }

  Widget _buildBowlingStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildStatRow('Wickets Taken', player.wickets.toString()),
          _buildStatRow('Overs Bowled', player.formattedOvers),
          _buildStatRow('Balls Bowled', player.ballsBowled.toString()),
          _buildStatRow('Runs Conceded', player.runsConceded.toString()),
          _buildStatRow('Maidens', player.maidens.toString()),
          const Divider(height: 24),
          _buildStatRow(
              'Bowling Average', player.bowlingAverage.toStringAsFixed(2)),
          _buildStatRow('Bowling Strike Rate',
              player.bowlingStrikeRate.toStringAsFixed(2)),
          _buildStatRow(
              'Economy Rate', '${player.economyRate.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
