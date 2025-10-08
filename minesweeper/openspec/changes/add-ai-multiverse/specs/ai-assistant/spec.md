# AI Assistant Specification

## ADDED Requirements

### Requirement: Assistant Character Display
The system SHALL display an animated assistant character (pixel art robot or helper) in Dimension 1 (AI Assistant Mode).

#### Scenario: Assistant appears on activation
- **WHEN** user switches to AI Assistant dimension
- **THEN** assistant character appears with entrance animation
- **AND** character is positioned non-intrusively on screen
- **AND** character design matches Win95 retro aesthetic

#### Scenario: Assistant hides on deactivation
- **WHEN** user switches away from AI Assistant dimension
- **THEN** assistant character plays exit animation and disappears
- **AND** no assistant UI remains visible

### Requirement: Contextual Hint Generation
The system SHALL provide contextual hints based on current board state and player situation.

#### Scenario: Hint request with safe moves
- **WHEN** user requests hint and safe moves exist
- **THEN** assistant suggests safest move with confidence level
- **AND** suggestion format: "Cell C4 is 95% safe!"
- **AND** visual indicator highlights suggested cell

#### Scenario: Hint request with no safe moves
- **WHEN** user requests hint and no guaranteed safe moves exist
- **THEN** assistant suggests lowest-risk option
- **AND** acknowledges uncertainty: "This is a tough spot! Cell B2 has only 35% mine chance - lowest risk available."

#### Scenario: Stuck player detection
- **WHEN** player hasn't moved for >30 seconds
- **THEN** assistant proactively offers hint
- **AND** message appears: "It looks like you're trying to not explode! Want help?"

### Requirement: Multiple Personality Modes
The system SHALL support four distinct assistant personalities: Encouraging, Strategic, Humorous, and Zen Master.

#### Scenario: Encouraging personality
- **WHEN** assistant personality is set to Encouraging
- **THEN** messages use positive reinforcement: "Great job! You're doing amazing!"
- **AND** mistakes are met with support: "No worries, we all hit mines sometimes!"

#### Scenario: Strategic personality
- **WHEN** assistant personality is set to Strategic
- **THEN** messages focus on tactics: "Optimal move: reveal corner first for maximum information gain."
- **AND** explanations are analytical and detailed

#### Scenario: Humorous personality
- **WHEN** assistant personality is set to Humorous
- **THEN** messages include jokes and puns: "That mine really blew your chances!"
- **AND** tone is lighthearted and entertaining

#### Scenario: Zen Master personality
- **WHEN** assistant personality is set to Zen Master
- **THEN** messages are philosophical: "The safe cell is within you."
- **AND** hints are cryptic yet helpful

### Requirement: Confidence Level Display
The system SHALL display confidence percentage (0-100%) for all suggestions and hints.

#### Scenario: High confidence suggestion
- **WHEN** assistant suggests move with >90% confidence
- **THEN** confidence is displayed: "95% safe"
- **AND** visual indicator shows high confidence (green)

#### Scenario: Low confidence suggestion
- **WHEN** assistant suggests move with <50% confidence
- **THEN** confidence is displayed: "Only 30% safe - risky!"
- **AND** visual indicator shows low confidence (red/orange)
- **AND** warning is included about risk level

### Requirement: Clippy-Style Messaging
The system SHALL use retro 90s tech language reminiscent of Microsoft Clippy.

#### Scenario: Classic Clippy phrasing
- **WHEN** assistant provides any message
- **THEN** phrasing matches style: "It looks like you're trying to [action]!"
- **AND** messages use 90s terminology: "Analyzing board configuration...", "Neural network activated"

#### Scenario: Friendly tone maintenance
- **WHEN** delivering any message
- **THEN** tone remains friendly and helpful
- **AND** never condescending or patronizing

### Requirement: Real-Time Board Analysis Display
The system SHALL show assistant's "thinking process" when analyzing the board.

#### Scenario: Analysis visualization
- **WHEN** assistant is analyzing board state
- **THEN** thinking animation plays (Matrix-style cascading numbers or progress bar)
- **AND** status text shows: "Computing probabilities..." or "Engaging expert system..."
- **AND** analysis completes within 1000ms or shows progress

#### Scenario: Analysis completion
- **WHEN** analysis finishes
- **THEN** thinking animation stops
- **AND** result is presented with smooth transition

### Requirement: Pattern Education
The system SHALL explain detected patterns when assistant provides hints related to them.

#### Scenario: Pattern-based hint
- **WHEN** suggested move is based on recognized pattern
- **THEN** assistant explains pattern: "I spotted a 1-2-1 pattern here! The middle cell is always safe."
- **AND** pattern is visually highlighted on board
- **AND** educational tooltip is shown

### Requirement: Progressive Disclosure
The system SHALL offer hints at increasing detail levels: vague hint → specific hint → show answer.

#### Scenario: First hint level
- **WHEN** user requests first hint
- **THEN** vague guidance is provided: "Look at the top-left area"
- **AND** no specific cell is revealed

#### Scenario: Second hint level
- **WHEN** user requests second hint on same situation
- **THEN** more specific guidance: "Focus on cells around the 2 in row 3"
- **AND** area is highlighted but specific cell not revealed

#### Scenario: Third hint level - full answer
- **WHEN** user requests third hint on same situation
- **THEN** exact move is shown with confidence
- **AND** reasoning is fully explained

### Requirement: Win Celebration and Loss Sympathy
The system SHALL respond appropriately to game outcomes with personality-appropriate messages.

#### Scenario: Win celebration
- **WHEN** player wins game with assistant active
- **THEN** assistant celebrates: "Excellent work! You cleared all mines!"
- **AND** celebration matches personality mode
- **AND** optional confetti or visual effect plays

#### Scenario: Loss sympathy
- **WHEN** player hits mine with assistant active
- **THEN** assistant provides sympathy: "That was a tough guess. Want to try again?"
- **AND** response matches personality mode
- **AND** optional "what went wrong" analysis is offered

### Requirement: Assistant Panel UI
The system SHALL provide a collapsible panel showing assistant character, messages, and controls.

#### Scenario: Panel structure
- **WHEN** AI Assistant dimension is active
- **THEN** panel displays: avatar, message bubble, suggested moves, action buttons
- **AND** panel can be collapsed to minimize screen space
- **AND** panel uses Win95-style window chrome

#### Scenario: Panel interactions
- **WHEN** user clicks hint button
- **THEN** assistant generates and displays new hint
- **AND** button shows loading state during analysis
- **AND** result appears with animation

### Requirement: Hint Cooldown Prevention
The system SHALL prevent hint spam by implementing reasonable cooldown periods.

#### Scenario: Cooldown enforcement
- **WHEN** user requests hint
- **AND** less than 5 seconds since last hint
- **THEN** cooldown message is shown: "Let's give that last hint a moment to sink in!"
- **AND** button is disabled until cooldown expires

#### Scenario: Cooldown exceptions
- **WHEN** board state significantly changes (3+ cells revealed)
- **THEN** hint cooldown is reset
- **AND** new hint can be requested immediately

### Requirement: Personality Customization
The system SHALL allow users to change assistant personality via settings or in-game toggle.

#### Scenario: Personality change
- **WHEN** user selects different personality
- **THEN** assistant acknowledges change with new personality
- **AND** all subsequent messages use new personality style
- **AND** preference is persisted across sessions

### Requirement: Assistant Silence Mode
The system SHALL provide option to keep assistant visible but reduce message frequency (visual only mode).

#### Scenario: Silence mode enabled
- **WHEN** user enables silence mode
- **THEN** assistant character remains visible
- **AND** proactive messages are suppressed
- **AND** hints are only provided when explicitly requested
- **AND** visual indicators (confidence colors) still function
