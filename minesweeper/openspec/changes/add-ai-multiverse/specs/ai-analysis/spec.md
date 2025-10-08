# AI Analysis Specification

## ADDED Requirements

### Requirement: Board Probability Calculation
The system SHALL calculate mine probability for each unrevealed cell using constraint satisfaction and Bayesian inference.

#### Scenario: Probability calculation success
- **WHEN** board analysis is requested for a partially revealed board
- **THEN** mine probability (0.0-1.0) is calculated for each unrevealed cell
- **AND** calculations complete within 1000ms for expert difficulty (30x16)
- **AND** calculations complete within 200ms for beginner difficulty (9x9)

#### Scenario: Computation in isolate
- **WHEN** probability calculation is triggered
- **THEN** heavy computation runs in separate isolate
- **AND** UI thread remains responsive during calculation
- **AND** loading indicator displays if calculation exceeds 200ms

### Requirement: Safe Move Identification
The system SHALL identify cells that are guaranteed safe (100% safe, 0% mine probability) based on current board state.

#### Scenario: Safe moves found
- **WHEN** board has logically deducible safe cells
- **THEN** all guaranteed safe cells are identified
- **AND** safe moves list is ordered by desirability (corners, edges, centers)
- **AND** no false positives exist (all identified cells are truly safe)

#### Scenario: No safe moves available
- **WHEN** board requires guessing (no logical deductions possible)
- **THEN** safe moves list is empty
- **AND** lowest-risk cells are provided as alternatives
- **AND** user is informed that guessing is required

### Requirement: Pattern Recognition
The system SHALL detect common Minesweeper patterns (1-2-1, 1-2-2-1, corners, edges) in the current board state.

#### Scenario: Pattern detection
- **WHEN** board analysis is performed
- **THEN** all instances of known patterns are detected
- **AND** pattern positions and types are reported
- **AND** detection completes in <100ms

#### Scenario: Pattern templates
- **WHEN** querying available patterns
- **THEN** library includes at minimum: 1-2-1, 1-2-2-1, corner tricks, edge strategies
- **AND** each pattern has name, description, and explanation
- **AND** patterns can be added without code changes (data-driven)

### Requirement: Constraint Satisfaction Solver
The system SHALL use CSP (Constraint Satisfaction Problem) solving to analyze board consistency and derive logical conclusions.

#### Scenario: CSP solving
- **WHEN** CSP solver analyzes revealed number constraints
- **THEN** all logical deductions are made
- **AND** contradictions are detected (indicates board error)
- **AND** solution uniqueness is determined

#### Scenario: Solver performance
- **WHEN** CSP solver runs on expert board
- **THEN** constraint propagation completes within 500ms
- **AND** backtracking (if needed) completes within 1000ms

### Requirement: Probability Heatmap Generation
The system SHALL generate visual heatmap data for overlay rendering based on calculated probabilities.

#### Scenario: Heatmap data structure
- **WHEN** heatmap is generated
- **THEN** each unrevealed cell has assigned color based on probability
- **AND** color scheme: green (0-20%), yellow (20-50%), orange (50-80%), red (80-100%)
- **AND** heatmap updates in real-time as board state changes

#### Scenario: Heatmap customization
- **WHEN** user changes heatmap color scheme in settings
- **THEN** new color mapping is applied
- **AND** customization persists across sessions

### Requirement: Optimal Move Recommendation
The system SHALL recommend the single best move based on probability analysis and game strategy.

#### Scenario: Best move recommendation
- **WHEN** user requests hint or AI assistant provides suggestion
- **THEN** highest-confidence safe move is recommended
- **AND** if no safe moves exist, lowest-risk move is recommended
- **AND** recommendation includes confidence percentage
- **AND** reasoning is provided ("This cell has 95% chance of being safe because...")

#### Scenario: Multiple safe moves
- **WHEN** multiple cells are equally safe (100% safe)
- **THEN** move closest to revealing largest area is prioritized
- **AND** corner/edge moves are favored for strategic advantage

### Requirement: Board Solvability Verification
The system SHALL determine whether a given board can be solved using pure logic (no guessing required).

#### Scenario: Solvable board
- **WHEN** solvability analysis runs on a fully logical board
- **THEN** result is "solvable" with confidence 100%
- **AND** analysis completes within 2000ms for expert boards

#### Scenario: Unsolvable board requiring guessing
- **WHEN** solvability analysis runs on board requiring luck
- **THEN** result indicates "guessing required"
- **AND** first guess point is identified
- **AND** estimated guess probability is provided

### Requirement: Analysis Result Caching
The system SHALL cache analysis results until board state changes to avoid redundant calculations.

#### Scenario: Cache hit
- **WHEN** analysis is requested for unchanged board state
- **THEN** cached results are returned immediately
- **AND** no recalculation occurs

#### Scenario: Cache invalidation
- **WHEN** user reveals or flags a cell
- **THEN** cached analysis is invalidated
- **AND** next analysis request triggers fresh calculation

### Requirement: Pattern Explanation Generation
The system SHALL generate human-readable explanations for detected patterns.

#### Scenario: Pattern explanation
- **WHEN** pattern is detected and user requests explanation
- **THEN** clear text description is provided (e.g., "This is a 1-2-1 pattern. The cell between two 1s and adjacent to a 2 is always safe.")
- **AND** visual highlighting shows pattern cells
- **AND** explanation uses retro language style

### Requirement: Multi-Level Analysis Depth
The system SHALL support multiple analysis depth levels: quick (surface-level), standard (full CSP), deep (Monte Carlo simulation).

#### Scenario: Quick analysis mode
- **WHEN** quick analysis is requested
- **THEN** only immediate logical deductions are performed
- **AND** analysis completes in <50ms
- **AND** result includes confidence level

#### Scenario: Deep analysis mode
- **WHEN** deep analysis is requested for ambiguous board
- **THEN** Monte Carlo simulation runs with 1000+ iterations
- **AND** probability estimates are highly accurate
- **AND** analysis completes within 5000ms

### Requirement: Error Handling for Invalid Boards
The system SHALL gracefully handle and report invalid or corrupted board states.

#### Scenario: Inconsistent board state
- **WHEN** CSP solver detects contradictory constraints
- **THEN** error is reported with details
- **AND** application does not crash
- **AND** user is informed board may be corrupted

#### Scenario: Null or empty board
- **WHEN** analysis is requested on null/empty board
- **THEN** appropriate error is returned
- **AND** no computation is performed
