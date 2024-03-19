// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Article {
  final String? title;
  final String? description;
  final String? urlToImage;
  final String? author;
  final String? publishedAt;
  Article({
    this.title,
    this.description,
    this.urlToImage,
    this.author,
    this.publishedAt,
  });

  Article copyWith({
    String? title,
    String? description,
    String? urlToImage,
    String? author,
    String? publishedAt,
  }) {
    return Article(
      title: title ?? this.title,
      description: description ?? this.description,
      urlToImage: urlToImage ?? this.urlToImage,
      author: author ?? this.author,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'urlToImage': urlToImage,
      'author': author,
      'publishedAt': publishedAt,
    };
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      title: map['title'] != null ? map['title'] as String : null,
      description: map['description'] != null ? map['description'] as String : null,
      urlToImage: map['urlToImage'] != null ? map['urlToImage'] as String : null,
      author: map['author'] != null ? map['author'] as String : null,
      publishedAt: map['publishedAt'] != null ? map['publishedAt'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Article.fromJson(String source) => Article.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Article(title: $title, description: $description, urlToImage: $urlToImage, author: $author, publishedAt: $publishedAt)';
  }

  @override
  bool operator ==(covariant Article other) {
    if (identical(this, other)) return true;
  
    return 
      other.title == title &&
      other.description == description &&
      other.urlToImage == urlToImage &&
      other.author == author &&
      other.publishedAt == publishedAt;
  }

  @override
  int get hashCode {
    return title.hashCode ^
      description.hashCode ^
      urlToImage.hashCode ^
      author.hashCode ^
      publishedAt.hashCode;
  }
}
