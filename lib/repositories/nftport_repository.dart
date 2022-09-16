import 'dart:convert';

import 'package:verifi/models/models.dart';
import 'package:http/http.dart' as http;

class NftPortRepository {
  Uri _uri;
  final Map<String, String> _headers;

  NftPortRepository()
      : _uri = Uri(
          scheme: 'https',
          host: 'api.nftport.xyz',
          path: 'v0',
        ),
        _headers = {
          "Authorization": "433c5984-c14a-44d0-bde3-cd10ccc5dee2",
          "Content-Type": "application/json",
        };

  Future<List<Pfp>> getAssetsOwnedByAddress(String address) async {
    List<Pfp> nfts = [];
    final queryParams = {
      "chain": "ethereum",
      "include": "metadata",
    };
    _uri = _uri.replace(
      path: 'v0/accounts/$address',
      queryParameters: queryParams,
    );
    final response = await http.get(_uri, headers: _headers);
    final assets = jsonDecode(response.body)['nfts'];
    for (Map<String, dynamic> asset in assets) {
      Pfp? nft = Pfp.fromNftPortResponse(asset);
      // Only support images for now (not vectors or videos)
      if (nft != null && nft.type == PfpTypes.image) nfts.add(nft);
    }
    return nfts;
  }
}
