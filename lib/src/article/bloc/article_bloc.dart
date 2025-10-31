import 'package:equatable/equatable.dart';
import 'package:expert_connect/src/article/repo/article_repo.dart';
import 'package:expert_connect/src/home/repo/home_repo.dart';
import 'package:expert_connect/src/models/article_vendor_list.dart';
import 'package:expert_connect/src/models/vendors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'article_event.dart';
part 'article_state.dart';

class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final ArticleRepo _articleRepo;
  final HomeRepo _homeRepo;
  ArticleBloc(final ArticleRepo articleRepo,final HomeRepo homeRepo)
    : _articleRepo = articleRepo,
    _homeRepo = homeRepo,
      super(ArticleState.initial()) {
    on<GetArticleVendorList>(_onGetArticleVendorList);
  }
Future<void> _onGetArticleVendorList(
  GetArticleVendorList event,
  Emitter<ArticleState> emit,
) async {
  emit(state.copyWith(status: () => ArticleStateStatus.loading));
  try {
    final articleVendorList = await _articleRepo.getArticleVendorList();
    
    // Create a list to store updated articles with vendor information
    List<ArticleVendorList> updatedArticleList = [];
    
    // Iterate through each article and fetch vendor details
    for (ArticleVendorList article in articleVendorList) {
      try {
        // Fetch vendor details using the vendorId from the article
        final vendor = await _homeRepo.vendorProfile(article.vendorId);
        
        // Update the article with vendor information using copyWith
        final updatedArticle = article.copyWith(vendor: vendor);
        updatedArticleList.add(updatedArticle);
      } catch (vendorError) {
        debugPrint('Error fetching vendor for article ${article.id}: $vendorError');
        // Add article with initial vendor if vendor fetch fails
        final updatedArticle = article.copyWith(vendor: Vendor.initial());
        updatedArticleList.add(updatedArticle);
      }
    }
    
    if (updatedArticleList.isNotEmpty) {
      emit(
        state.copyWith(
          message: () => "Article Vendor List loaded successfully",
          articleVendorList: () => updatedArticleList,
          status: () => ArticleStateStatus.loaded,
          articleStatus: () => ArticleVendorListStatus.loaded,
        ),
      );
    } else {
      emit(
        state.copyWith(
          message: () => "Article Vendor List is empty",
          articleVendorList: () => updatedArticleList,
          status: () => ArticleStateStatus.loaded,
          articleStatus: () => ArticleVendorListStatus.empty,
        ),
      );
    }
  } catch (e) {
    debugPrint(e.toString());
    emit(
      state.copyWith(
        message: () => e.toString(),
        status: () => ArticleStateStatus.failed,
      ),
    );
  }
}
}
