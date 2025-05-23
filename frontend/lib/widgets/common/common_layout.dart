import 'package:app/widgets/chat_bot.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/app_footer.dart';
import 'package:app/widgets/common/theme_builder.dart'; // 追加

class CommonLayout extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;

  const CommonLayout({
    super.key,
    required this.child,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, primaryColor) {
        return Stack(
          children: [
            Scaffold(
              appBar: appBar,
              body: SingleChildScrollView(child: child),
              bottomNavigationBar: const AppFooter(),
              floatingActionButton: const ChatBot(),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
            ),
          ],
        );
      },
    );
  }
}
