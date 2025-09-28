import 'package:cricket_scorer/models/team.dart';
import 'package:cricket_scorer/screens/team_profile_screen.dart';
import 'package:flutter/material.dart';

class TeamListScreen extends StatefulWidget {
  final List<Team> teams;

  const TeamListScreen({super.key, required this.teams});

  @override
  State<TeamListScreen> createState() => _TeamListScreenState();
}

class _TeamListScreenState extends State<TeamListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TEAMS',
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
      body: ListView.separated(
        itemCount: widget.teams.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          indent: 10,
          endIndent: 10,
        ),
        itemBuilder: (context, index) {
          final team = widget.teams[index];
          return ListTile(
            title: Text(team.name),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 12,
            ),
            subtitle: Text(
              '${team.players.length} players',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TeamProfileScreen(team: team)),
              );
            },
          );
        },
      ),
    );
  }
}
