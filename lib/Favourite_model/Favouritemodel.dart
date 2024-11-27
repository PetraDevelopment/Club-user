class Favouritemodel {
  String? playground_id;
  String? id;
  bool isfav;
  String? img;
  String? playground_name;
  String? userid;

  Favouritemodel({
    this.playground_id,
    this.img,
    this.playground_name,
    this.userid,
    this.id,
    this.isfav = false,
  });
  factory Favouritemodel.fromMap(Map<String, dynamic> map) {
    return Favouritemodel(
      playground_name:'',
      img:'',
      isfav: map['is_favourite'] ?? false,
      id: '',
      playground_id: map['playground_id'],
      userid: map['userid'],

    );
  }
  Map<String, dynamic> toMap() {
    return {

      'is_favourite': isfav,
      'userid': userid,
      'playground_id': playground_id,

    };
  }

  @override
  String toString() {
    return 'AddPlayGroundModel(playgroundName: $playground_name, userid: $userid, playground_id: $playground_id,  img: $img,isfav: $isfav)';
  }
}