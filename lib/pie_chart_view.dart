import 'dart:math';

import 'package:flutter/material.dart';

typedef PieChartViewTap = Function(int index);
typedef OutsideText = Text Function(PieChartModel model, String scale);

class PieChartView extends ImplicitlyAnimatedWidget {
  final List<PieChartModel> models;
  /// 是否显示内部圆
  final bool isShowHole;
  /// 内部圆的半径
  final double holeRadius;
  /// 内部圆的颜色
  final Color holeColor;
  /// 扇形分割线宽度
  final double spaceWidth;
  /// 溢出上方文字
  final OutsideText? outsideTopText;
  /// 溢出下方文字
  final OutsideText? outsideBottomText;
  /// 扇形点击事件
  final PieChartViewTap? onTap;

  const PieChartView(
    this.models, {
    Key? key,
    this.holeRadius = 55.0,
    this.isShowHole = true,
    this.holeColor = Colors.white,
    this.spaceWidth = 2.0,
    this.outsideTopText,
    this.outsideBottomText,
    this.onTap,
    Curve curve = Curves.linear,
    Duration duration = const Duration(milliseconds: 150),
  }) : super(
          key: key,
          curve: curve,
          duration: duration,
        );

  @override
  _CustomPieViewState createState() => _CustomPieViewState();
}

class _CustomPieViewState extends AnimatedWidgetBaseState<PieChartView> {
  CustomPieTween? customPieTween;

  List<PieChartModel> get end => widget.models
      .map((e) => PieChartModel(
          value: e.value, color: e.color, name: e.name, radius: e.radius))
      .toList();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: PieChartPainter(
        context,
        customPieTween!.evaluate(animation),
        holeRadius: widget.holeRadius,
        isShowHole: widget.isShowHole,
        holeColor: widget.holeColor,
        spaceWidth: widget.spaceWidth,
        outsideTopText: widget.outsideTopText,
        outsideBottomText: widget.outsideBottomText,
        onTap: widget.onTap,
      ),
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    customPieTween = visitor(customPieTween, end, (dynamic value) {
      return CustomPieTween(begin: value, end: end);
    }) as CustomPieTween;
  }
}

class CustomPieTween extends Tween<List<PieChartModel>> {
  CustomPieTween({List<PieChartModel>? begin, List<PieChartModel>? end})
      : super(begin: begin, end: end);

  @override
  List<PieChartModel> lerp(double t) {
    List<PieChartModel> list = [];
    begin?.asMap().forEach((index, model) {
      list.add(model
        ..radius = lerpDouble(model.radius, end?[index].radius ?? 100.0, t));
    });
    return list;
  }

  double lerpDouble(double radius, double radius2, double t) {
    if (radius == radius2) {
      return radius;
    }
    var d = (radius2 - radius) * t;
    var value = radius + d;
    return value;
  }
}

class PieChartPaint extends CustomPaint {
  const PieChartPaint({Key? key}) : super(key: key);
}

class PieChartPainter extends CustomPainter {
  final BuildContext context;
  final List<PieChartModel> models;
  final bool isShowHole;
  final double holeRadius;
  final Color holeColor;
  final double spaceWidth;
  final OutsideText? outsideTopText;
  final OutsideText? outsideBottomText;
  final PieChartViewTap? onTap;

  final List<Path> paths = [];
  final Path holePath = Path();

  Offset oldTapOffset = Offset.zero;

  PieChartPainter(
    this.context,
    this.models, {
    this.holeRadius = 60.0,
    this.isShowHole = true,
    this.holeColor = Colors.white,
    this.spaceWidth = 2.0,
    this.outsideTopText,
    this.outsideBottomText,
    this.onTap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    //移动到中心点
    canvas.translate(size.width / 2, size.height / 2);
    //绘制饼状图
    _drawPie(canvas, size);
    //绘制分割线
    _drawSpaceLine(canvas);
    // //绘制中心圆
    _drawHole(canvas, size);

    // drawLineAndText(canvas);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;

  @override
  bool? hitTest(Offset position) {
    return _interceptTouchEvent(position);
  }

  bool _interceptTouchEvent(Offset offset) {
    if (oldTapOffset.dx == offset.dx && oldTapOffset.dy == offset.dy) {
      return false;
    }
    oldTapOffset = offset;
    for (int i = 0; i < paths.length; i++) {
      if (paths[i].contains(offset) && !holePath.contains(offset)) {
        onTap?.call(i);
        oldTapOffset = offset;
        return true;
      }
    }
    onTap?.call(-1);
    return false;
  }

  /// 绘制分割线
  void _drawSpaceLine(Canvas canvas) {
    var sumValue = models.fold<double>(0.0, (sum, model) => sum + model.value);
    var startAngle = 0.0;
    for (var model in models) {
      _drawLine(canvas, startAngle, model.radius);
      startAngle += model.value / sumValue * 360;
      _drawLine(canvas, startAngle, model.radius);
    }
  }

  void _drawLine(Canvas canvas, double angle, double radius) {
    var endX = cos(angle * pi / 180) * radius;
    var endY = sin(angle * pi / 180) * radius;
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white
      ..strokeWidth = spaceWidth;
    canvas.drawLine(Offset.zero, Offset(endX, endY), paint);
  }

  /// 绘制饼状图
  void _drawPie(Canvas canvas, Size size) {
    var startAngle = 0.0;
    var sumValue = models.fold<double>(0.0, (sum, model) => sum + model.value);
    for (var model in models) {
      Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..color = model.color;
      var sweepAngle = model.value / sumValue * 360;
      canvas.drawArc(Rect.fromCircle(radius: model.radius, center: Offset.zero),
          startAngle * pi / 180, sweepAngle * pi / 180, true, paint);

      Path path = Path();
      var centerX = size.width / 2;
      var centerY = size.height / 2;

      path.addArc(
          Rect.fromCircle(
              radius: model.radius, center: Offset(centerX, centerY)),
          startAngle * pi / 180,
          sweepAngle * pi / 180);
      path.moveTo(centerX, centerY);
      path.lineTo(centerX + cos(startAngle * pi / 180) * model.radius,
          centerY + sin(startAngle * pi / 180) * model.radius);
      path.lineTo(
          centerX + cos((sweepAngle + startAngle) * pi / 180) * model.radius,
          centerY + sin((sweepAngle + startAngle) * pi / 180) * model.radius);
      paths.add(path);

      //为每一个区域绘制延长线和文字
      _drawLineAndText(
          canvas, size, model.radius, startAngle, sweepAngle, model);

      startAngle += sweepAngle;
    }
  }

  /// 绘制延长线和文字
  void _drawLineAndText(Canvas canvas, Size size, double radius,
      double startAngle, double sweepAngle, PieChartModel model) {
    var ratio = (sweepAngle / 360.0 * 100).toStringAsFixed(2);

    var top = outsideTopText?.call(model, ratio) ??
        Text(
          model.name,
          style: const TextStyle(color: Colors.black38),
        );
    var topTextPainter = getTextPainter(top);

    var bottom = outsideBottomText?.call(model, ratio) ??
        Text(
          "$ratio%",
          style: const TextStyle(color: Colors.black38),
        );
    var bottomTextPainter = getTextPainter(bottom);

    // 绘制横线
    // 计算开始坐标以及转折点的坐标
    var startX = radius * (cos((startAngle + (sweepAngle / 2)) * (pi / 180)));
    var startY = radius * (sin((startAngle + (sweepAngle / 2)) * (pi / 180)));

    var firstLine = radius / 5;
    var secondLine =
        max(bottomTextPainter.width, topTextPainter.width) + radius / 4;
    var pointX = (radius + firstLine) *
        (cos((startAngle + (sweepAngle / 2)) * (pi / 180)));
    var pointY = (radius + firstLine) *
        (sin((startAngle + (sweepAngle / 2)) * (pi / 180)));

    // 计算坐标在左边还是在右边
    // 并计算横线结束坐标
    // 如果结束坐标超过了绘制区域，则改变结束坐标的值
    var endX = 0.0;
    // 距离绘制边界的偏移量
    var marginOffset = 20.0;
    if (pointX - startX > 0) {
      endX = min(pointX + secondLine, size.width / 2 - marginOffset);
      secondLine = endX - pointX;
    } else {
      endX = max(pointX - secondLine, -size.width / 2 + marginOffset);
      secondLine = pointX - endX;
    }

    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1
      ..color = Colors.grey;

    // 绘制延长线
    canvas.drawLine(Offset(startX, startY), Offset(pointX, pointY), paint);
    canvas.drawLine(Offset(pointX, pointY), Offset(endX, pointY), paint);

    // 文字距离中间横线上下间距偏移量
    var offset = 4;
    var textWidth = bottomTextPainter.width;
    var textStartX = 0.0;
    textStartX = _calculateTextStartX(
        pointX, startX, textWidth, secondLine, textStartX, offset);
    bottomTextPainter.paint(canvas, Offset(textStartX, pointY + offset));

    textWidth = topTextPainter.width;
    var textHeight = topTextPainter.height;
    textStartX = _calculateTextStartX(
        pointX, startX, textWidth, secondLine, textStartX, offset);
    topTextPainter.paint(
        canvas, Offset(textStartX, pointY - offset - textHeight));

    // 绘制文字前面的小圆点
    paint.color = model.color;
    canvas.drawCircle(
        Offset(textStartX - 8, pointY - 4 - topTextPainter.height / 2),
        4,
        paint);
  }

  double _calculateTextStartX(double stopX, double startX, double w,
      double line2, double textStartX, int offset) {
    if (stopX - startX > 0) {
      if (w > line2) {
        textStartX = (stopX + offset);
      } else {
        textStartX = (stopX + (line2 - w));
      }
    } else {
      if (w > line2) {
        textStartX = (stopX - offset - w);
      } else {
        textStartX = (stopX - (line2 - w) - w);
      }
    }
    return textStartX;
  }

  TextPainter getTextPainter(Text text) {
    TextPainter painter = TextPainter(
      locale: Localizations.localeOf(context),
      maxLines: text.maxLines,
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: text.data,
        style: text.style,
      ),
    );
    painter.layout();
    return painter;
  }

  //绘制中心圆
  void _drawHole(Canvas canvas, Size size) {
    if (isShowHole) {
      holePath.reset();
      Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.white;
      canvas.drawCircle(Offset.zero, holeRadius, paint);
      var centerX = size.width / 2;
      var centerY = size.height / 2;
      holePath.addArc(
          Rect.fromCircle(radius: holeRadius, center: Offset(centerX, centerY)),
          0,
          360 * pi / 180);
    }
  }
}

class PieChartModel {
  double value;
  Color color;
  String name;
  double radius;

  PieChartModel({
    required this.value,
    required this.color,
    required this.name,
    this.radius = 100,
  });
}
