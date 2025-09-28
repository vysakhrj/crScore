import 'package:cricket_scorer/models/player.dart';
import 'package:cricket_scorer/models/team.dart';
import 'package:cricket_scorer/services/match_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CreateTeamScreen extends StatefulWidget {
  @override
  _CreateTeamScreenState createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _teamNameController = TextEditingController();
  final _playerSearchController = TextEditingController();
  final _newPlayerNameController = TextEditingController();
  List<Player> selectedPlayers = [];
  List<Player> allPlayers = [];
  List<Player> filteredPlayers = [];
  final MatchStorage _matchStorage = MatchStorage();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadAllPlayers();
  }

  Future<void> _loadAllPlayers() async {
    final teams = await _matchStorage.loadTeams();
    final allPlayersFromTeams = <Player>[];

    for (final team in teams) {
      allPlayersFromTeams.addAll(team.players);
    }

    // Remove duplicates based on player ID
    final uniquePlayers = <String, Player>{};
    for (final player in allPlayersFromTeams) {
      uniquePlayers[player.id] = player;
    }

    setState(() {
      allPlayers = uniquePlayers.values.toList();
      filteredPlayers = allPlayers;
    });
  }

  void _filterPlayers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredPlayers = allPlayers;
      } else {
        filteredPlayers = allPlayers
            .where((player) =>
                player.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _addExistingPlayer(Player player) {
    if (!selectedPlayers.any((p) => p.id == player.id)) {
      setState(() {
        selectedPlayers.add(player);
      });
    }
    _playerSearchController.clear();
    _filterPlayers('');
  }

  void _addNewPlayer() {
    if (_newPlayerNameController.text.trim().isEmpty) return;

    final newPlayer = Player(
      id: const Uuid().v4(),
      name: _newPlayerNameController.text.trim(),
    );

    setState(() {
      selectedPlayers.add(newPlayer);
    });

    _newPlayerNameController.clear();
    Navigator.of(context).pop();
  }

  void _removePlayer(Player player) {
    setState(() {
      selectedPlayers.removeWhere((p) => p.id == player.id);
    });
  }

  void _showAddPlayerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Player'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search existing players
                    TextField(
                      controller: _playerSearchController,
                      decoration: const InputDecoration(
                        labelText: 'Search existing players',
                        hintText: 'Type to search...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          _filterPlayers(value);
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Existing players list
                    if (filteredPlayers.isNotEmpty)
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          itemCount: filteredPlayers.length,
                          itemBuilder: (context, index) {
                            final player = filteredPlayers[index];
                            final isSelected =
                                selectedPlayers.any((p) => p.id == player.id);

                            return ListTile(
                              title: Text(player.name),
                              subtitle: Text(
                                '${player.runs} runs • ${player.wickets} wkts',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check, color: Colors.green)
                                  : const Icon(Icons.add),
                              onTap: isSelected
                                  ? null
                                  : () {
                                      _addExistingPlayer(player);
                                      Navigator.of(context).pop();
                                    },
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Add new player section
                    const Text(
                      'Or add a new player:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _newPlayerNameController,
                      decoration: const InputDecoration(
                        labelText: 'New player name',
                        hintText: 'Enter player name',
                      ),
                      onSubmitted: (value) => _addNewPlayer(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _playerSearchController.clear();
                    _newPlayerNameController.clear();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: _addNewPlayer,
                  child: const Text('Add New'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'CREATE TEAM',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Team Name
            TextField(
              controller: _teamNameController,
              decoration: const InputDecoration(
                labelText: 'Team Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Players Section Header
            Row(
              children: [
                const Text(
                  'PLAYERS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const Spacer(),
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
            const SizedBox(height: 16),

            // Add Player Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _showAddPlayerDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Player'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black26),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Selected Players List
            Expanded(
              child: selectedPlayers.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      itemCount: selectedPlayers.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        indent: 10,
                        endIndent: 10,
                      ),
                      itemBuilder: (context, index) {
                        final player = selectedPlayers[index];
                        return Dismissible(
                          key: Key(player.id),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            _removePlayer(player);
                          },
                          child: ListTile(
                            title: Text(player.name),
                            subtitle: Text(
                              '${player.runs} runs • ${player.wickets} wkts',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red,
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 16),

            // Save Team Button
            buildFlatButton(
              'SAVE TEAM',
              selectedPlayers.isNotEmpty &&
                      _teamNameController.text.trim().isNotEmpty
                  ? () {
                      final team = Team(
                        id: const Uuid().v4(),
                        name: _teamNameController.text.trim(),
                        players: selectedPlayers,
                      );
                      Navigator.pop(context, team);
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_add_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No players added yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add players to your team to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFlatButton(String text, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: onPressed != null ? Colors.black26 : Colors.grey[300]!,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: onPressed != null ? Colors.black : Colors.grey[400],
          ),
        ),
      ),
    );
  }
}
