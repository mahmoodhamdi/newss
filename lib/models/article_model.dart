class ArticleModel {
  final String? image;
  final String title;
  final String? description;
  final String? url;
  final String? author;
  final DateTime? publishedAt;
  final String? content;
  final Source source;

  ArticleModel({
    this.image,
    required this.title,
    this.description,
    this.url,
    this.author,
    this.publishedAt,
    this.content,
    required this.source,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      image: json['urlToImage'],
      title: json['title'] ?? '',
      description: json['description'],
      url: json['url'],
      author: json['author'],
      publishedAt: json['publishedAt'] != null 
          ? DateTime.parse(json['publishedAt'])
          : null,
      content: json['content'],
      source: Source.fromJson(json['source'] ?? {}),
    );
  }
}

class Source {
  final String? id;
  final String name;

  Source({
    this.id,
    required this.name,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}
