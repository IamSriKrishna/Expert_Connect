import 'package:expert_connect/src/home/bloc/home_bloc.dart';
import 'package:expert_connect/src/home/repo/home_repo.dart';
import 'package:expert_connect/src/home/widgets/category_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryScreen extends StatelessWidget {
  final int id;
  final String category;
  const CategoryScreen({super.key, required this.id, required this.category});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HomeBloc(HomeRepoImpl())..add(FetchSubCategories(categoryId: id)),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2D3748),
              title:  Text(
                category,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
              centerTitle: true,
            ),
            body: Row(
              children: [
                CategoryWidget.sideBar(state),
                CategoryWidget.mainContent(id,state,category),
              ],
            ),
          );
        },
      ),
    );
  }
}
