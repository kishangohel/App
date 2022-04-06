import 'package:formz/formz.dart';
import 'package:verifi/models/username.dart';

class Profile {
  final Username username;
  final String? photoPath;
  final FormzStatus status;

  const Profile({
    this.username = const Username.pure(),
    this.photoPath,
    this.status = FormzStatus.pure,
    //this.userBounties,
  });

  Profile copyWith({
    Username? username,
    String? photoPath,
    FormzStatus? status,
    String? error,
  }) {
    return Profile(
      username: username ?? this.username,
      photoPath: photoPath ?? this.photoPath,
      status: status ?? this.status,
    );
  }
}
