import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../configuration/sharepref.dart';
import '../model/org_list_model.dart';

final orgListProvider =
    FutureProvider.autoDispose<List<OrganisationListModel>>((ref) async {
  final qp = {
    "per_page": "30",
    "page": "1",
  };
  final response = await http.get(
    Uri.parse(
      "https://api.github.com/user/orgs"
    ).replace(
      queryParameters: qp,
    ),
    headers: {
      "Authorization": "Bearer ${Sharedpref.getAccessToken}",
      "Accept": "application/vnd.github+json"
    },
  );

  if (response.statusCode == 200) {
    log(response.body);
    return organisationListModelFromJson(response.body);
  } else {
    log(response.body);
    throw Exception("Failed to connect");
  }
});
