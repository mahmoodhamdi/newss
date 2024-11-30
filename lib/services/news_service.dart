import 'package:dio/dio.dart';
import 'package:news_apps/models/article_model.dart';

class NewsService {
  final Dio dio;
  final String _baseUrl = 'https://newsapi.org/v2';
  final String _apiKey = '3c88955c487e4d9db668f011dd85e737';

  NewsService(this.dio);

  Future<List<ArticleModel>> getTopHeadlines({
    String? category,
    String? country = 'us',
    String? q,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'apiKey': _apiKey,
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      if (category != null) queryParams['category'] = category;
      if (country != null) queryParams['country'] = country;
      if (q != null) queryParams['q'] = q;

      final response = await dio.get(
        '$_baseUrl/top-headlines',
        queryParameters: queryParams,
      );

      return _parseArticlesResponse(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ArticleModel>> searchNews({
    required String query,
    String? language,
    String? sortBy,
    DateTime? from,
    DateTime? to,
    List<String>? domains,
    List<String>? excludeDomains,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'apiKey': _apiKey,
        'q': query,
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      if (language != null) queryParams['language'] = language;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (from != null) queryParams['from'] = from.toIso8601String();
      if (to != null) queryParams['to'] = to.toIso8601String();
      if (domains?.isNotEmpty == true) {
        queryParams['domains'] = domains!.join(',');
      }
      if (excludeDomains?.isNotEmpty == true) {
        queryParams['excludeDomains'] = excludeDomains!.join(',');
      }

      final response = await dio.get(
        '$_baseUrl/everything',
        queryParameters: queryParams,
      );

      return _parseArticlesResponse(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Source>> getSources({
    String? category,
    String? language,
    String? country,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'apiKey': _apiKey,
      };

      if (category != null) queryParams['category'] = category;
      if (language != null) queryParams['language'] = language;
      if (country != null) queryParams['country'] = country;

      final response = await dio.get(
        '$_baseUrl/top-headlines/sources',
        queryParameters: queryParams,
      );

      final List<dynamic> sources = response.data['sources'];
      return sources.map((source) => Source.fromJson(source)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  List<ArticleModel> _parseArticlesResponse(Map<String, dynamic> data) {
    final List<dynamic> articles = data['articles'];
    return articles.map((article) => ArticleModel.fromJson(article)).toList();
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final response = error.response;
      if (response?.data != null) {
        return Exception(response!.data['message'] ?? 'An error occurred');
      }
    }
    return Exception('Failed to fetch news');
  }
}

// Constants for the NewsAPI
class NewsApiConstants {
  static const List<String> categories = [
    'business',
    'entertainment',
    'general',
    'health',
    'science',
    'sports',
    'technology'
  ];

  static const List<String> languages = [
    'ar', 'de', 'en', 'es', 'fr', 'he', 'it', 'nl',
    'no', 'pt', 'ru', 'sv', 'ud', 'zh'
  ];

  static const List<String> sortOptions = [
    'relevancy',
    'popularity',
    'publishedAt'
  ];
}
