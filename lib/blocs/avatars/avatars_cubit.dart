import 'package:bloc/bloc.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/models/pfp.dart';

class AvatarCubit extends Cubit<List<Pfp>> {
  AvatarCubit() : super([]);

  void loadAvatars() {
    final avatars = <Pfp>[];
    for (var i = 1; i <= 24; i++) {
      final id = i.toString().padLeft(2, '0');
      final asset = "asset/profile_avatars/People-$id";
      final pfp = Pfp(id: "avatar-$id", image: asset, type: PfpTypes.image);
      avatars.add(pfp);
    }
    emit(avatars);
  }
}
