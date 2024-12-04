class userDataofgroup {
  String? UserId;
  String? AdminId;
  String?TeamId;
  userDataofgroup({this.UserId, this.AdminId, this.TeamId});
  factory userDataofgroup.fromMap(Map<String, dynamic> map) {
    return userDataofgroup(
      UserId: map['userId'],
      AdminId: map['AdminId'],
      TeamId:map['TeamId'],

    );
  }
  @override
  String toString() {
    return 'User(userid: $UserId, adminid: $AdminId,groupid: $TeamId)';
  }
}