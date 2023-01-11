import 'package:flutter_map_supercluster/flutter_map_supercluster.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';

class UserProfileCluster extends ClusterDataBase {
  final List<UserProfile> userProfiles;

  UserProfileCluster({required this.userProfiles});

  UserProfileCluster.fromUser(UserProfile user) : userProfiles = [user];

  @override
  UserProfileCluster combine(UserProfileCluster data) {
    return UserProfileCluster(
      userProfiles: List.from(userProfiles)..addAll(data.userProfiles),
    );
  }
}
