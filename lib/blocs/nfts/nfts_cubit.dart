import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/models/nft.dart';
import 'package:verifi/repositories/nftport_repository.dart';

class NftsCubit extends Cubit<List<Nft>> {
  final NftPortRepository _nftPortRepository;

  NftsCubit(this._nftPortRepository) : super([]);

  Future<void> loadNftsOwnedbyAddress(String address) async {
    List<Nft> nfts = await _nftPortRepository.getAssetsOwnedByAddress(address);
    emit(nfts);
  }
}
