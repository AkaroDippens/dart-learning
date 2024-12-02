import 'dart:io';
import 'dart:math';

void main() {
  final game = Game();
  game.start();
}

// Класс для корабля
class Ship {
  final String name;
  final int size;
  List<List<int>> positions; // Координаты корабля
  int hits = 0;

  Ship(this.name, this.size) : positions = [];

  bool isSunk() => hits >= size; // Проверка, уничтожен ли корабль
}

// Класс для игрового поля
class GameField {
  final int size;
  List<List<String>> grid;
  List<Ship> ships = [];

  GameField(this.size)
      : grid = List.generate(size, (_) => List.generate(size, (_) => '.')); // Инициализация игрового поля

  void placeShipManually(Ship ship) {
    while (true) {
      print('\nТекущее состояние вашего поля:');
      printFieldWithCoordinates(); // Выводим поле с координатами

      print(
          'Введите координаты начала корабля "${ship.name}" (длина ${ship.size}). Например: A3 H (H - горизонтально, V - вертикально):');
      final input = stdin.readLineSync();
      if (input == null) continue;
      final parts = input.split(' ');

      if (parts.length != 2) continue; // Проверка на корректность ввода

      final rowLetter = parts[0][0].toUpperCase(); // Получаем букву строки
      final col = int.tryParse(parts[0].substring(1)); // Получаем столбец
      final direction = parts[1].toUpperCase(); // Получаем направление (Вертик. или горизонт.)

      if (rowLetter.codeUnitAt(0) < 65 ||
          rowLetter.codeUnitAt(0) >= 65 + size) {
        print(
            'Неверная строка, используйте буквы от A до ${String.fromCharCode(65 + size - 1)}');
        continue;
      }

      final row = rowLetter.codeUnitAt(0) - 65; // Преобразуем букву в индекс
      if (col == null || col < 0 || col >= size) {
        print('Неверный столбец, используйте цифры от 0 до ${size - 1}');
        continue;
      }

      if (direction != 'H' && direction != 'V') {
        print(
            'Направление может быть только H (горизонтально) или V (вертикально)');
        continue;
      }

      if (placeShip(ship, row, col, direction)) {
        print('Корабль "${ship.name}" успешно размещён.');
        break;
      } else {
        print('Ошибка размещения, попробуйте снова.');
      }
    }
  }

  // Метод для вывода поля с координатами
  void printFieldWithCoordinates({bool hideShips = false}) {
    stdout.write('  ');
    // Выводим номера столбцов
    for (int i = 0; i < size; i++) {
      stdout.write('$i ');
    }
    print('');
    // Выводим поле с координатами
    for (int i = 0; i < size; i++) {
      stdout.write('${String.fromCharCode(65 + i)} ');
      for (int j = 0; j < size; j++) {
        if (hideShips && grid[i][j] == 'S') {
          stdout.write('. ');
        } else {
          stdout.write('${grid[i][j]} ');
        }
      }
      print('');
    }
  }

  // Метод для случайного размещения кораблей
  void placeShipRandomly(Ship ship) {
    final random = Random();
    while (true) {
      final row = random.nextInt(size);
      final col = random.nextInt(size);
      final direction = random.nextBool() ? 'H' : 'V';
      if (placeShip(ship, row, col, direction)) {
        break;
      }
    }
  }

  // Метод для размещения корабля
  bool placeShip(Ship ship, int row, int col, String direction) {
    final int shipSize = ship.size;

    // Проверка на границы поля
    if (direction == 'H') {
      if (col + shipSize > size) return false;
    } else if (direction == 'V') {
      if (row + shipSize > size) return false;
    }

    // Проверка на наличие других кораблей в непосредственной близости
    for (int i = 0; i < shipSize; i++) {
      int r = direction == 'H' ? row : row + i;
      int c = direction == 'H' ? col + i : col;

      // Проверка на наличие корабля в текущей клетке
      if (grid[r][c] != '.') return false;

      // Проверка на наличие кораблей вокруг текущей клетки
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          int nr = r + dr;
          int nc = c + dc;
          if (nr >= 0 && nr < size && nc >= 0 && nc < size && grid[nr][nc] != '.') {
            return false;
          }
        }
      }
    }

    // Размещение корабля
    for (int i = 0; i < shipSize; i++) {
      int r = direction == 'H' ? row : row + i;
      int c = direction == 'H' ? col + i : col;
      grid[r][c] = 'S';
      ship.positions.add([r, c]);
    }

    ships.add(ship);
    return true;
  }

  // Метод для атаки
  bool receiveAttack(int row, int col) {
    if (grid[row][col] == 'S') {
      grid[row][col] = 'X';
      for (var ship in ships) {
        for (var pos in ship.positions) {
          if (pos[0] == row && pos[1] == col) {
            ship.hits++;
            print('Попадание!');
            if (ship.isSunk()) {
              print('Корабль "${ship.name}" уничтожен!');
            }
            return false;
          }
        }
      }
    } else if (grid[row][col] == '.') {
        grid[row][col] = 'O';
        print('Мимо!');
        return true;
    }
    return false;
  }

  // Метод для вывода поле без координат (во время игры)
  void printField({bool hideShips = false}) {
    for (var row in grid) {
      for (var cell in row) {
        if (hideShips && cell == 'S') {
          stdout.write('. ');
        } else {
          stdout.write('$cell ');
        }
      }
      print('');
    }
  }
}

// Класс для игрока
class Player {
  final String name;
  final GameField field;
  bool isBot;

  Player(this.name, int fieldSize, this.isBot) : field = GameField(fieldSize);

  void placeShips(List<Ship> ships) {
    if (isBot) {
      for (var ship in ships) {
        field.placeShipRandomly(ship);
      }
    } else {
      print('$name, расставьте свои корабли.');
      for (var ship in ships) {
        field.placeShipManually(ship);
      }
    }
  }

  void makeMove(Player opponent) {
    if (isBot) {
      final random = Random();
      while (true) {
        final row = random.nextInt(field.size);
        final col = random.nextInt(field.size);
        if (opponent.field.receiveAttack(row, col)) {
          break;
        }
      }
    } else {
      while (true) {
        print('Введите координаты для атаки (строка и столбец):');
        final input = stdin.readLineSync()!;
        final parts = input.split(' ');
        if (parts.length != 2) continue;

        final row = int.tryParse(parts[0]);
        final col = int.tryParse(parts[1]);
        if (row == null || col == null) continue;

        if (opponent.field.receiveAttack(row, col)) {
          break;
        }
      }
    }
  }
}

// Основной класс игры
class Game {
  late Player player1;
  late Player player2;

  void start() {
    print('Добро пожаловать в Морской Бой!');
    print('Выберите размер поля: 1) 10x10 2) 12x12 3) 14x14');
    final fieldSize = _selectFieldSize();

    print('Введите имя игрока 1:');
    final player1Name = stdin.readLineSync()!;
    print('Играть против бота? (y/n)');
    final playAgainstBot = stdin.readLineSync()!.toLowerCase() == 'y';
    final player2Name = playAgainstBot ? 'Бот' : stdin.readLineSync()!;

    player1 = Player(player1Name, fieldSize, false);
    player2 = Player(player2Name, fieldSize, playAgainstBot);

    final ships = _createShips(fieldSize);
    player1.placeShips(ships);
    player2.placeShips(ships);

    _gameLoop();
  }

  int _selectFieldSize() {
    while (true) {
      final input = stdin.readLineSync();
      if (input == '1') return 10;
      if (input == '2') return 12;
      if (input == '3') return 14;
      print('Неверный выбор, попробуйте снова.');
    }
  }

  List<Ship> _createShips(int fieldSize) {
    final shipSizes = fieldSize == 10
        ? [5, 4, 3, 3, 2]
        : fieldSize == 12
            ? [6, 5, 4, 3, 2]
            : [7, 6, 5, 4, 3];
    return List.generate(shipSizes.length,
        (i) => Ship('Корабль ${i + 1}', shipSizes[i]));
  }

  void _gameLoop() {
    var currentPlayer = player1;
    var opponent = player2;

    while (true) {
      print('\x1B[2J\x1B[0;0H');;
      print('Ходит игрок: ${currentPlayer.name}');
      print('Ваше поле:');
      currentPlayer.field.printField();
      print('Поле соперника:');
      opponent.field.printField(hideShips: true);

      currentPlayer.makeMove(opponent);

      if (opponent.field.ships.every((s) => s.isSunk())) {
        print('${currentPlayer.name} победил!');
        break;
      }

      // Смена хода
      final temp = currentPlayer;
      currentPlayer = opponent;
      opponent = temp;
    }
  }
}