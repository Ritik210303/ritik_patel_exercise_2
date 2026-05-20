import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MemoryMatchApp());
}

class MemoryMatchApp extends StatelessWidget {
  const MemoryMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Memory Match Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MemoryGameScreen(),
    );
  }
}

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final List<String> cardImages = [
    '🐶',
    '🐱',
    '🐰',
    '🦁',
    '🐼',
    '🐸',
    '🐵',
    '🐧',
  ];

  late List<String> gameCards;
  late List<bool> flippedCards;
  late List<bool> matchedCards;

  int? firstSelectedIndex;
  int? secondSelectedIndex;
  int moves = 0;
  bool isChecking = false;

  @override
  void initState() {
    super.initState();
    startNewGame();
  }

  void startNewGame() {
    gameCards = [...cardImages, ...cardImages];
    gameCards.shuffle(Random());

    flippedCards = List.generate(gameCards.length, (index) => false);
    matchedCards = List.generate(gameCards.length, (index) => false);

    firstSelectedIndex = null;
    secondSelectedIndex = null;
    moves = 0;
    isChecking = false;

    setState(() {});
  }

  void flipCard(int index) {
    if (isChecking || flippedCards[index] || matchedCards[index]) {
      return;
    }

    setState(() {
      flippedCards[index] = true;

      if (firstSelectedIndex == null) {
        firstSelectedIndex = index;
      } else {
        secondSelectedIndex = index;
        moves++;
        checkMatch();
      }
    });
  }

  void checkMatch() {
    isChecking = true;

    if (gameCards[firstSelectedIndex!] == gameCards[secondSelectedIndex!]) {
      matchedCards[firstSelectedIndex!] = true;
      matchedCards[secondSelectedIndex!] = true;

      firstSelectedIndex = null;
      secondSelectedIndex = null;
      isChecking = false;

      if (matchedCards.every((card) => card == true)) {
        Future.delayed(const Duration(milliseconds: 500), () {
          showWinDialog();
        });
      }
    } else {
      Timer(const Duration(seconds: 1), () {
        setState(() {
          flippedCards[firstSelectedIndex!] = false;
          flippedCards[secondSelectedIndex!] = false;

          firstSelectedIndex = null;
          secondSelectedIndex = null;
          isChecking = false;
        });
      });
    }
  }

  void showWinDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Congratulations!'),
          content: Text('You matched all cards in $moves moves.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                startNewGame();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int matchedPairs = matchedCards.where((card) => card == true).length ~/ 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F0FF),
      appBar: AppBar(
        title: const Text(
          'Memory Match',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade100,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          Text(
            'Find all matching pairs',
            style: TextStyle(
              fontSize: 18,
              color: Colors.deepPurple.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Moves: $moves   |   Matched Pairs: $matchedPairs / 8',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: gameCards.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  bool showCard = flippedCards[index] || matchedCards[index];

                  return GestureDetector(
                    onTap: () => flipCard(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: showCard
                            ? Colors.white
                            : Colors.deepPurple.shade400,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          showCard ? gameCards[index] : '?',
                          style: TextStyle(
                            fontSize: showCard ? 34 : 36,
                            fontWeight: FontWeight.bold,
                            color: showCard
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: ElevatedButton.icon(
              onPressed: startNewGame,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Restart Game'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}