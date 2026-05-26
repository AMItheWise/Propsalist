import 'package:flutter/material.dart';

Route<T> buildProposalistPageRoute<T>({
  required WidgetBuilder builder,
  RouteSettings? settings,
}) {
  return PageRouteBuilder<T>(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0, 0.08);
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;
      final offsetTween = Tween(
        begin: begin,
        end: end,
      ).chain(CurveTween(curve: curve));
      final opacityAnimation = animation.drive(
        CurveTween(curve: Curves.easeOut),
      );

      return FadeTransition(
        key: const Key('proposalistPageTransition'),
        opacity: opacityAnimation,
        child: SlideTransition(
          position: animation.drive(offsetTween),
          child: child,
        ),
      );
    },
  );
}
