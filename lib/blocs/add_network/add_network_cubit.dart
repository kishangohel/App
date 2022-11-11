import 'package:bloc/bloc.dart';
import 'package:verifi/blocs/add_network/add_network.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/repositories/repositories.dart';

class AddNetworkCubit extends Cubit<AddNetworkState> {
  final WifiRepository _wifiRepository;

  AddNetworkCubit(this._wifiRepository)
      : super(AddNetworkState.addNetworkEmpty);

  Future<void> addNetwork(
    String ssid,
    String? password,
    Place place,
    String userId,
  ) async {
    emit(AddNetworkState.addNetworkSubmitting);
    await _wifiRepository.addNewAccessPoint(
      ssid,
      password,
      place,
      userId,
    );
    emit(AddNetworkState.addNetworkSubmitted);
  }

  Future<void> addValidationEvent(
    String userId,
    String accessPointId,
  ) async =>
      _wifiRepository.networkValidatedByUser(accessPointId, userId);
}
