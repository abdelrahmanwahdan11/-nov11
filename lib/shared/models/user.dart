class User {
  User({this.id, this.name, this.guest = false});

  final String? id;
  final String? name;
  final bool guest;
}
