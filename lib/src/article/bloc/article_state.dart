part of 'article_bloc.dart';

enum ArticleStateStatus { initial, loading, loaded, failed, scheduleCreated }

class ArticleState extends Equatable {
  final ArticleStateStatus status;
  final ArticleVendorListStatus articleStatus;
  final List<ArticleVendorList> articleVendorList;
  final String message;

  const ArticleState({
    required this.articleStatus,
    required this.status,
    required this.message,
    required this.articleVendorList,
  });

  factory ArticleState.initial() {
    return ArticleState(
      status: ArticleStateStatus.initial,
      articleStatus: ArticleVendorListStatus.initial,
      articleVendorList: [],
      message: "",
    );
  }

  ArticleState copyWith({
    ArticleStateStatus Function()? status,
    ArticleVendorListStatus Function()? articleStatus,
    List<ArticleVendorList> Function()? articleVendorList,
    String Function()? message,
  }) {
    return ArticleState(
      
      articleStatus: articleStatus != null
          ? articleStatus()
          : this.articleStatus,
      status: status != null ? status() : this.status,
      message: message != null ? message() : this.message,
      articleVendorList: articleVendorList != null
          ? articleVendorList()
          : this.articleVendorList,
    );
  }

  @override
  List<Object?> get props => [
    status,
    message,
    articleVendorList,
    articleStatus,
  ];
}
