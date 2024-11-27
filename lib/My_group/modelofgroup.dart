class userDataofgroup {
  // Assuming these are the properties of your User class
  String? UserId;
  String? AdminId;
  String?TeamId;

  // Constructor
  userDataofgroup({this.UserId, this.AdminId, this.TeamId});
  // fromMap method to create a User object from a Map
  factory userDataofgroup.fromMap(Map<String, dynamic> map) {
    return userDataofgroup(
      UserId: map['userId'],
      AdminId: map['AdminId'],
      TeamId:map['TeamId'],

    );
  }
  // toString method to print the User object
  @override
  String toString() {
    return 'User(userid: $UserId, adminid: $AdminId,groupid: $TeamId)';
  }
}