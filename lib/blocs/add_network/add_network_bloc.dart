import 'package:bloc/bloc.dart';
import 'package:verifi/blocs/add_network/add_network.dart';
import 'package:verifi/repositories/repositories.dart';

class AddNetworkBloc extends Bloc<AddNetworkEvent, AddNetworkState> {
  final WifiRepository _wifiRemoteRepository;

  AddNetworkBloc(this._wifiRemoteRepository)
      : super(AddNetworkState.addNetworkEmpty) {
    on<AddNetworkSubmit>(_onAddNetworkSubmit);
    on<AddNetworkError>(_onAddNetworkError);
  }

  void _onAddNetworkSubmit(
      AddNetworkSubmit event, Emitter<AddNetworkState> emit) {
    emit(AddNetworkState.addNetworkSubmitting);
    _wifiRemoteRepository.addWifiMarker(event.wifiDetails);
  }

  void _onAddNetworkError(
      AddNetworkError event, Emitter<AddNetworkState> emit) {
    emit(AddNetworkState.addNetworkError);
  }
}
