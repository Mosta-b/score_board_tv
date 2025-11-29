import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:score_board_tv/widgets/main_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Force landscape orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(ScoreboardApp2());
  });
}
