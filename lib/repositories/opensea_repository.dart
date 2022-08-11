import 'dart:convert';

import 'package:verifi/models/models.dart';
import 'package:http/http.dart' as http;

class OpenSeaRepository {
  // testnet address - 0x062d6d315e6c8aa196b9072d749e3f3f3579fdd0
  // testnet api assets - https://testnets-api.opensea.io/api/v1/assets
  // example - https://testnets-api.opensea.io/api/v1/assets?owner=0x062d6d315e6c8aa196b9072d749e3f3f3579fdd0&order_direction=desc&offset=0&limit=20&include_orders=false
  final Uri _openSeaUri;

  OpenSeaRepository({
    bool useTestNet = false,
  }) : _openSeaUri = Uri(
          scheme: 'https',
          host: useTestNet ? 'testnets-api.opensea.io' : 'api.opensea.io',
          path: 'api/v1',
        );

  Future<List<Pfp>> getAssetsOwnedByAddress(String address) async {
    List<Pfp> nfts = [];
    Uri uri = _openSeaUri.replace(path: 'api/v1/assets');
    final queryParams = {
      "owner": address,
      // most valuable NFTs listed first
      "order_by": "sale_price",
      "order_direction": "desc",
      "include_orders": "false",
    };
    uri = uri.replace(queryParameters: queryParams);
    final response = await http.get(uri);
    final assets = jsonDecode(response.body)["assets"];
    for (Map<String, dynamic> asset in assets) {
      Pfp? nft = Pfp.fromOpenSeaResponse(asset);
      if (nft != null) nfts.add(nft);
    }
    return nfts;
  }
}
