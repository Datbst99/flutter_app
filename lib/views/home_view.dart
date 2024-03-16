
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app_bt/models/article.dart';
import 'package:http/http.dart' as http;

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("News app"),
      ),
      body: FutureBuilder(
        future: getArticles(), 
        builder:(context, snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              final List<Article> articles = snapshot.data ?? [];
              return ListView.builder(
                itemCount: articles.length,
                itemBuilder:(context, index) {
                  return Container(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      children: [
                        Image.network(
                          articles.elementAt(index).urlToImage ?? "",
                          width: 80,
                          height: 80,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(color: Colors.lightBlue, width: 80, height: 80,);
                          },
                        ),
                        
                        Expanded(child: Text(articles.elementAt(index).title ?? ""))
                      ],
                    ),
                  );
                },
              );
          }
        },
      ),
    );
  }

  Future<List<Article>> getArticles() async {
    const url = "https://newsapi.org/v2/everything?q=tesla&from=2024-02-16&sortBy=publishedAt&apiKey=61b5ccfa18e94315be008a4d8c86201b";
    final response = await http.get(Uri.parse(url));
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final List<Article> articles = [];
    for(final item in body['articles']) {
      final article = Article.fromMap(item);
      articles.add(article);
    }
    return articles;
  }
}