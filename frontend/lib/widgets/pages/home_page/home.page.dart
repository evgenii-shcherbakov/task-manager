import 'package:flutter/material.dart';
import 'package:frontend/enums/route.enum.dart';
import 'package:frontend/widgets/bottom_bar_page.dart';
import 'package:frontend/widgets/pages/home_page/sub_pages/project_list.page.dart';
import 'package:frontend/widgets/pages/home_page/sub_pages/user.page.dart';
import 'package:go_router/go_router.dart';

import '../../../data/bottom_bar.data.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomBarPage(
      onBack: () => context.go(RouteEnum.auth.value),
      items: _tabItems,
    );
  }

  static final List<BottomBarData> _tabItems = [
    BottomBarData('Проекты', Colors.lightBlue, const Icon(Icons.folder), ProjectListPage.onCreate()),
    BottomBarData('Аккаунт', Colors.limeAccent, const Icon(Icons.account_circle), UserPage.onCreate())
  ];
}
