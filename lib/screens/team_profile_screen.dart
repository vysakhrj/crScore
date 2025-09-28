import 'package:cricket_scorer/models/team.dart';
import 'package:cricket_scorer/models/player.dart';
import 'package:cricket_scorer/screens/player_profile_screen.dart';
import 'package:cricket_scorer/services/match_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TeamProfileScreen extends StatefulWidget {
  final Team team;

  TeamProfileScreen({required this.team});

  @override
  State<TeamProfileScreen> createState() => _TeamProfileScreenState();
}

class _TeamProfileScreenState extends State<TeamProfileScreen> {
  late Team _team;
  final MatchStorage _matchStorage = MatchStorage();
  final TextEditingController _playerNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _team = widget.team;
  }

  Future<void> _addPlayer() async {
    if (_playerNameController.text.trim().isEmpty) return;

    setState(() {
      _team.players.add(Player(
        id: const Uuid().v4(),
        name: _playerNameController.text.trim(),
      ));
    });

    _playerNameController.clear();
    await _saveTeam();
  }

  Future<void> _removePlayer(Player player) async {
    setState(() {
      _team.players.removeWhere((p) => p.id == player.id);
    });
    await _saveTeam();
  }

  Future<void> _saveTeam() async {
    final teams = await _matchStorage.loadTeams();
    final teamIndex = teams.indexWhere((t) => t.id == _team.id);

    if (teamIndex != -1) {
      teams[teamIndex] = _team;
    }

    await _matchStorage.saveTeams(teams);
  }

  void _showAddPlayerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Player'),
          content: TextField(
            controller: _playerNameController,
            decoration: const InputDecoration(
              labelText: 'Player Name',
              hintText: 'Enter player name',
            ),
            autofocus: true,
            onSubmitted: (value) {
              Navigator.of(context).pop();
              _addPlayer();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _playerNameController.clear();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addPlayer();
              },
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
      appBar: AppBar(
        title: Text(
          'TEAM PROFILE',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_team.name}',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_team.players.length} players',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  'PLAYERS',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _showAddPlayerDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Player'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            Expanded(
              child: _team.players.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      itemCount: _team.players.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        indent: 10,
                        endIndent: 10,
                      ),
                      itemBuilder: (context, index) {
                        final player = _team.players[index];
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
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Remove Player'),
                                  content: Text(
                                      'Are you sure you want to remove ${player.name}?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Remove'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
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
                              Icons.arrow_forward_ios,
                              size: 12,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PlayerProfileScreen(player: player)),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      // floatingActionButton: _team.players.isEmpty
      //     ? null
      //     : FloatingActionButton(
      //         onPressed: _showAddPlayerDialog,
      //         backgroundColor: Colors.black,
      //         foregroundColor: Colors.white,
      //         child: const Icon(Icons.add),
      //       ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No players yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first player to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddPlayerDialog,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Player'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
