import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:score_board_tv/widgets/main_widget.dart';

class TimerFloatingActionButton extends StatefulWidget {
  const TimerFloatingActionButton({super.key});

  @override
  State<TimerFloatingActionButton> createState() =>
      _TimerFloatingActionButtonState();
}

class _TimerFloatingActionButtonState extends State<TimerFloatingActionButton> {
  late Timer _timer;
  Duration _timerDuration = const Duration(minutes: 90);

  Duration _currentDuration = const Duration(minutes: 90);
  bool _isRunning = false;
  @override
  void initState() {
    super.initState();
    // Initialize current duration to the default timer duration
    _currentDuration = _timerDuration;
    // Initialize timer to avoid late initialization errors, will be cancelled if not started
    _timer = Timer(Duration.zero, () {});
  }

  void resetTimer() {
    // Cancel any active timer
    if (_timer.isActive) {
      _timer.cancel();
    }
    setState(() {
      _isRunning = false;
      // Reset current duration to the last set timer duration
      _currentDuration = _timerDuration;
    });
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  void _pauseTimer() {
    if (_isRunning) {
      _timer.cancel(); // Stop the periodic timer
      setState(() {
        _isRunning = false;
      });
    }
  }

  // --- Timer Methods ---
  void _startTimer() {
    Navigator.of(context).pop();
    // Only start if the timer is not already running and duration is greater than 0
    if (!_isRunning && _currentDuration.inSeconds > 0) {
      setState(() {
        _isRunning = true;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_currentDuration.inSeconds > 0) {
            _currentDuration = _currentDuration - const Duration(seconds: 1);
          } else {
            // Timer finished
            _timer.cancel();
            _isRunning = false;
            // Optionally, add a notification or sound when time is up
          }
        });
      });
    }
  }

  // Helper to format duration into MM : SS
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes : $seconds';
  }

  // --- Dialog for Timer Settings and Controls ---
  Future<void> _showTimerSettingsDialog() async {
    // Use a local controller for the dialog's text field
    TextEditingController minutesController = TextEditingController(
      text: _timerDuration.inMinutes.toString(),
    );

    return showDialog<void>(
      context: context,
      barrierDismissible: true, // User must tap a button to close
      builder: (BuildContext context) {
        return MediaQuery.removeViewInsets(
          context: context,
          removeBottom: true,
          removeLeft: true,
          removeRight: true,
          removeTop: true,
          child: AlertDialog(
            title: const Text('Set Timer Duration & Controls'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: minutesController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ], // Only allow digits
                    decoration: const InputDecoration(
                      labelText: 'Minutes (e.g., 90)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: _startTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Start'),
                      ),
                      ElevatedButton(
                        onPressed: _pauseTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text('Pause'),
                      ),
                      ElevatedButton(
                        onPressed: resetTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Set & Close'),
                onPressed: () {
                  setState(() {
                    // Parse the input minutes, default to 90 if invalid
                    int newMinutes = int.tryParse(minutesController.text) ?? 90;
                    // Ensure minutes are not negative
                    if (newMinutes < 0) newMinutes = 0;

                    _timerDuration = Duration(minutes: newMinutes);
                    // If timer was running, pause it and reset to new duration
                    if (_isRunning) {
                      _timer.cancel();
                      _isRunning = false;
                    }
                    _currentDuration =
                        _timerDuration; // Update current duration to new set value
                  });
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: getScreenHeight(context) * .05, // Adjust padding as needed
      ),
      child: SizedBox(
        width: getScreenWidth(context) * .19, // Adjust width as needed
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF00509D),
          onPressed: _showTimerSettingsDialog,
          label: AutoSizeText(
            _formatDuration(_currentDuration),
            style: Theme.of(context).textTheme.displaySmall,
          ),
          icon: _isRunning
              ? const Icon(Icons.pause, color: Colors.white)
              : const Icon(Icons.play_arrow, color: Colors.white),
        ),
      ),
    );
  }
}
