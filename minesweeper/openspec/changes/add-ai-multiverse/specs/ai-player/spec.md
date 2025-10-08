# AI Player Specification

## ADDED Requirements

### Requirement: Ghost Player Demo Mode
The system SHALL provide demo mode (Dimension 3) where AI solves the current board while explaining its decisions.

#### Scenario: Demo mode activation
- **WHEN** user switches to Ghost Player dimension
- **THEN** AI begins solving current board from its state
- **AND** AI plays with same constraints (cannot see mines)
- **AND** demo starts in paused state awaiting user command

#### Scenario: Demo mode with new board
- **WHEN** Ghost Player dimension activates with fresh game
- **THEN** new board is generated
- **AND** AI starts from initial state
- **AND** user can observe from beginning

### Requirement: Optimal Move Strategy
The system SHALL use Monte Carlo tree search or CSP-based solving to determine optimal moves with >95% success rate on solvable boards.

#### Scenario: Optimal play on solvable board
- **WHEN** AI plays on logically solvable board
- **THEN** AI makes only safe moves until completion or guess required
- **AND** AI successfully solves ≥95% of solvable expert boards
- **AND** AI never makes illogical moves

#### Scenario: Guess handling
- **WHEN** AI encounters board requiring guess
- **THEN** AI selects lowest-probability mine cell
- **AND** AI explains: "No logical moves available. Choosing cell with 25% mine probability."

### Requirement: Move Explanation Generation
The system SHALL generate natural language explanations for each AI move showing reasoning process.

#### Scenario: Logical move explanation
- **WHEN** AI makes move based on constraint satisfaction
- **THEN** explanation is displayed: "Cell B3 must be safe because the 1 at A2 already has its mine flagged at A1."
- **AND** relevant cells are visually highlighted
- **AND** explanation uses simple, clear language

#### Scenario: Probabilistic move explanation
- **WHEN** AI makes move based on probability
- **THEN** explanation includes percentages: "Cell E5 has 85% safe probability based on surrounding constraints."
- **AND** calculation reasoning is summarized

### Requirement: Playback Controls
The system SHALL provide VCR-style playback controls: rewind, backward step, pause, play, forward step, fast-forward.

#### Scenario: Play control
- **WHEN** user presses play button
- **THEN** AI makes next move
- **AND** waits for configurable delay before next move
- **AND** explanation is shown during pause

#### Scenario: Pause control
- **WHEN** user presses pause during playback
- **THEN** AI stops after completing current move
- **AND** current state is frozen
- **AND** user can examine board

#### Scenario: Step forward
- **WHEN** user presses forward step while paused
- **THEN** AI makes exactly one move
- **AND** playback remains paused
- **AND** explanation is displayed

#### Scenario: Step backward
- **WHEN** user presses backward step
- **THEN** game state reverts to previous move
- **AND** board shows state before last AI action
- **AND** move history pointer moves backward

#### Scenario: Fast-forward
- **WHEN** user presses fast-forward
- **THEN** AI makes moves rapidly (10x speed)
- **AND** explanations are suppressed or abbreviated
- **AND** user can still pause at any time

### Requirement: Adjustable Playback Speed
The system SHALL allow users to adjust AI playback speed from 0.25x to 10x normal speed.

#### Scenario: Speed adjustment
- **WHEN** user changes playback speed slider
- **THEN** delay between moves adjusts accordingly
- **AND** 1x speed = ~1 second per move
- **AND** speed change takes effect on next move

### Requirement: Interactive "Why" Query
The system SHALL allow users to pause and ask "Why did you click there?" for any AI move.

#### Scenario: Why query on recent move
- **WHEN** user pauses playback and selects "Why?" button
- **THEN** detailed explanation of last move is shown
- **AND** explanation includes: constraint analysis, probability calculations, alternative moves considered
- **AND** visual diagram highlights relevant board areas

### Requirement: Split-Screen Comparison Mode
The system SHALL provide optional split-screen where user plays left side and AI plays identical right side simultaneously.

#### Scenario: Split-screen activation
- **WHEN** user enables split-screen mode
- **THEN** screen divides into two identical boards
- **AND** left board accepts user input
- **AND** right board shows AI moves in real-time
- **AND** both boards have same mine layout

#### Scenario: Split-screen synchronization
- **WHEN** user makes move on left board
- **THEN** AI continues playing right board
- **AND** user can compare their progress to AI
- **AND** both sides remain synchronized

#### Scenario: Split-screen outcome
- **WHEN** either player wins or loses
- **THEN** both boards continue until both finish
- **AND** completion times are compared
- **AND** result shows who solved faster

### Requirement: Ghost Racing Mode
The system SHALL support racing against AI opponent(s) on identical boards (Dimension 8).

#### Scenario: Race start
- **WHEN** user enters Ghost Racing dimension
- **THEN** new board is generated
- **AND** user and AI(s) start simultaneously
- **AND** race timer begins

#### Scenario: AI opponent skill levels
- **WHEN** user selects AI opponent
- **THEN** opponent skill can be chosen: Beginner, Intermediate, Expert, Pro
- **AND** AI difficulty affects move speed and risk tolerance
- **AND** lower difficulty AI makes sub-optimal moves occasionally

#### Scenario: Race completion
- **WHEN** either player completes board first
- **THEN** winner is announced
- **AND** completion times are displayed
- **AND** both players can finish for full comparison

### Requirement: Replay Ghost Visualization
The system SHALL display ghost replays as transparent overlay showing previous attempts or other players' solutions.

#### Scenario: Personal best ghost
- **WHEN** user plays board they've solved before
- **THEN** transparent ghost of best previous attempt appears
- **AND** ghost moves are shown at same time points
- **AND** user can race against own best time

#### Scenario: Ghost transparency control
- **WHEN** user adjusts ghost opacity setting
- **THEN** ghost visualization opacity changes (0-50%)
- **AND** ghosts never fully obscure current game

### Requirement: AI Play Style Configuration
The system SHALL support multiple AI play styles: Conservative (slow, cautious), Aggressive (fast, risky), Optimal (balanced).

#### Scenario: Conservative AI
- **WHEN** AI play style is Conservative
- **THEN** AI always chooses safest available move
- **AND** AI takes longer to decide on ambiguous situations
- **AND** AI only guesses when absolutely necessary

#### Scenario: Aggressive AI
- **WHEN** AI play style is Aggressive
- **THEN** AI accepts higher risk for faster completion
- **AND** AI guesses earlier rather than full analysis
- **AND** AI prioritizes speed over perfection

#### Scenario: Optimal AI
- **WHEN** AI play style is Optimal
- **THEN** AI balances safety and speed
- **AND** AI uses full CSP solving before guessing
- **AND** AI chooses information-maximizing moves

### Requirement: Thought Bubble Visualization
The system SHALL display AI's current thoughts in comic-style thought bubbles above board.

#### Scenario: Thought bubble display
- **WHEN** AI is deciding next move
- **THEN** thought bubble appears with current analysis
- **AND** text rotates through: "Analyzing constraints...", "Calculating probabilities...", "Found safe move!"
- **AND** bubble uses retro pixelated styling

### Requirement: Learning from AI Demonstration
The system SHALL track which patterns and strategies user observes from AI play.

#### Scenario: Pattern observation tracking
- **WHEN** AI demonstrates specific pattern (e.g., 1-2-1)
- **THEN** system records that pattern was shown
- **AND** Pattern Sensei dimension can reference observed patterns
- **AND** user is credited with "having seen" this strategy

### Requirement: AI Performance Statistics
The system SHALL track and display AI performance statistics: win rate, average time, efficiency metrics.

#### Scenario: Statistics display
- **WHEN** user views AI statistics
- **THEN** metrics shown: games played, win rate, average completion time, perfect games
- **AND** statistics are broken down by difficulty level
- **AND** comparison to user's own stats is available
