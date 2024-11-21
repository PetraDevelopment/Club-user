class Rate_fetched {
  String?PlayGroundName;
  String?PlayGroundimg;
  String? userid;
  String? playgroundIdstars;
  List<bool>? rate;

  Rate_fetched({
   this.PlayGroundimg,
    this.PlayGroundName,
    this.userid,
    this.playgroundIdstars,
    this.rate,
  });

  // Factory constructor to create the model from a Map
  factory Rate_fetched.fromMap(Map<String, dynamic> map) {
    return Rate_fetched(
      PlayGroundName:'',
      PlayGroundimg:'',

      userid: map['userid'],
      playgroundIdstars: map['playground_idstars'] ?? '',
      rate: List<bool>.from(map['rate'] ?? []), // Convert to a list of booleans
    );
  }

  // Method to calculate the overall rating score
  int get totalRating => rate?.where((r) => r).length ?? 0;

  // Method to convert the model to a Map
  Map<String, dynamic> toMap() {
    return {
      'userid': userid,
      'playground_idstars': playgroundIdstars,
      'rate': rate,
    };
  }

  @override
  String toString() {
    return 'Ratemodel(userid: $userid,  playground_id: $playgroundIdstars, totalRating: $totalRating)';
  }
}


