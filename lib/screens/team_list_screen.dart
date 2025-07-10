
import 'package:cricket_scorer/models/team.dart';
import 'package:cricket_scorer/screens/team_profile_screen.dart';
import 'package:flutter/material.dart';

class TeamListScreen extends StatefulWidget {
  final List<Team> teams;

  TeamListScreen({required this.teams});

  @override
  _TeamListScreenState createState() => _TeamListScreenState();
}

class _TeamListScreenState extends State<TeamListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teams'),
      ),
      body: ListView.builder(
        itemCount: widget.teams.length,
        itemBuilder: (context, index) {
          final team = widget.teams[index];
          return ListTile(
            title: Text(team.name),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TeamProfileScreen(team: team)),
              );
            },
          );
        },
      ),
    );
  }
}
