import 'package:expert_connect/src/article/widget/about_article_widget.dart';
import 'package:expert_connect/src/models/article_vendor_list.dart';
import 'package:flutter/material.dart';

class AboutArticleScreen extends StatelessWidget {
  final ArticleVendorList article;
  const AboutArticleScreen({super.key,required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          AboutArticleWidget.appBar(article: article),
          AboutArticleWidget.showProfile(article: article),
          AboutArticleWidget.articleContent(article: article)
        ],
      ),
    );
  }
}
