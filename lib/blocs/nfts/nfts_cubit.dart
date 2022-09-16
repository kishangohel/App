import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/models/pfp.dart';
import 'package:verifi/repositories/nftport_repository.dart';

class NftsCubit extends Cubit<List<Pfp>> {
  final NftPortRepository _nftPortRepository;

  NftsCubit(this._nftPortRepository) : super([]);

  Future<void> loadNftsOwnedbyAddress(String address) async {
    List<Pfp> nfts = await _nftPortRepository.getAssetsOwnedByAddress(address);
    emit(nfts);
  }
}
