import 'package:cricket_scorer/models/tennis_player.dart';
import 'package:cricket_scorer/models/tennis_tournament.dart';
import 'package:cricket_scorer/models/tennis_team.dart';
import 'package:cricket_scorer/models/tennis_match.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';

class TennisTournamentScreen extends StatefulWidget {
  @override
  _TennisTournamentScreenState createState() => _TennisTournamentScreenState();
}

class _TennisTournamentScreenState extends State<TennisTournamentScreen> {
  final _tournamentNameController = TextEditingController();
  final _newPlayerNameController = TextEditingController();
  final _pointsToWinSetController = TextEditingController(text: '10');
  final _setsToWinController = TextEditingController(text: '3');

  List<TennisPlayer> allPlayers = [];
  List<TennisPlayer> selectedPlayers = [];
  List<TennisPlayer> defaultTeamPlayers = []; // Players in the default team
  TennisTournament? currentTournament;
  bool isTournamentStarted = false;

  // Confetti controller
  late ConfettiController _confettiController;

  // Text-to-speech
  late FlutterTts _flutterTts;
  bool _ttsInitialized = false;
  bool _ttsEnabled = true; // Toggle for TTS on/off
  DateTime? _lastTtsTime;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
    _generateTournamentName();
    _initializeConfetti();
    _initializeTts();
  }

  void _initializeConfetti() {
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  Future<void> _initializeTts() async {
    try {
      _flutterTts = FlutterTts();
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _ttsInitialized = true;
    } catch (e) {
      // TTS not available (e.g., on web or if plugin not properly linked)
      // Silently disable TTS feature
      print('TTS initialization failed: $e');
      _ttsInitialized = false;
    }
  }

  Future<void> _speakScore(TennisMatch match) async {
    if (!_ttsInitialized || !_ttsEnabled) return;

    try {
      // Throttle TTS to avoid speaking too frequently (max once per 2 seconds)
      final now = DateTime.now();
      if (_lastTtsTime != null &&
          now.difference(_lastTtsTime!).inMilliseconds < 2000) {
        return;
      }
      _lastTtsTime = now;

      final team1Points = match.team1CurrentPoints;
      final team2Points = match.team2CurrentPoints;

      // Just say the current set score: "4 0" (without dash)
      final scoreText = '$team1Points $team2Points';

      // Stop any ongoing speech before speaking new score
      await _flutterTts.stop();
      await _flutterTts.speak(scoreText);
    } catch (e) {
      // TTS failed, disable it to avoid repeated errors
      print('TTS speak failed: $e');
      _ttsInitialized = false;
    }
  }

  void _triggerConfetti() {
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    if (_ttsInitialized) {
      try {
        _flutterTts.stop();
      } catch (e) {
        // Ignore errors during disposal
      }
    }
    super.dispose();
  }

  void _generateTournamentName() {
    final now = DateTime.now();
    final formattedDate =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final formattedTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    _tournamentNameController.text =
        'Badminton Tournament - $formattedDate $formattedTime';
  }

  Future<void> _loadPlayers() async {
    // For now, we'll create some sample players
    // In a real app, you'd load from storage
    setState(() {
      allPlayers = [
        TennisPlayer(id: '1', name: 'Aaseer'),
        TennisPlayer(id: '2', name: 'Akash'),
        TennisPlayer(id: '3', name: 'Sachu'),
        TennisPlayer(id: '4', name: 'Karthik'),
        TennisPlayer(id: '5', name: 'Kichu'),
        TennisPlayer(id: '6', name: 'Vysakh'),
        TennisPlayer(id: '7', name: 'Vishnu'),
        TennisPlayer(id: '8', name: 'Akhil'),
        TennisPlayer(id: '9', name: 'Kuttayi'),
        TennisPlayer(id: '10', name: 'Thrilok'),
        TennisPlayer(id: '11', name: 'Athira')
      ];
    });
  }

  void _addNewPlayer() {
    if (_newPlayerNameController.text.trim().isEmpty) return;

    final newPlayer = TennisPlayer(
      id: const Uuid().v4(),
      name: _newPlayerNameController.text.trim(),
    );

    setState(() {
      allPlayers.add(newPlayer);
    });

    _newPlayerNameController.clear();
    Navigator.of(context).pop();
  }

  void _togglePlayerSelection(TennisPlayer player) {
    setState(() {
      if (selectedPlayers.any((p) => p.id == player.id)) {
        selectedPlayers.removeWhere((p) => p.id == player.id);
      } else {
        selectedPlayers.add(player);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (selectedPlayers.length == allPlayers.length) {
        // Deselect all
        selectedPlayers.clear();
      } else {
        // Select all
        selectedPlayers = List.from(allPlayers);
      }
    });
  }

  void _toggleDefaultTeamPlayer(TennisPlayer player) {
    setState(() {
      if (defaultTeamPlayers.any((p) => p.id == player.id)) {
        defaultTeamPlayers.removeWhere((p) => p.id == player.id);
      } else {
        // Only allow 2 players in default team
        if (defaultTeamPlayers.length < 2) {
          defaultTeamPlayers.add(player);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Default team can only have 2 players'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    });
  }

  void _fillRemainingPlayers() {
    if (defaultTeamPlayers.length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select exactly 2 players for the default team'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      // Start with default team players
      selectedPlayers = List.from(defaultTeamPlayers);

      // Get remaining players (excluding default team)
      final remainingPlayers = allPlayers
          .where(
              (player) => !defaultTeamPlayers.any((dtp) => dtp.id == player.id))
          .toList();

      // Randomly select remaining players to reach minimum 4 players total
      final random = Random();
      final minPlayersNeeded = 4 - selectedPlayers.length;

      if (remainingPlayers.length >= minPlayersNeeded) {
        // Shuffle and take required number
        remainingPlayers.shuffle(random);
        selectedPlayers.addAll(remainingPlayers.take(minPlayersNeeded));
      } else {
        // Add all remaining players
        selectedPlayers.addAll(remainingPlayers);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Added ${selectedPlayers.length - defaultTeamPlayers.length} random players to complete the tournament'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _startTournament() async {
    if (selectedPlayers.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 2 players'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedPlayers.length > 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 16 players allowed'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedPlayers.length % 2 != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an even number of players'),
          backgroundColor: Colors.red,
        ),
      );
    }

    // Validate match settings
    final pointsToWinSet = int.tryParse(_pointsToWinSetController.text);
    final setsToWin = int.tryParse(_setsToWinController.text);

    if (pointsToWinSet == null || pointsToWinSet < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please enter a valid number of points to win a set (minimum 1)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (setsToWin == null || setsToWin < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please enter a valid number of sets to win (minimum 1)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('DEBUG: Starting tournament with ${selectedPlayers.length} players');

    final tournament = TennisTournament(
      id: const Uuid().v4(),
      name: _tournamentNameController.text.trim(),
      allPlayers: allPlayers,
      selectedPlayers: selectedPlayers,
      defaultTeamPlayers: defaultTeamPlayers,
      createdAt: DateTime.now(),
      pointsToWinSet: pointsToWinSet,
      setsToWin: setsToWin,
    );

    try {
      print('DEBUG: Created tournament, generating teams...');
      await tournament.generateTeams();
      print('DEBUG: Teams generated, generating matches...');
      await tournament.generateMatches();
      print(
          'DEBUG: Matches generated. Total matches: ${tournament.matches.length}');

      setState(() {
        currentTournament = tournament;
        isTournamentStarted = true;
      });

      print(
          'DEBUG: Tournament started. Current matches: ${currentTournament!.matches.length}');
    } catch (e) {
      print('DEBUG: Error generating matches: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error generating matches'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddPlayerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Player'),
          content: TextField(
            controller: _newPlayerNameController,
            decoration: const InputDecoration(
              labelText: 'Player Name',
              hintText: 'Enter player name',
            ),
            autofocus: true,
            onSubmitted: (value) => _addNewPlayer(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _newPlayerNameController.clear();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _addNewPlayer,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          _buildMainContent(),
          // Confetti overlay
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.orange,
                Colors.yellow,
                Colors.red,
              ],
            ),
          ),
        ],
      ),
      appBar: AppBar(
        title: Text(
          'BADMINTON TOURNAMENT',
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
        actions: [
          // TTS Toggle Button
          if (isTournamentStarted)
            IconButton(
              icon: Icon(
                _ttsEnabled ? Icons.volume_up : Icons.volume_off,
                color: _ttsEnabled ? Colors.grey[700] : Colors.grey[400],
              ),
              onPressed: () {
                setState(() {
                  _ttsEnabled = !_ttsEnabled;
                });
              },
              tooltip: _ttsEnabled ? 'Turn off voice' : 'Turn on voice',
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      // floatingActionButton: !isTournamentStarted
      //     ? FloatingActionButton(
      //         onPressed: _showAddPlayerDialog,
      //         backgroundColor: Colors.black,
      //         foregroundColor: Colors.white,
      //         child: const Icon(Icons.add),
      //       )
      //     : null,
    );
  }

  Widget _buildMainContent() {
    return isTournamentStarted ? _buildTournamentView() : _buildSetupView();
  }

  Widget buildFlatButton(String text, VoidCallback onPressed) {
    return SizedBox(
      // height: 26,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.black26),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w500, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildSetupView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tournament Name
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tournamentNameController,
                    decoration: const InputDecoration(
                      labelText: 'Tournament Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _generateTournamentName,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Generate new name',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Default Team Section
            const Text(
              'DEFAULT TEAM (OPTIONAL)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Select 2 players to form a default team. Other players will be randomly selected to complete the tournament.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Default Team Players
            if (defaultTeamPlayers.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Default Team (${defaultTeamPlayers.length}/2):',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.amber[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: defaultTeamPlayers
                          .map((player) => Chip(
                                label: Text(player.name),
                                backgroundColor: Colors.amber[200],
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () =>
                                    _toggleDefaultTeamPlayer(player),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _fillRemainingPlayers,
                        icon: const Icon(Icons.shuffle, size: 16),
                        label: const Text('Fill with Random Players'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Match Settings Section
            const Text(
              'MATCH SETTINGS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 12),

            // Points to win set
            TextField(
              controller: _pointsToWinSetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Points to Win a Set',
                hintText: 'e.g., 21',
                border: OutlineInputBorder(),
                helperText: 'Number of points needed to win a set',
              ),
            ),
            const SizedBox(height: 16),

            // Sets to win match
            TextField(
              controller: _setsToWinController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Sets to Win Match',
                hintText: 'e.g., 2 (best of 3)',
                border: OutlineInputBorder(),
                helperText: 'Number of sets needed to win the match',
              ),
            ),
            const SizedBox(height: 24),

            // Players Section Header
            Row(
              children: [
                const Text(
                  'SELECT PLAYERS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const Spacer(),
                Container(
                  child: isTournamentStarted
                      ? const SizedBox(
                          width: 0,
                          height: 0,
                        )
                      : buildFlatButton("Add Player", _showAddPlayerDialog),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${selectedPlayers.length} selected',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Selection Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Select 2-16 players to start the tournament. Odd numbers will create individual player teams.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Select All Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _toggleSelectAll,
                icon: Icon(
                  selectedPlayers.length == allPlayers.length
                      ? Icons.check_box_outline_blank
                      : Icons.check_box,
                  size: 18,
                ),
                label: Text(
                  selectedPlayers.length == allPlayers.length
                      ? 'Deselect All'
                      : 'Select All',
                  style: const TextStyle(fontSize: 14),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Players List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allPlayers.length,
              itemBuilder: (context, index) {
                final player = allPlayers[index];
                final isSelected =
                    selectedPlayers.any((p) => p.id == player.id);

                final isInDefaultTeam =
                    defaultTeamPlayers.any((p) => p.id == player.id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Row(
                      children: [
                        Text(player.name),
                        if (isInDefaultTeam) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'DEFAULT',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.amber[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      '${player.matchesWon}W/${player.matchesPlayed}M • ${player.winPercentage.toStringAsFixed(1)}% win rate',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: isInDefaultTeam
                          ? Colors.amber
                          : (isSelected ? Colors.green : Colors.grey[300]),
                      child: Text(
                        player.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: isInDefaultTeam
                              ? Colors.white
                              : (isSelected ? Colors.white : Colors.grey[700]),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (defaultTeamPlayers.length < 2 || isInDefaultTeam)
                          IconButton(
                            onPressed: () => _toggleDefaultTeamPlayer(player),
                            icon: Icon(
                              isInDefaultTeam
                                  ? Icons.remove_circle
                                  : Icons.add_circle_outline,
                              color: isInDefaultTeam
                                  ? Colors.amber[700]
                                  : Colors.amber[500],
                            ),
                            tooltip: isInDefaultTeam
                                ? 'Remove from default team'
                                : 'Add to default team',
                          ),
                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isSelected ? Colors.green : Colors.grey[400],
                        ),
                      ],
                    ),
                    onTap: () => _togglePlayerSelection(player),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Start Tournament Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed:
                    selectedPlayers.length >= 2 && selectedPlayers.length <= 16
                        ? _startTournament
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'START TOURNAMENT (${selectedPlayers.length} players)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentView() {
    if (currentTournament == null) return Container();

    return DefaultTabController(
      length: currentTournament!.teams.length == 4 ? 3 : 2,
      child: Column(
        children: [
          // Tournament Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Text(
                  currentTournament!.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: currentTournament!.progressPercentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  '${currentTournament!.progressPercentage.toStringAsFixed(1)}% Complete',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              tabs: [
                const Tab(text: 'BRACKET'),
                const Tab(text: 'TEAMS'),
                if (currentTournament!.teams.length == 4)
                  const Tab(text: 'STANDINGS'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              children: [
                _buildBracketTab(),
                _buildTeamsTab(),
                if (currentTournament!.teams.length == 4) _buildStandingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamWithAvatars(TennisTeam? team, bool isWinner,
      {bool isRightAligned = false}) {
    if (team == null) {
      return Text(
        'TBD',
        textAlign: isRightAligned ? TextAlign.end : TextAlign.start,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      );
    }

    // Stack of overlapping avatars
    final avatarStack = SizedBox(
      width: 40,
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: isRightAligned ? 12 : 0,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: isWinner ? Colors.green[100] : Colors.grey[300],
              child: Text(
                team.player1.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isWinner ? Colors.green[700] : Colors.grey[700],
                ),
              ),
            ),
          ),
          Positioned(
            left: isRightAligned ? 0 : 12,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: isWinner ? Colors.green[100] : Colors.grey[300],
              child: Text(
                team.player2.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isWinner ? Colors.green[700] : Colors.grey[700],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // Team name - show full name with proper wrapping
    final teamName = Flexible(
      child: Text(
        team.name,
        style: TextStyle(
          fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
          color: isWinner ? Colors.green[700] : Colors.grey[800],
          fontSize: 12,
        ),
        maxLines: 2,
        overflow: TextOverflow.visible,
        textAlign: isRightAligned ? TextAlign.end : TextAlign.start,
      ),
    );

    if (isRightAligned) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          teamName,
          const SizedBox(width: 8),
          avatarStack,
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          avatarStack,
          const SizedBox(width: 8),
          teamName,
        ],
      );
    }
  }

  Color _getRoundColor(String round) {
    switch (round) {
      case 'Round Robin':
        return Colors.teal[100]!;
      case 'Round of 16':
        return Colors.purple[100]!;
      case 'Quarter Final':
        return Colors.blue[100]!;
      case 'Semi Final':
        return Colors.orange[100]!;
      case 'Final':
        return Colors.green[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getRoundTextColor(String round) {
    switch (round) {
      case 'Round Robin':
        return Colors.teal[700]!;
      case 'Round of 16':
        return Colors.purple[700]!;
      case 'Quarter Final':
        return Colors.blue[700]!;
      case 'Semi Final':
        return Colors.orange[700]!;
      case 'Final':
        return Colors.green[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  Widget _buildTeamsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: currentTournament!.teams.length,
      itemBuilder: (context, index) {
        final team = currentTournament!.teams[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Team ${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  team.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildPlayerCard(team.player1),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPlayerCard(team.player2),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerCard(TennisPlayer player) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            child: Text(
              player.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            player.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${player.winPercentage.toStringAsFixed(1)}% win',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBracketTab() {
    final allMatches = currentTournament!.matches;
    if (allMatches.isEmpty)
      return const Center(child: Text('No matches scheduled yet.'));

    // Group matches by round
    final roundRobinMatches =
        allMatches.where((m) => m.round == 'Round Robin').toList();
    final roundOf16Matches =
        allMatches.where((m) => m.round == 'Round of 16').toList();
    final quarterFinalMatches =
        allMatches.where((m) => m.round == 'Quarter Final').toList();
    final semiFinalMatches =
        allMatches.where((m) => m.round == 'Semi Final').toList();
    final finalMatches = allMatches.where((m) => m.round == 'Final').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (roundRobinMatches.isNotEmpty) ...[
          _buildRoundSection('Round Robin', roundRobinMatches),
          const SizedBox(height: 24),
        ],
        if (roundOf16Matches.isNotEmpty) ...[
          _buildRoundSection('Round of 16', roundOf16Matches),
          const SizedBox(height: 24),
        ],
        if (quarterFinalMatches.isNotEmpty) ...[
          _buildRoundSection('Quarter Final', quarterFinalMatches),
          const SizedBox(height: 24),
        ],
        if (semiFinalMatches.isNotEmpty) ...[
          _buildRoundSection('Semi Final', semiFinalMatches),
          const SizedBox(height: 24),
        ],
        if (finalMatches.isNotEmpty) ...[
          _buildRoundSection('Final', finalMatches),
        ],
      ],
    );
  }

  Widget _buildRoundSection(String round, List<TennisMatch> matches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _getRoundColor(round),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            round.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _getRoundTextColor(round),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...matches.map((match) => _buildBracketMatchCard(match)),
      ],
    );
  }

  Widget _buildBracketMatchCard(TennisMatch match) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Team names with avatars and set score
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTeamWithAvatars(
                    match.team1,
                    match.winner?.id == match.team1?.id,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    match.scoreDisplay,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _buildTeamWithAvatars(
                    match.team2,
                    match.winner?.id == match.team2?.id,
                    isRightAligned: true,
                  ),
                ),
              ],
            ),

            // Set history
            if (match.setHistoryDisplay.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Sets: ${match.setHistoryDisplay}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],

            // Point history for each set (compact version for bracket)
            if (match.pointHistoryDisplay.isNotEmpty) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  match.pointHistoryDisplay,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],

            // Current set points and scoring buttons
            if (!match.isCompleted &&
                match.team1 != null &&
                match.team2 != null) ...[
              const SizedBox(height: 8),
              // Match settings info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'First to ${match.pointsToWinSet} pts',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${match.team1CurrentPoints}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final wasCompleted = match.isCompleted;
                              setState(() {
                                match.incrementPoint(true);
                                if (match.isCompleted && !wasCompleted) {
                                  currentTournament!.advanceWinner(match);
                                  _triggerConfetti();
                                }
                              });
                              await _speakScore(match);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              minimumSize: const Size(0, 32),
                            ),
                            child: const Text('+1',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${match.team2CurrentPoints}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final wasCompleted = match.isCompleted;
                              setState(() {
                                match.incrementPoint(false);
                                if (match.isCompleted && !wasCompleted) {
                                  currentTournament!.advanceWinner(match);
                                  _triggerConfetti();
                                }
                              });
                              await _speakScore(match);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              minimumSize: const Size(0, 32),
                            ),
                            child: const Text('+1',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Undo and Reset buttons (compact version for bracket)
              if (match.canUndo || match.canReset) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (match.canUndo)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              match.undoLastPoint();
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange[700],
                            side: BorderSide(color: Colors.orange[300]!),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            minimumSize: const Size(0, 28),
                          ),
                          child: const Text('Undo',
                              style: TextStyle(fontSize: 10)),
                        ),
                      ),
                    if (match.canUndo && match.canReset)
                      const SizedBox(width: 4),
                    if (match.canReset)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              match.resetCurrentSet();
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red[700],
                            side: BorderSide(color: Colors.red[300]!),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            minimumSize: const Size(0, 28),
                          ),
                          child: const Text('Reset',
                              style: TextStyle(fontSize: 10)),
                        ),
                      ),
                  ],
                ),
              ],
            ],

            if (match.isCompleted) ...[
              const SizedBox(height: 4),
              Text(
                'Winner: ${match.winner?.name ?? "TBD"}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStandingsTab() {
    final roundRobinMatches = currentTournament!.matches
        .where((m) => m.round == 'Round Robin')
        .toList();
    final completedMatches =
        roundRobinMatches.where((m) => m.isCompleted).toList();

    if (completedMatches.isEmpty) {
      return const Center(
        child: Text('No round-robin matches completed yet.'),
      );
    }

    // Calculate standings using the tournament's method
    final teamStandings = currentTournament!.calculateTeamStandings();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: teamStandings.length,
      itemBuilder: (context, index) {
        final standing = teamStandings[index];
        final team = standing.team;
        final wins = standing.wins;
        final losses = standing.losses;
        final winPercentage = standing.winPercentage;
        final pointsScored = standing.pointsScored;
        final pointsConceded = standing.pointsConceded;
        final pointDifference = standing.pointDifference;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: index < 4 ? Colors.green[100] : Colors.grey[100],
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: index < 4 ? Colors.green[700] : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              team.name,
              style: TextStyle(
                fontWeight: index < 4 ? FontWeight.bold : FontWeight.normal,
                color: index < 4 ? Colors.green[700] : Colors.grey[800],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${wins}W ${losses}L • ${(winPercentage * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Points: $pointsScored-$pointsConceded (${pointDifference >= 0 ? '+' : ''}$pointDifference)',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: index < 4
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'QUALIFIED',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}
