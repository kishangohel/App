import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/models/nft.dart';
import 'package:verifi/repositories/opensea_repository.dart';

class NftsCubit extends Cubit<List<Nft>> {
  final OpenSeaRepository _openSeaRepository;

  NftsCubit(this._openSeaRepository) : super([]);

  Future<void> loadNftsOwnedbyAddress(String address) async {
    List<Nft> nfts = await _openSeaRepository.getAssetsOwnedByAddress(address);
    emit(nfts);
  }
}
