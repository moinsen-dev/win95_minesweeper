# Minesweeper - Windows 95 Style

A faithful recreation of the classic Windows 95 Minesweeper game built with Flutter.

## Features

✨ **Authentic Windows 95 Design**
- Classic 3D button styling with beveled edges
- Windows 95 color scheme (iconic gray `#C0C0C0`)
- Seven-segment LED-style displays for timer and mine counter
- Retro smiley face reset button with different expressions

🎮 **Complete Gameplay**
- Three difficulty levels:
  - **Beginner**: 8×8 grid with 10 mines
  - **Intermediate**: 16×16 grid with 40 mines
  - **Expert**: 16×30 grid with 99 mines
- First click is always safe
- Auto-reveal empty cells
- Flag and question mark marking
- Win/lose detection
- Real-time timer
- Mine counter

🎯 **Classic Mechanics**
- Left click to reveal cells
- Right click (or long press) to flag/question mark
- Color-coded numbers (1-8) matching the original
- Game states: Ready, Playing, Won, Lost

## How to Run

```bash
cd minesweeper
flutter run
```

## How to Play

1. **Start a game**: The timer starts on your first click
2. **Reveal cells**: Tap on a cell to reveal it
3. **Mark mines**: Long-press or right-click to cycle through flag → question mark → normal
4. **Numbers**: Show how many mines are adjacent to that cell
5. **Win condition**: Reveal all non-mine cells
6. **Change difficulty**: Use the menu button in the top-right corner

## Controls

- **Tap**: Reveal cell
- **Long press / Right click**: Cycle flag states (flag → ? → normal)
- **Smiley button**: Reset game
- **Menu button**: Change difficulty

## Technical Details

- **Framework**: Flutter 3.35.5
- **State Management**: ChangeNotifier
- **UI Design**: Custom Windows 95-style widgets
- **Responsive**: Adapts to different screen sizes

## Project Structure

```
lib/
├── models/
│   ├── cell.dart           # Cell data model
│   ├── difficulty.dart     # Difficulty levels
│   └── game_state.dart     # Game state enum
├── game/
│   └── minesweeper_game.dart  # Core game logic
├── widgets/
│   ├── cell_widget.dart       # Individual cell UI
│   ├── game_board.dart        # Grid layout
│   ├── game_header.dart       # Timer, counter, reset
│   ├── seven_segment_display.dart  # LED-style numbers
│   ├── win95_button.dart      # Windows 95 button style
│   └── win95_panel.dart       # Windows 95 panel style
├── screens/
│   └── game_screen.dart       # Main game screen
└── main.dart                  # App entry point
```

## Screenshots

The app features:
- Authentic beveled 3D buttons
- Classic gray color scheme
- Red LED-style digital displays
- Colored number indicators (blue=1, green=2, red=3, etc.)
- Smiley face that changes based on game state

## License

This is a recreation of the classic Minesweeper game for educational purposes.

---

Built with ❤️ using Flutter
