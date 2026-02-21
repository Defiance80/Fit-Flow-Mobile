import 'package:fitflow/core/api/api_client.dart';
import 'package:fitflow/core/api/api_params.dart';
import 'package:fitflow/features/search/models/search_suggestion_model.dart';

class SearchSuggestionRepository {
  Future<SearchSuggestionDataModel> fetchSuggestions({
    required String query,
  }) async {
    final Map<String, dynamic> response = await Api.get(
      Apis.getSearchSuggestions,
      data: {ApiParams.query: query},
    );
    return SearchSuggestionDataModel.fromJson(response[ApiParams.data] as Map<String, dynamic>);
  }
}