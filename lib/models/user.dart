import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String username;
  final String displayname;
  final String id;
  final String email;
  final String bio;
  final String photoUrl;

  User(this.username,this.displayname,this.id,this.email,this.bio,this.photoUrl);

  factory User.fromDocument(DocumentSnapshot doc){
    return User(doc['name'], doc['displayName'], doc['id'], doc['email'], doc['bio'], doc['photo']);
  }

  @override
  String toString() {
    return 'User{name: $username, displayName: $displayname, id: $id, email: $email, bio: $bio, photo: $photoUrl}';
  }
}
