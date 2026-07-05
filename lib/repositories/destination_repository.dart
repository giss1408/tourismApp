import '../models/destination_model.dart';
import 'query_options.dart';

abstract class DestinationRepository {
  Future<List<Destination>> fetchDestinations({
    DestinationQueryOptions? options,
  });
}
