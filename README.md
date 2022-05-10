<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->


![alt screenshot](https://github.com/EaniaHuui/chart_view/blob/main/screenshot/screenshot.gif)

## Usage

```yaml
dependencies:
  flutter:
    sdk: flutter

  chart_view:
    git: https://github.com/EaniaHuui/chart_view.git
```

```dart
import 'package:chart_view/chart_view.dart';

PieChartView(
  [
    PieChartModel(
      value: 35,
      name: 'A',
      color: Colors.blue,
      radius: 100,
    ),
    PieChartModel(
      value: 15,
      name: 'B',
      color: Colors.red,
      radius: 100,
    ),
    PieChartModel(
      value: 22,
      name: 'C',
      color: Colors.yellow,
      radius: 100,
    ),
    PieChartModel(
      value: 18,
      name: 'D',
      color: Colors.orange,
      radius: 100,
    ),
    PieChartModel(
      value: 39,
      name: 'F',
      color: Colors.green,
      radius: 100,
    ),
  ],
)
```
