import 'package:expert_connect/src/help/widgets/help_widgets.dart';
import 'package:expert_connect/src/widgets/common_widgets.dart';
import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          CommonWidgets.appBar(),
          HelpWidgets.welcomeText(),
          HelpWidgets.fields(),
        ],
      ),
    );
  }
}
