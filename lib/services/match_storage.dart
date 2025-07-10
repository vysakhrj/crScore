
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cricket_scorer/models/match.dart';
import 'package:cricket_scorer/models/team.dart';

class MatchStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  Future<File> saveMatch(Match match) async {
    final file = await _localFile('match_${match.id}.json');
    final jsonString = jsonEncode(match.toJson());
    return file.writeAsString(jsonString);
  }

  Future<Match?> loadMatch(String matchId) async {
    try {
      final file = await _localFile('match_$matchId.json');
      final contents = await file.readAsString();
      final json = jsonDecode(contents);
      return Match.fromJson(json);
    } catch (e) {
      // If encountering an error, return null
      return null;
    }
  }

  Future<List<String>> listSavedMatches() async {
    final path = await _localPath;
    final directory = Directory(path);
    final files = directory.listSync();
    List<String> matchIds = [];
    for (var file in files) {
      if (file.path.endsWith('.json') && file.path.contains('match_')) {
        final fileName = file.path.split('/').last;
        matchIds.add(fileName.replaceAll('match_', '').replaceAll('.json', ''));
      }
    }
    return matchIds;
  }

  Future<File> saveTeams(List<Team> teams) async {
    final file = await _localFile('teams.json');
    final jsonString = jsonEncode(teams.map((team) => team.toJson()).toList());
    return file.writeAsString(jsonString);
  }

  Future<List<Team>> loadTeams() async {
    try {
      final file = await _localFile('teams.json');
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((json) => Team.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
