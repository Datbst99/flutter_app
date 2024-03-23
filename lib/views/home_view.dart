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
        title: const Text('Trang chủ bài viết'),
      ),
      body: FutureBuilder(
        future: getArticles(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              final List<Article> articles = snapshot.data ?? [];
              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(15),
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25))
                        ),
                        hintText: 'Search title news',
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  articles.elementAt(index).urlToImage ?? "",
                                  width: 100,
                                  height: 110,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.lightBlue,
                                      width: 100,
                                      height: 150,
                                    );
                                  },
                                ),
                              ),
                              Expanded(
                                  child: Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      articles.elementAt(index).title ?? "",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      articles.elementAt(index).author ?? "",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey),
                                    ),
                                    Text(
                                      articles.elementAt(index).publishedAt ??
                                          "",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey),
                                    )
                                  ],
                                ),
                              ))
                            ],
                          ),
                        );
                      },
                    ),
                  )
                ],
              );
          }
        },
      ),
      bottomNavigationBar:
          BottomNavigationBar(items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: Icon(Icons.window_sharp), label: "Trang chủ"),
        BottomNavigationBarItem(icon: Icon(Icons.heart_broken), label: "Detail")
      ]),
    );
  }

  Future<List<Article>> getArticles() async {
    const url =
        "https://newsapi.org/v2/everything?q=cuoc&from=2024-02-23&sortBy=publishedAt&apiKey=61b5ccfa18e94315be008a4d8c86201b";
    final response = await http.get(Uri.parse(url));
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final List<Article> articles = [];
    for (final item in body['articles']) {
      final article = Article.fromMap(item);
      articles.add(article);
    }
    return articles;
  }
}
