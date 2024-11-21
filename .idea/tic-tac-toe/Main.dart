import 'dart:math';
import 'dart:io';

class TicTacToe {
  late List<List<String>> board;
  int size;
  late String currentPlayer;
  bool isAgainstBot; // Флаг, указывающий на режим игры (человек против бота или человек против человека)
  Random random = Random();

  // Конструктор класса, инициализирующий игровое поле и определяющий, кто ходит первым
  TicTacToe(this.size, this.isAgainstBot) {
    board = List.generate(size, (_) => List.filled(size, ' ')); // Создание пустого игрового поля
    currentPlayer = random.nextBool() ? 'X' : 'O'; // Выбор случайным образом, кто ходит первым
    print('Первым ходит: $currentPlayer');
  }

  // Метод для вывода игрового поля на экран
  void printBoard() {
    stdout.write('  ');
    for (int i = 1; i <= size; i++) {
      stdout.write('$i ');
    }
    print('');

    // Вывод строки игрового поля
    for (int i = 0; i < size; i++) {
      stdout.write('${i + 1} '); // Вывод номера строки
      for (int j = 0; j < size; j++) {
        stdout.write(board[i][j] == ' ' ? '. ' : '${board[i][j]} '); // Вывод символа игрока или точки, если клетка пуста
      }
      print('');
    }
  }

  // Метод для проверки, заполнено ли игровое поле
  bool isBoardFull() {
    for (var row in board) {
      if (row.contains(' ')) {
        return false;
      }
    }
    return true;
  }

  // Метод для проверки, выиграл ли текущий игрок
  bool checkWin(String player) {
    for (int i = 0; i < size; i++) {
      if (board[i].every((cell) => cell == player) || // Проверка строки
          List.generate(size, (j) => board[j][i]).every((cell) => cell == player)) { // Проверка столбца
        return true;
      }
    }
    // Проверка диагоналей
    if (List.generate(size, (i) => board[i][i]).every((cell) => cell == player) || // Проверка первой диагонали
        List.generate(size, (i) => board[i][size - i - 1]).every((cell) => cell == player)) { // Проверка второй диагонали
      return true;
    }
    return false;
  }

  // Метод для выполнения хода
  void makeMove() {
    if (isAgainstBot && currentPlayer == 'O') {
      botMove();
    } else {
      humanMove();
    }
    printBoard(); // Выводим обновленное игровое поле

    if (checkWin(currentPlayer)) {
      print('Игрок $currentPlayer выиграл!');
      return;
    } else if (isBoardFull()) {
      print('Ничья!');
      return;
    }
    // Смена игрока
    currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
  }

  void humanMove() {
    int row, col;
    do {
      print('Игрок $currentPlayer, введите строку и столбец (от 1 до $size):');
      row = int.parse(stdin.readLineSync()!) - 1;  // Вычет 1 для преобразования в индекс
      col = int.parse(stdin.readLineSync()!) - 1;  // Вычет 1 для преобразования в индекс
    }
    // Повтор ввода, пока не будет введена корректная клетка
    while (row < 0 || row >= size || col < 0 || col >= size || board[row][col] != ' ');

    board[row][col] = currentPlayer; // Запись хода игрока на игровое поле
  }

  void botMove() {
    print('Ходит бот (O)...');
    int row, col;
    do {
      row = random.nextInt(size);
      col = random.nextInt(size);
    } while (board[row][col] != ' '); // Повтор, пока не будет найдена пустая клетка

    board[row][col] = 'O'; // Запись хода бота на игровое поле
  }

  // Метод для запуска игры
  void playGame() {
    while (!checkWin(currentPlayer) && !isBoardFull()) { // Пока нет победителя и поле не заполнено
      makeMove();
    }
    print('Игра завершена.');
  }
}

void main() {
  while (true) {
    print('Введите размер поля (n x n):');
    int size = int.parse(stdin.readLineSync()!);

    print('Выберите режим игры:');
    print('1. Человек против человека');
    print('2. Человек против бота');
    int choice = int.parse(stdin.readLineSync()!); // Ввод выбора режима игры

    bool isAgainstBot = choice == 2; // Определение режим игры

    TicTacToe game = TicTacToe(size, isAgainstBot); // Создание объекта игры
    game.printBoard(); // Вывод начального состояния игрового поля
    game.playGame(); // Запуск игры

    print('Хотите начать новую игру? (y/n)');
    String? newGame = stdin.readLineSync(); // Спрашиваем, хочет ли пользователь начать новую игру
    if (newGame?.toLowerCase() != 'y') {
      break; // Если ответ не 'y', завершаем цикл и программу
    }
  }
}