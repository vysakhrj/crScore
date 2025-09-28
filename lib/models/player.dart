class Player {
  String id;
  String name;

  // Batting statistics
  int runs = 0;
  int ballsFaced = 0;
  int fours = 0;
  int sixes = 0;
  int notOuts = 0;
  int dismissals = 0;

  // Bowling statistics
  int wickets = 0;
  int oversBowled = 0;
  int ballsBowled = 0;
  int runsConceded = 0;
  int maidens = 0;

  // Calculated statistics
  double get battingAverage {
    if (dismissals == 0) return runs.toDouble();
    return runs / dismissals.toDouble();
  }

  double get battingStrikeRate {
    if (ballsFaced == 0) return 0.0;
    return (runs / ballsFaced.toDouble()) * 100;
  }

  double get bowlingAverage {
    if (wickets == 0) return 0.0;
    return runsConceded / wickets.toDouble();
  }

  double get bowlingStrikeRate {
    if (wickets == 0) return 0.0;
    return ballsBowled / wickets.toDouble();
  }

  double get economyRate {
    if (oversBowled == 0) return 0.0;
    return runsConceded / oversBowled.toDouble();
  }

  Player({
    required this.id,
    required this.name,
    this.runs = 0,
    this.ballsFaced = 0,
    this.fours = 0,
    this.sixes = 0,
    this.notOuts = 0,
    this.dismissals = 0,
    this.wickets = 0,
    this.oversBowled = 0,
    this.ballsBowled = 0,
    this.runsConceded = 0,
    this.maidens = 0,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      runs: json['runs'] ?? 0,
      ballsFaced: json['ballsFaced'] ?? 0,
      fours: json['fours'] ?? 0,
      sixes: json['sixes'] ?? 0,
      notOuts: json['notOuts'] ?? 0,
      dismissals: json['dismissals'] ?? 0,
      wickets: json['wickets'] ?? 0,
      oversBowled: json['oversBowled'] ?? 0,
      ballsBowled: json['ballsBowled'] ?? 0,
      runsConceded: json['runsConceded'] ?? 0,
      maidens: json['maidens'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'runs': runs,
      'ballsFaced': ballsFaced,
      'fours': fours,
      'sixes': sixes,
      'notOuts': notOuts,
      'dismissals': dismissals,
      'wickets': wickets,
      'oversBowled': oversBowled,
      'ballsBowled': ballsBowled,
      'runsConceded': runsConceded,
      'maidens': maidens,
    };
  }

  // Method to update batting stats
  void updateBattingStats(int runsScored, bool isDismissed) {
    runs += runsScored;
    ballsFaced += 1;

    if (runsScored == 4) fours += 1;
    if (runsScored == 6) sixes += 1;

    if (isDismissed) {
      dismissals += 1;
    }
  }

  // Method to update bowling stats
  void updateBowlingStats(int runsGiven, bool isWicket, bool isMaiden) {
    runsConceded += runsGiven;
    ballsBowled += 1;

    if (isWicket) wickets += 1;
    if (isMaiden) maidens += 1;

    // Update overs (every 6 balls = 1 over)
    if (ballsBowled % 6 == 0) {
      oversBowled = ballsBowled ~/ 6;
    }
  }

  // Method to get formatted overs (e.g., 5.3 for 5 overs 3 balls)
  String get formattedOvers {
    int fullOvers = ballsBowled ~/ 6;
    int remainingBalls = ballsBowled % 6;
    return remainingBalls == 0
        ? fullOvers.toString()
        : '$fullOvers.$remainingBalls';
  }
}
