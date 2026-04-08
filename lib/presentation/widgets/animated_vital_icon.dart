import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/vital_sign_model.dart';

class AnimatedVitalIcon extends StatefulWidget {
  final VitalType vitalType;
  final bool isAnimating;
  final double size;
  final Color? color;

  const AnimatedVitalIcon({
    super.key,
    required this.vitalType,
    this.isAnimating = false,
    this.size = 48.0,
    this.color,
  });

  @override
  State<AnimatedVitalIcon> createState() => _AnimatedVitalIconState();
}

class _AnimatedVitalIconState extends State<AnimatedVitalIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isAnimating) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(AnimatedVitalIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !oldWidget.isAnimating) {
      _startAnimation();
    } else if (!widget.isAnimating && oldWidget.isAnimating) {
      _stopAnimation();
    }
  }

  void _startAnimation() {
    _controller.repeat(reverse: true);
  }

  void _stopAnimation() {
    _controller.stop();
    _controller.reset();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData get _iconData {
    switch (widget.vitalType) {
      case VitalType.heartRate:
        return Icons.favorite;
      case VitalType.bloodPressure:
        return Icons.speed;
      case VitalType.spo2:
        return Icons.air;
      case VitalType.sleep:
        return Icons.bedtime;
      case VitalType.exercise:
        return Icons.directions_run;
      case VitalType.steps:
        return Icons.directions_walk;
    }
  }

  Color get _defaultColor {
    switch (widget.vitalType) {
      case VitalType.heartRate:
        return AppTheme.heartColor;
      case VitalType.bloodPressure:
        return AppTheme.bloodPressureColor;
      case VitalType.spo2:
        return AppTheme.spo2Color;
      case VitalType.sleep:
        return AppTheme.sleepColor;
      case VitalType.exercise:
        return AppTheme.exerciseColor;
      case VitalType.steps:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? _defaultColor;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isAnimating ? _scaleAnimation.value : 1.0,
          child: Opacity(
            opacity: widget.isAnimating ? _opacityAnimation.value : 1.0,
            child: Container(
              padding: EdgeInsets.all(widget.size * 0.25),
              decoration: widget.isAnimating
                  ? BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Icon(_iconData, size: widget.size, color: color),
            ),
          ),
        );
      },
    );
  }
}

class PulsingGlow extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final bool isActive;

  const PulsingGlow({
    super.key,
    required this.child,
    required this.glowColor,
    this.isActive = true,
  });

  @override
  State<PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<PulsingGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 25.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulsingGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(0.4),
                blurRadius: _glowAnimation.value,
                spreadRadius: _glowAnimation.value * 0.5,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}
