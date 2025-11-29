import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async'; // Required for Timer
import 'package:auto_size_text/auto_size_text.dart';
import 'package:score_board_tv/widgets/animated_background.dart'; // Required for AutoSizeText

// Helper functions (assuming these are defined globally or in a utility file)
double getScreenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double getScreenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

// Define the Intents (the commands we want to execute)
// We keep SettingsIntent, but Increment/Decrement are no longer needed
class SettingsIntent extends Intent {
  const SettingsIntent();
}

// Main App Widget for demonstration
class ScoreboardApp2 extends StatelessWidget {
  const ScoreboardApp2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // A dark theme is better for TV screens
      theme: ThemeData.dark().copyWith(
        textTheme: const TextTheme(
          displayMedium: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineLarge: TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          displaySmall: TextStyle(
            // Added for the timer text
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            // Added for displaying key info
            fontSize: 24,
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        // This makes the focus highlight visible
        focusColor: const Color(0xFFFDC500).withOpacity(.5),
      ),
      home: Scaffold(
        body: AnimatedBackground(
          child: InteractiveScoreboardSecond(),
        ),
      ),
    );
  }
}

// --- TimerFloatingActionButton Widget ---
class TimerFloatingActionButton extends StatefulWidget {
  // GlobalKey to allow parent widget to access this widget's state methods
  final GlobalKey<TimerFloatingActionButtonState> key;
  final Function(String) onButtonPressed; // Callback for button presses

  const TimerFloatingActionButton({
    required this.key,
    required this.onButtonPressed,
  }) : super(key: key);

  @override
  State<TimerFloatingActionButton> createState() =>
      TimerFloatingActionButtonState();
}

class TimerFloatingActionButtonState extends State<TimerFloatingActionButton> {
  late Timer _timer;
  Duration _timerDuration = const Duration(minutes: 60);
  Duration _currentDuration = const Duration(minutes: 60);
  bool _isRunning = false;

  // FocusNodes for the dialog buttons and text field
  final FocusNode _minutesTextFieldFocusNode = FocusNode();
  final FocusNode _startButtonFocusNode = FocusNode();
  final FocusNode _pauseButtonFocusNode = FocusNode();
  final FocusNode _resetButtonFocusNode = FocusNode();
  final FocusNode _cancelButtonFocusNode = FocusNode();
  final FocusNode _setAndCloseButtonFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentDuration = _timerDuration;
    _timer = Timer(Duration.zero, () {}); // Initialize a dummy timer
  }

  // Public method to reset the timer, callable from parent
  void resetTimer() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    setState(() {
      _isRunning = false;
      _currentDuration = _timerDuration; // Reset to the last set duration
    });
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    // Dispose all custom FocusNodes to prevent memory leaks
    _minutesTextFieldFocusNode.dispose();
    _startButtonFocusNode.dispose();
    _pauseButtonFocusNode.dispose();
    _resetButtonFocusNode.dispose();
    _cancelButtonFocusNode.dispose();
    _setAndCloseButtonFocusNode.dispose();
    super.dispose();
  }

  void _pauseTimer() {
    if (_isRunning) {
      _timer.cancel();
      setState(() {
        _isRunning = false;
      });
    }
    widget.onButtonPressed('Timer Pause Button'); // Notify parent
  }

  void _startTimer() {
    // We intentionally do NOT pop the dialog here, so the user can see/use pause/reset buttons
    if (!_isRunning && _currentDuration.inSeconds > 0) {
      setState(() {
        _isRunning = true;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_currentDuration.inSeconds > 0) {
            _currentDuration = _currentDuration - const Duration(seconds: 1);
          } else {
            _timer.cancel();
            _isRunning = false;
            // Optionally, add a notification or sound when time is up
          }
        });
      });
    }
    widget.onButtonPressed('Timer Start Button'); // Notify parent
  }

  // Helper to format duration into MM : SS (fixed to show total minutes)
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    // Use inMinutes directly to show total minutes, not remainder(60)
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes : $seconds';
  }

  Future<void> _showTimerSettingsDialog() async {
    widget.onButtonPressed('Timer Settings Opened'); // Notify parent
    TextEditingController minutesController = TextEditingController(
      text: _timerDuration.inMinutes.toString(),
    );

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        // Changed context to dialogContext to avoid confusion
        // Request focus for the Start button after the dialog is built
        // This attempts to override the TextField's default autofocus
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // If the TextField currently has focus, try to unfocus it and move to start button
          // if (_minutesTextFieldFocusNode.hasFocus) {
          //   _minutesTextFieldFocusNode.unfocus();
          //   FocusScope.of(dialogContext).requestFocus(_startButtonFocusNode);
          // } else {
          //   // Otherwise, just request focus for the start button
          //   FocusScope.of(dialogContext).requestFocus(_startButtonFocusNode);
          // }
        });

        return MediaQuery.removeViewInsets(
          context: dialogContext, // Use dialogContext
          removeBottom: true,
          removeLeft: true,
          removeRight: true,
          removeTop: true,
          child: AlertDialog(
            title: const Text(
              'Modifier La Durée De La Minuterie',
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: minutesController,
                    focusNode:
                        _minutesTextFieldFocusNode, // Assign focus node to TextField
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Minutes (ex : 90)',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) {
                      widget.onButtonPressed(
                        'Timer Minutes Entered',
                      ); // Notify parent
                      FocusScope.of(
                        dialogContext,
                      ).requestFocus(_startButtonFocusNode);
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        focusNode: _startButtonFocusNode, // Assign focus node
                        // autofocus: true, // No need for autofocus here, managed by postFrameCallback
                        onPressed: _startTimer,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateColor.resolveWith(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.focused)) {
                                return Colors.green.withOpacity(
                                  .5,
                                ); // Highlight color when focused
                              }
                              return Colors.green; // Default color
                            },
                          ),
                        ),
                        child: const Text('Démarrer'),
                      ),
                      ElevatedButton(
                        focusNode: _pauseButtonFocusNode, // Assign focus node
                        onPressed: _pauseTimer,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateColor.resolveWith(
                            (Set<WidgetState> states) {
                              if (states.contains(
                                WidgetState.focused,
                              )) {
                                return Theme.of(
                                  dialogContext,
                                ).focusColor; // Highlight color when focused
                              }
                              return Colors.orange; // Default color
                            },
                          ),
                        ),
                        child: const Text('Pause'),
                      ),
                      ElevatedButton(
                        focusNode: _resetButtonFocusNode, // Assign focus node
                        onPressed: () {
                          resetTimer();
                          widget.onButtonPressed(
                            'Timer Reset Button',
                          ); // Notify parent
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateColor.resolveWith(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.focused)) {
                                return Colors.red.withOpacity(
                                  .5,
                                ); // Highlight color when focused
                              }
                              return Colors.red; // Default color
                            },
                          ),
                        ),
                        child: const Text('Réinitialiser'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                focusNode: _cancelButtonFocusNode, // Assign focus node
                child: const Text('Fermer'),
                onPressed: () {
                  widget.onButtonPressed(
                    'Timer Settings Close Button',
                  ); // Notify parent
                  Navigator.of(dialogContext).pop();
                },
              ),
              TextButton(
                focusNode: _setAndCloseButtonFocusNode, // Assign focus node
                child: const Text('Régler et fermer'),
                onPressed: () {
                  setState(() {
                    int newMinutes = int.tryParse(minutesController.text) ?? 90;
                    if (newMinutes < 0) newMinutes = 0;

                    _timerDuration = Duration(minutes: newMinutes);
                    if (_isRunning) {
                      _timer.cancel();
                      _isRunning = false;
                    }
                    _currentDuration = _timerDuration;
                  });
                  widget.onButtonPressed(
                    'Timer Set & Close Button',
                  ); // Notify parent
                  Navigator.of(dialogContext).pop();
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
        top: getScreenHeight(context) * .05,
      ),
      child: SizedBox(
        width: getScreenWidth(context) * .15,
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF00509D),
          onPressed: _showTimerSettingsDialog,
          label: AutoSizeText(
            _formatDuration(_currentDuration),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          icon: _isRunning
              ? const Icon(Icons.pause, color: Colors.white)
              : const Icon(Icons.play_arrow, color: Colors.white),
        ),
      ),
    );
  }
}

// The main interactive scoreboard widget
class InteractiveScoreboardSecond extends StatefulWidget {
  const InteractiveScoreboardSecond({super.key});

  @override
  State<InteractiveScoreboardSecond> createState() =>
      _InteractiveScoreboardState();
}

class _InteractiveScoreboardState extends State<InteractiveScoreboardSecond> {
  int _teamAScore = 0;
  int _teamBScore = 0;
  String _teamAName = "Équipe A";
  String _teamBName = "Équipe B";

  // GlobalKey for accessing the TimerFloatingActionButtonState
  final GlobalKey<TimerFloatingActionButtonState> _timerKey =
      GlobalKey<TimerFloatingActionButtonState>();

  // Focus nodes are kept for visual feedback on team names
  final FocusNode _teamAFocusNode = FocusNode();
  final FocusNode _teamBFocusNode = FocusNode();

  @override
  void dispose() {
    _teamAFocusNode.dispose();
    _teamBFocusNode.dispose();
    super.dispose();
  }

  // --- NEW: Score control methods ---
  void _incrementTeamA() {
    setState(() {
      _teamAScore++;
    });
  }

  void _decrementTeamA() {
    setState(() {
      if (_teamAScore > 0) {
        _teamAScore--;
      }
    });
  }

  void _incrementTeamB() {
    setState(() {
      _teamBScore++;
    });
  }

  void _decrementTeamB() {
    setState(() {
      if (_teamBScore > 0) {
        _teamBScore--;
      }
    });
  }

  Future<void> _showSettingsDialog() async {
    TextEditingController teamAController = TextEditingController(
      text: _teamAName,
    );
    TextEditingController teamBController = TextEditingController(
      text: _teamBName,
    );

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return MediaQuery.removeViewInsets(
          context: context,
          removeBottom: true,
          removeLeft: true,
          removeRight: true,
          removeTop: true,
          child: AlertDialog(
            title: const Text('Paramètres'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: teamAController,
                    decoration: const InputDecoration(
                      labelText: "Nom de l'équipe A",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: teamBController,
                    decoration: const InputDecoration(
                      labelText: "Nom de l'équipe B",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirmer la réinitialisation'),
                            content: const Text(
                              "Êtes-vous sûr de vouloir réinitialiser tous les scores, le chronomètre et les noms d'équipe ? Cette action ne peut pas être annulée.",
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Annuler'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text('Réinitialiser tout'),
                                onPressed: () {
                                  setState(() {
                                    _teamAScore = 0;
                                    _teamBScore = 0;
                                    _teamAName = "Équipe A";
                                    _teamBName = "Équipe B";
                                    // Call the resetTimer method on the TimerFloatingActionButton
                                    _timerKey.currentState?.resetTimer();
                                    teamAController.text = _teamAName;
                                    teamBController.text = _teamBName;
                                  });

                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Réinitialiser tout'),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Annuler'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Sauvegarder'),
                onPressed: () {
                  setState(() {
                    _teamAName = teamAController.text;
                    _teamBName = teamBController.text;
                  });
                  Navigator.of(context).pop();
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
    // Shortcuts are now only for the settings menu
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.settings): const SettingsIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          // Actions for score changes are removed
          SettingsIntent: CallbackAction<SettingsIntent>(
            onInvoke: (intent) {
              _showSettingsDialog();
              return null;
            },
          ),
        },
        child: Center(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: getScreenWidth(context) * .9,
                  height: getScreenHeight(context) * .22,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF00296B),
                      border: Border.all(
                        width: 3,
                        color: const Color(0xFF00509D),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Team A Name
                    Padding(
                      padding: EdgeInsets.only(
                        left: getScreenWidth(context) * .1,
                      ),
                      child: SizedBox(
                        width: getScreenWidth(context) * .2,
                        child: FocusableTeam(
                          focusNode: _teamAFocusNode,
                          teamName: _teamAName,
                          autofocus: true,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // --- MODIFIED: Team A Buttons in a Column ---
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                            size: 36,
                          ),
                          focusColor: Theme.of(context).focusColor,

                          onPressed: _incrementTeamA,
                          tooltip: "Augmenter le score de l'équipe A",
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.white,
                            size: 36,
                          ),
                          focusColor: Theme.of(context).focusColor,

                          onPressed: _decrementTeamA,
                          tooltip: "Diminuer le score de l'équipe A",
                        ),
                      ],
                    ),

                    // Central Score Display
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SizedBox(
                        width: getScreenWidth(context) * .2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD500),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              width: 3,
                              color: const Color(0xFFFDC500),
                            ),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: SizedBox(
                            height: getScreenHeight(context) * .25,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: AutoSizeText(
                                    "$_teamAScore",
                                    textAlign: TextAlign.center,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineLarge,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                  ),
                                  child: Text(
                                    "-",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineLarge,
                                  ),
                                ),
                                Expanded(
                                  child: AutoSizeText(
                                    "$_teamBScore",
                                    textAlign: TextAlign.center,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineLarge,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // --- MODIFIED: Team B Buttons in a Column ---
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                            size: 36,
                          ),
                          focusColor: Theme.of(context).focusColor,
                          onPressed: _incrementTeamB,
                          tooltip: "Augmenter le score de l'équipe B",
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.white,
                            size: 36,
                          ),
                          focusColor: Theme.of(context).focusColor,

                          onPressed: _decrementTeamB,
                          tooltip: "Diminuer le score de l'équipe B",
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Team B Name
                    Padding(
                      padding: EdgeInsets.only(
                        right: getScreenWidth(context) * .1,
                      ),
                      child: SizedBox(
                        width: getScreenWidth(context) * .2,
                        child: FocusableTeam(
                          focusNode: _teamBFocusNode,
                          teamName: _teamBName,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Use the extracted TimerFloatingActionButton
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: getScreenHeight(context) * .4,
                  ),
                  child: TimerFloatingActionButton(
                    key: _timerKey,
                    onButtonPressed: (p0) {},
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.all(getScreenWidth(context) * .03),
                  child: FloatingActionButton(
                    backgroundColor: const Color(0xFF00509D),
                    onPressed: _showSettingsDialog,
                    child: const Icon(Icons.settings, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A reusable widget that makes the team name focusable and shows a
/// visual indicator (a colored background) when it has focus.
class FocusableTeam extends StatefulWidget {
  final FocusNode focusNode;
  final String teamName;
  final bool autofocus;

  const FocusableTeam({
    super.key,
    required this.focusNode,
    required this.teamName,
    this.autofocus = false,
  });

  @override
  State<FocusableTeam> createState() => _FocusableTeamState();
}

class _FocusableTeamState extends State<FocusableTeam> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getScreenHeight(context) * .15,
      child: AutoSizeText(
        textAlign: TextAlign.center,
        widget.teamName,
        style: Theme.of(context).textTheme.displayMedium,
      ),
    );
  }
}
