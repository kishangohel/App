import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/models/pfp.dart';
import 'package:verifi/repositories/opensea_repository.dart';

class NftsCubit extends Cubit<List<Pfp>> {
  final OpenSeaRepository _openSeaRepository;

  NftsCubit(this._openSeaRepository) : super([]);

  Future<void> loadNftsOwnedbyAddress(String address) async {
    List<Pfp> nfts = await _openSeaRepository.getAssetsOwnedByAddress(address);
    emit(nfts);
  }
}
