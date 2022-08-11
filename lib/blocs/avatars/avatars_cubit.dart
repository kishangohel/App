import 'package:bloc/bloc.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/models/pfp.dart';

class AvatarCubit extends Cubit<List<Pfp>> {
  AvatarCubit() : super([]);

  void loadAvatars() {
    final avatars = <Pfp>[];
    for (var i = 1; i <= 24; i++) {
      final asset =
          "asset/profile_avatars/People-${i.toString().padLeft(2, '0')}";
      final pfp = Pfp(id: i, image: asset);
      avatars.add(pfp);
    }
    emit(avatars);
  }
}
