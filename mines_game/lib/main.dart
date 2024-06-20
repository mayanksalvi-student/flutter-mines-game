import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: MinesGame()),
    );
  }
}

class MinesGame extends StatefulWidget {
  @override
  _MinesGameState createState() => _MinesGameState();
}

class _MinesGameState extends State<MinesGame> {
  List<List<Cell>> board = [];
  bool gameActive = false;
  bool hitMine = false;
  double betAmount = 10.00;

  @override
  void initState() {
    super.initState();
    generateBoard(5, 3); // Initial board generation with default values
  }

  void generateBoard(int size, int minesCount) {
    setState(() {
      board = List.generate(size, (i) => List.generate(size, (j) => Cell()));
      gameActive = true;
      hitMine = false;
    });

    List<int> mines = [];
    while (mines.length < minesCount) {
      int rand = Random().nextInt(size * size);
      if (!mines.contains(rand)) {
        mines.add(rand);
        int row = rand ~/ size;
        int col = rand % size;
        setState(() => board[row][col].isMine = true);
      }
    }
  }

  void revealCell(int row, int col) {
    if (!gameActive || board[row][col].revealed) return;

    setState(() {
      board[row][col].revealed = true;
    });

    if (board[row][col].isMine) {
      setState(() => hitMine = true);
      // Play bomb sound
      gameOver();
    } else {
      // Play 'oh yeah' sound
      checkWin();
    }
  }

  void revealAllMines() {
    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[i].length; j++) {
        if (board[i][j].isMine && !board[i][j].revealed) {
          setState(() => board[i][j].revealed = true);
        }
      }
    }
  }

  void gameOver() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over!'),
        content: const Text('You hit a mine.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => gameActive = false);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    revealAllMines();
  }

  void checkWin() {
    int revealedCells = 0;
    int totalCells = board.length * board.length;
    int mineCount = 3; // Change this to dynamically get minesCount

    for (var row in board) {
      for (var cell in row) {
        if (cell.revealed && !cell.isMine) {
          revealedCells++;
        }
      }
    }

    if (revealedCells == totalCells - mineCount) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Congratulations!'),
          content: const Text('You have won.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => gameActive = false);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Mines Game'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Game Board Widget
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: board.length,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: board.length * board.length,
                itemBuilder: (context, index) {
                  int row = index ~/ board.length;
                  int col = index % board.length;
                  return GestureDetector(
                    onTap: () => revealCell(row, col),
                    child: Container(
                      decoration: BoxDecoration(
                        color: board[row][col].revealed
                            ? board[row][col].isMine
                                ? Colors.red
                                : Colors.orange
                            : Colors.cyan,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(),
                      ),
                      child: Center(
                        child: Text(
                          board[row][col].revealed
                              ? board[row][col].isMine
                                  ? '💣'
                                  : '⭐'
                              : '',
                          style: const TextStyle(
                              fontSize: 24, color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Controls
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => generateBoard(5, 3),
                          child: Text('New Game'),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Bet Amount'),
                              content:
                                  Text('You have placed a bet of ₹$betAmount.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                          ),
                          child: Text('Bet'),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DropdownButton<int>(
                        value: board.length,
                        items: [2, 5, 6, 7].map((size) {
                          return DropdownMenuItem<int>(
                            value: size,
                            child: Text('$size x $size Grid'),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            generateBoard(value!, 3), // 3 Mines by default
                      ),
                      const SizedBox(width: 20),
                      DropdownButton<int>(
                        value: 3, // Default mines count
                        items: [2, 3, 5, 10].map((mines) {
                          return DropdownMenuItem<int>(
                            value: mines,
                            child: Text('$mines Mines'),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            generateBoard(board.length, value!),
                      ),
                    ],
                  )
                ],
              ),
            ),
            // Game Info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Bet Amount: ',
                  style: TextStyle(fontSize: 18),
                ),
                IconButton(
                  onPressed: () {
                    if (betAmount > 10) setState(() => betAmount -= 10);
                  },
                  icon: Icon(Icons.new_label),
                ),
                Text(
                  '₹${betAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18),
                ),
                IconButton(
                  onPressed: () => setState(() => betAmount += 10),
                  icon: Icon(Icons.add),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class Cell {
  bool isMine = false;
  bool revealed = false;
}
