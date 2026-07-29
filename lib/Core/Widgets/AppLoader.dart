import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';

class AppLoader {
  AppLoader._();

  static bool _isShowing = false;

  static void show({bool dismissible = false}) {
    if (_isShowing) return;

    _isShowing = true;

    Get.dialog(
      PopScope(
        canPop: dismissible,
        child: const _LoaderView(),
      ),
      barrierDismissible: dismissible,
      barrierColor: Colors.transparent,
      useSafeArea: false,
      transitionDuration: const Duration(milliseconds: 220),
    ).then((_) => _isShowing = false);
  }

  static void hide() {
    if (!_isShowing) return;

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    _isShowing = false;
  }
}

class _LoaderView extends StatefulWidget {
  const _LoaderView();

  @override
  State<_LoaderView> createState() => _LoaderViewState();
}

class _LoaderViewState extends State<_LoaderView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  )..forward();

  late final Animation<double> _blur = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  late final Animation<double> _scale = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutBack,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 8 * _blur.value,
              sigmaY: 8 * _blur.value,
            ),
            child: Container(
              color: Colors.black.withOpacity(.1 * _blur.value),
              child: child,
            ),
          );
        },
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: FadeTransition(
              opacity: _blur,
              child: LoadingAnimationWidget.fourRotatingDots(
                color: AppColors.primary,
                size: 52,
              ),
            ),
          ),
        ),
      ),
    );
  }
}