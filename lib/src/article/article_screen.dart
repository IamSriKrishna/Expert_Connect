// ignore_for_file: deprecated_member_use

import 'package:expert_connect/src/article/bloc/article_bloc.dart';
import 'package:expert_connect/src/article/repo/article_repo.dart';
import 'package:expert_connect/src/article/widget/article_widgets.dart';
import 'package:expert_connect/src/home/bloc/home_bloc.dart';
import 'package:expert_connect/src/home/repo/home_repo.dart';
import 'package:expert_connect/src/models/article_vendor_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArticleScreen extends StatelessWidget {
  const ArticleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ArticleBloc(ArticleRepoImpl(), HomeRepoImpl())
            ..add(GetArticleVendorList()),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return BlocBuilder<ArticleBloc, ArticleState>(
            builder: (context, state) {
              final article = state.articleVendorList
                  .where((e) => e.status.toLowerCase() == "published")
                  .toList();
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ArticleBloc>().add(GetArticleVendorList());
                },
                child: Scaffold(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  body: CustomScrollView(
                    physics: AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      ArticleWidgets.appBar(),
                      if (state.articleStatus == ArticleVendorListStatus.empty)
                        SliverFillRemaining(
                          child: ArticleWidgets.buildEmptyState(context),
                        ),
                      if (state.articleStatus == ArticleVendorListStatus.loaded)
                        SliverList.builder(
                          itemCount: article.length,
                          itemBuilder: (context, index) =>
                              ArticleWidgets.preview(article: article[index]),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
