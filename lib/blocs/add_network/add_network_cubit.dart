import 'package:bloc/bloc.dart';
import 'package:verifi/blocs/add_network/add_network.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/repositories/repositories.dart';

class AddNetworkCubit extends Cubit<AddNetworkState> {
  final WifiRepository _wifiRemoteRepository;

  AddNetworkCubit(this._wifiRemoteRepository)
      : super(AddNetworkState.addNetworkEmpty);

  void addNetwork(WifiDetails wifiDetails) async {
    emit(AddNetworkState.addNetworkSubmitting);
    try {
      await _wifiRemoteRepository.addWifiMarker(wifiDetails);
    } catch (e) {
      emit(AddNetworkState.addNetworkError);
    }
  }
}
