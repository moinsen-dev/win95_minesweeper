# Game History Specification

## ADDED Requirements

### Requirement: Complete Game State History
The system SHALL record complete game state snapshot after every player move for "Time Machine" analysis (Dimension 4).

#### Scenario: Move history recording
- **WHEN** player reveals or flags a cell
- **THEN** complete board state is captured (cell states, flags, time, game status)
- **AND** snapshot is appended to history
- **AND** history remains accessible for current game session

#### Scenario: History memory management
- **WHEN** game history exceeds 1000 moves
- **THEN** oldest moves beyond 500 are pruned
- **AND** critical decision points are preserved
- **AND** memory usage remains under 50MB per game

### Requirement: Rewind Functionality
The system SHALL allow players to rewind game to any previous move state.

#### Scenario: Rewind to specific move
- **WHEN** player selects move N in history timeline
- **THEN** game board reverts to state after move N
- **AND** all subsequent moves are preserved but marked as "alternate timeline"
- **AND** player can play forward from that point

#### Scenario: Rewind UI
- **WHEN** Time Machine dimension is active
- **THEN** timeline slider shows all moves
- **AND** dragging slider scrubs through history in real-time
- **AND** current move is clearly marked

### Requirement: "What If" Scenario Analysis
The system SHALL analyze alternate realities: "What if you'd clicked HERE instead at move N?"

#### Scenario: Alternate move exploration
- **WHEN** player rewound to move N and selects different cell
- **THEN** system simulates outcome of that choice
- **AND** probability of success is calculated
- **AND** comparison to actual path is shown

#### Scenario: Branching timeline visualization
- **WHEN** player creates alternate timeline by making different move
- **THEN** decision tree shows: original path vs. new path
- **AND** outcomes are visually compared
- **AND** player can switch between timelines

### Requirement: "Where It Went Wrong" Analysis
The system SHALL identify the critical move where game became unwinnable (if applicable).

#### Scenario: Loss post-mortem
- **WHEN** player loses game and enters Time Machine dimension
- **THEN** AI analyzes history to find first bad decision
- **AND** message shown: "This is where things went wrong - Move 17"
- **AND** move is highlighted in timeline
- **AND** explanation provided for why it was wrong

#### Scenario: Unavoidable loss detection
- **WHEN** player lost due to forced guess with bad luck
- **THEN** analysis shows: "This was unavoidable - you made the best choice"
- **AND** guess probability is displayed
- **AND** no blame assigned to player strategy

### Requirement: Safe Path Visualization
The system SHALL show all possible safe paths player missed after game ends.

#### Scenario: Missed opportunities display
- **WHEN** player views post-game analysis
- **THEN** all cells that were logically deducible as safe are highlighted
- **AND** alternate winning paths are shown
- **AND** comparison: "You could have won by revealing these 5 cells"

### Requirement: Butterfly Effect Visualization
The system SHALL show how single move changes cascade through entire game.

#### Scenario: Move impact analysis
- **WHEN** player selects move in history
- **THEN** system highlights all subsequently affected cells
- **AND** animation shows ripple effect of information revealed
- **AND** explanation: "This move revealed 8 cells and unlocked 3 safe deductions"

#### Scenario: Butterfly effect comparison
- **WHEN** comparing alternate timelines
- **THEN** visualization shows divergence point
- **AND** downstream effects are color-coded
- **AND** outcome difference is quantified (time saved, mines avoided)

### Requirement: Decision Point Identification
The system SHALL automatically identify critical decision points where multiple valid strategies existed.

#### Scenario: Key decision marking
- **WHEN** analyzing game history
- **THEN** moves with 2+ viable options are marked as "decision points"
- **AND** decision points appear as nodes on timeline
- **AND** clicking shows what alternatives were available

### Requirement: Replay Mode with Annotations
The system SHALL allow replaying entire game with AI commentary on each move.

#### Scenario: Annotated replay
- **WHEN** player starts annotated replay
- **THEN** game replays move-by-move with commentary
- **AND** AI explains: "Good choice", "Risky but acceptable", "Better option was available"
- **AND** playback speed is adjustable

### Requirement: Export Game History
The system SHALL allow exporting game history as shareable data or video replay.

#### Scenario: History export
- **WHEN** player chooses to export game
- **THEN** game moves are encoded as share code
- **AND** code can be shared with others
- **AND** recipients can import and view replay

### Requirement: Compare Attempts on Same Board
The system SHALL allow playing same board multiple times and comparing approaches.

#### Scenario: Retry with comparison
- **WHEN** player retries same board configuration
- **THEN** ghost of previous attempt is shown
- **AND** player can compare decision-making in real-time
- **AND** both timelines are preserved for analysis

### Requirement: Time Travel UI Controls
The system SHALL provide intuitive timeline scrubber with move-by-move navigation.

#### Scenario: Timeline scrubber interaction
- **WHEN** player uses timeline scrubber
- **THEN** dragging shows smooth board state transitions
- **AND** move numbers and timestamps are labeled
- **AND** decision points are visually marked on scrubber

#### Scenario: Keyboard navigation
- **WHEN** player uses arrow keys
- **THEN** left arrow = previous move, right arrow = next move
- **AND** Ctrl+Home = game start, Ctrl+End = current position
- **AND** keyboard shortcuts are discoverable via tooltip

### Requirement: History Persistence
The system SHALL optionally persist game histories across sessions for later analysis.

#### Scenario: Save history for later
- **WHEN** player chooses to save game history
- **THEN** history is stored locally with metadata (date, difficulty, outcome)
- **AND** saved histories are browsable in library
- **AND** storage is limited to last 20 games

#### Scenario: Load saved history
- **WHEN** player loads saved history from library
- **THEN** game is restored to final state
- **AND** full timeline is accessible
- **AND** time travel features work on loaded history

### Requirement: Probability Evolution Visualization
The system SHALL show how mine probabilities evolved throughout game as information was revealed.

#### Scenario: Probability timeline
- **WHEN** viewing specific cell in history mode
- **THEN** chart shows probability changes over time
- **AND** key revelations that affected probability are marked
- **AND** visualization helps understand information cascades

### Requirement: Learning from Mistakes
The system SHALL extract lessons from game history and suggest improvements.

#### Scenario: Lesson extraction
- **WHEN** player finishes analyzing game history
- **THEN** 1-3 key lessons are summarized
- **AND** lessons are specific: "Opening with corners reveals more information"
- **AND** lessons are linked to specific moves in history
