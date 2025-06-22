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
              extendBody: true,
              appBar: appBar,
              body: Stack(
                children: [
                  Positioned.fill(child: SingleChildScrollView(child: child)),
                  const Positioned(
                    right: 16,
                    bottom: 16,
                    child: ChatBot(),
                  ),
                ],
              ),
              bottomNavigationBar: const AppFooter(),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/add_schedule');
                },
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(Icons.add, size: 32),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
            ),
          ],
        );
      },
    );
  }
}
