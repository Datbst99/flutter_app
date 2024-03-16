// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Article {
  final String? title;
  final String? description;
  final String? urlToImage;
  Article({
    this.title,
    this.description,
    this.urlToImage,
  });

  Article copyWith({
    String? title,
    String? description,
    String? urlToImage,
  }) {
    return Article(
      title: title ?? this.title,
      description: description ?? this.description,
      urlToImage: urlToImage ?? this.urlToImage,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'urlToImage': urlToImage,
    };
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      title: map['title'] != null ? map['title'] as String : null,
      description: map['description'] != null ? map['description'] as String : null,
      urlToImage: map['urlToImage'] != null ? map['urlToImage'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Article.fromJson(String source) => Article.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Article(title: $title, description: $description, urlToImage: $urlToImage)';

  @override
  bool operator ==(covariant Article other) {
    if (identical(this, other)) return true;
  
    return 
      other.title == title &&
      other.description == description &&
      other.urlToImage == urlToImage;
  }

  @override
  int get hashCode => title.hashCode ^ description.hashCode ^ urlToImage.hashCode;
}
