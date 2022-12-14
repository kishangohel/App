import 'package:flutter_map_supercluster/flutter_map_supercluster.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';

class UserCluster extends ClusterDataBase {
  static const maxUsersInSample = 5;
  final List<UserProfile> userSample;

  UserCluster({required this.userSample});

  UserCluster.fromUser(UserProfile user) : userSample = [user];

  @override
  UserCluster combine(covariant UserCluster data) {
    if (userSample.length < maxUsersInSample) {
      return UserCluster(
        userSample: List.from(userSample)
          ..addAll(
            data.userSample.take(maxUsersInSample - userSample.length),
          ),
      );
    } else {
      return UserCluster(userSample: userSample);
    }
  }
}
