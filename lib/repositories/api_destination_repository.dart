import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import '../models/destination_model.dart';
import 'dto/destination_dto.dart';
import 'query_options.dart';
import '../services/graphql_service.dart';
import 'destination_repository.dart';

class ApiDestinationRepository implements DestinationRepository {
  final GraphQlService _graphQl;

  ApiDestinationRepository({
    required String endpoint,
    String? authToken,
  }) : _graphQl = GraphQlService(endpoint: endpoint, authToken: authToken);

  @override
  Future<List<Destination>> fetchDestinations({
    DestinationQueryOptions? options,
  }) async {
    if (kDebugMode) {
      debugPrint('[GQL] fetchDestinations → variables: ${options?.toVariables()}');
    }

    const query = r'''
      query GetDestinations(
        $search: String
        $category: String
        $sortBy: String
        $sortDirection: String
        $page: Int
        $pageSize: Int
      ) {
        destinations(
          search: $search
          category: $category
          sortBy: $sortBy
          sortDirection: $sortDirection
          page: $page
          pageSize: $pageSize
        ) {
          id
          name
          description
          location
          rating
          price
          images
          activities
          isFeatured
          category
          availableSpots
          discount
          latitude
          longitude
        }
      }
    ''';

    final result = await _graphQl.query(
      operationName: 'GetDestinations',
      document: query,
      variables: options?.toVariables() ?? const {},
    );

    if (kDebugMode) {
      debugPrint('[GQL] GetDestinations raw data keys: ${result.data?.keys.toList()}');
      debugPrint('[GQL] GetDestinations exception: ${result.exception}');
    }

    final rawList = result.data?['destinations'] as List<dynamic>?;

    if (kDebugMode) {
      debugPrint('[GQL] destinations rawList type: ${rawList?.runtimeType}  count: ${rawList?.length}');
      if (rawList != null && rawList.isNotEmpty) {
        debugPrint('[GQL] first item: ${rawList.first}');
      }
    }

    if (rawList == null) {
      return [];
    }

    final destinations = rawList
        .whereType<Map<String, dynamic>>()
        .map(DestinationDto.fromJson)
        .map((dto) => dto.toDomain())
        .toList(growable: false);

    if (kDebugMode) {
      debugPrint('[GQL] parsed ${destinations.length} destinations');
      if (destinations.isNotEmpty) {
        final d = destinations.first;
        debugPrint('[GQL] first destination: ${d.name}, images: ${d.images.length}, activities: ${d.activities.length}');
      }
    }

    return destinations;
  }
}
