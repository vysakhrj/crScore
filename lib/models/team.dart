import './player.dart';

class Team {
  String id;
  String name;
  List<Player> players;

  Team({required this.id, required this.name, required this.players});

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      players: List<Player>.from(
          (json['players'] as List).map((player) => Player.fromJson(player))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'players': players.map((player) => player.toJson()).toList(),
    };
  }
}
