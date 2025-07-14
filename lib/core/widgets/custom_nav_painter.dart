import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

class DentAnimationWidget extends StatefulWidget {
  final List<Offset> iconPositions;

  const DentAnimationWidget({super.key, required this.iconPositions});

  @override
  DentAnimationWidgetState createState() => DentAnimationWidgetState();
}

class DentAnimationWidgetState extends State<DentAnimationWidget> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _circleController;
  late Animation<double> _circleJumpAnimation;

  int _circleStartPosition = 0;
  int _circleEndPosition = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: StifferCurve(),
    );
    _controller.value = 1.0;

    _circleController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _circleJumpAnimation = CurvedAnimation(
      parent: _circleController,
      curve: Curves.easeOutQuad,
    );
  }

  void onParentClick(int selection) {
    _startAnimation(selection);
  }

  void _startAnimation(int endPosition) {
    if (endPosition < 0 || endPosition >= widget.iconPositions.length) return;
    setState(() {
      _circleStartPosition = _circleEndPosition;
      _circleEndPosition = endPosition;
    });
    _circleController.forward(from: 0);
    _controller.reset();
    Future.delayed(const Duration(milliseconds: 200), () => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    _circleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    /*if (widget.iconPositions.any((pos) => pos == Offset.zero)) {
      return const SizedBox.shrink();
    }*/

    return AnimatedBuilder(
      animation: Listenable.merge([_animation, _circleJumpAnimation]),
      builder: (context, child) {
        final dentManager = DentPointManager();
        dentManager.addDynamicDents(
          _circleEndPosition,
          widget.iconPositions,
          screenWidth,
          screenHeight,
          widget.iconPositions.length,
          _animation.value,
        );

        Rect botTabRect = Rect.fromLTWH(
          0,
          screenHeight * .8,
          screenWidth,
          screenHeight * .2,
        );

        return CustomPaint(
          painter: CurvedPainter(
            dents: dentManager._dents,
            circleProgress: _circleJumpAnimation.value,
            circleStartPosition: widget.iconPositions[_circleStartPosition],
            circleEndPosition: widget.iconPositions[_circleEndPosition],
            bottomTab: botTabRect,
            progress: _animation.value,

        ),
          child: SizedBox(
            width: double.infinity,
            height: screenHeight * 0.35,
          ),
        );
      },
    );
  }
}

class StifferCurve extends Curve {
  @override
  double transform(double t) => -math.pow(math.e, -t * 8) * math.cos(t * 6) + 1;
}

double easeDentWidth(double progress) {
  double oscillation = math.sin(progress * math.pi * 2) * 0.3;
  double linear = progress;
  double blend = 1 - progress;
  return 1 + (oscillation * blend) - (0.3 * (1 - linear));
}

class DentPointManager {
  final List<DentData> _dents = [];

  void addDynamicDents(
      int currentSelection,
      List<Offset> iconPositions,
      double screenWidth,
      double screenHeight,
      int dentCount,
      double progress,
      ) {
    //if (dentCount <= 0) return;
    if (dentCount <= 0 || currentSelection >= dentCount) return;

    double dentWidth = screenWidth * 0.35;
    double dentDepth = screenHeight * 0.040;

    for (int i = 0; i < dentCount; i++) {
      double dentCenterX = iconPositions[i].dx;
      Offset dentCenter = Offset(dentCenterX, screenHeight * 0.8);
      addDent(
        dentCenter: dentCenter,
        dentWidth: dentWidth,
        dentDepth: dentDepth,
        progress: i == currentSelection ? progress : 0.0,
      );
    }
  }

  void addDent({
    required Offset dentCenter,
    required double dentWidth,
    required double dentDepth,
    required double progress,
  }) {
    dentDepth *= progress;
    dentWidth *= easeDentWidth(progress);

    final startPoint = Offset(dentCenter.dx - dentWidth / 2, dentCenter.dy);
    final startControlPoint1 = Offset(dentCenter.dx - dentWidth * .14, dentCenter.dy);
    final startControlPoint2 = Offset(dentCenter.dx - dentWidth * .26, dentCenter.dy + dentDepth);
    final middlePoint = Offset(dentCenter.dx, dentCenter.dy + dentDepth);
    final endControlPoint1 = Offset(dentCenter.dx + dentWidth * .26, dentCenter.dy + dentDepth);
    final endControlPoint2 = Offset(dentCenter.dx + dentWidth * .14, dentCenter.dy);
    final endPoint = Offset(dentCenter.dx + dentWidth / 2, dentCenter.dy);

    _dents.add(DentData(
      startPoint,
      Offset.lerp(startPoint, startControlPoint1, progress)!,
      Offset.lerp(startControlPoint1, startControlPoint2, progress)!,
      Offset.lerp(Offset(middlePoint.dx, dentCenter.dy), middlePoint, progress)!,
      Offset.lerp(endPoint, endControlPoint1, progress)!,
      Offset.lerp(endPoint, endControlPoint2, progress)!,
      endPoint,
      Offset.lerp(endPoint, endControlPoint1, progress)!,
      endControlPoint2,
    ));
  }
}

class DentData {
  final Offset startPoint;
  final Offset startControlPoint1;
  final Offset startControlPoint2;
  final Offset middlePoint;
  final Offset middleControlPoint1;
  final Offset middleControlPoint2;
  final Offset endPoint;
  final Offset endControlPoint1;
  final Offset endControlPoint2;

  const DentData(
      this.startPoint,
      this.startControlPoint1,
      this.startControlPoint2,
      this.middlePoint,
      this.middleControlPoint1,
      this.middleControlPoint2,
      this.endPoint,
      this.endControlPoint1,
      this.endControlPoint2,
      );
}

class CurvedPainter extends CustomPainter {
  final List<DentData> dents;
  final double circleProgress;
  final Offset circleStartPosition;
  final Offset circleEndPosition;
  final Rect bottomTab;
  final double progress;

  CurvedPainter({
    required this.dents,
    required this.circleProgress,
    required this.circleStartPosition,
    required this.circleEndPosition,
    required this.bottomTab,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFD2B48C);
      //..color = const Color(0xE82C0D05); // nav background


    final path = Path();
    path.moveTo(bottomTab.left, bottomTab.top);

    for (var dent in dents) {
      path.moveTo(dent.startPoint.dx, dent.startPoint.dy);
      path.cubicTo(
        dent.startControlPoint1.dx,
        dent.startControlPoint1.dy,
        dent.startControlPoint2.dx,
        dent.startControlPoint2.dy,
        dent.middlePoint.dx,
        dent.middlePoint.dy,
      );
      path.cubicTo(
        dent.middleControlPoint1.dx,
        dent.middleControlPoint1.dy,
        dent.middleControlPoint2.dx,
        dent.middleControlPoint2.dy,
        dent.endPoint.dx,
        dent.endPoint.dy,
      );
    }

    path.lineTo(bottomTab.right, bottomTab.top);
    path.lineTo(bottomTab.right, bottomTab.bottom);
    path.lineTo(bottomTab.left, bottomTab.bottom);
    path.close();

    canvas.drawPath(path, paint);
    _drawCircle(canvas, size);
  }

  void _drawCircle(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF8C5E35)
      //..color = Colors.yellow.shade700
      ..style = PaintingStyle.fill;

    final x = lerpDouble(circleStartPosition.dx, circleEndPosition.dx, circleProgress)!;
    final yOffset = size.height * 0.1 * (1 - (circleProgress - 0.5).abs() * 2);
    final y = size.height * 0.8 - yOffset;

    canvas.drawCircle(Offset(x, y), 20, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}