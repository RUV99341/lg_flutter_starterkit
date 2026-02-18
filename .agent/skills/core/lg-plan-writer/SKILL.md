---
name: Liquid Galaxy Flutter Plan Writer
description: Converts validated brainstorm logic into a deterministic, executable Flutter + Liquid Galaxy implementation plan.
---

# 📝 Liquid Galaxy Flutter Implementation Planning

Pipeline:

Init → Brainstorm → Plan → Execute → Review → Quiz

This is Stage 3.

Brainstorm validated logic and created design document.
This stage converts design into deterministic implementation tasks.

No brainstorming. No architecture debate. Only execution planning.

---

# ⚠️ PROMINENT GUARDRAIL

Do NOT generate a plan if the student cannot:

- Restate the full data flow from design doc
- Justify their Master-only vs Parallel choice
- Explain ghosting prevention (clearKML timing)
- Explain why logo uses sendScreenOverlay() not sendKML()

If they fail → activate `lg-skeptical-mentor`.

No plan without understanding.

---

# 🧠 Activation Statement

Say:

"I am using the lg-plan-writer skill to generate your deterministic Flutter Liquid Galaxy implementation plan based on your validated design document."

## 🔀 Workflow-Specific Planning

Generate the implementation plan based on the active mode:

- **mode: api-only**:
  - **Focus**: `ApiService`, `DataModels`, `Repository`, and unit tests for HTTP failures.
  - **Skip**: UI Widgets and KML Builder logic.
  
- **mode: screen-only**:
  - **Focus**: UI layer, `View`, `Controller/ViewModel`, and Widget tests.
  - **Skip**: SSH logic and external API implementation.

- **mode: full**:
  - **Focus**: Complete vertical slice implementation (Service → Domain → UI).

---

### 📝 Canonical Commit Format
Every task in the implementation plan must use this exact structure:
**Format:** `<type>(<scope>): <description>`

**Allowed Types:** `feat`, `fix`, `refactor`, `test`, `docs`, `chore`
**Allowed Scopes:** `services`, `core`, `presentation`, `domain`, `data`, `test`, `docs`

**Example Plan Task:**
- [ ] Task: Implement PyramidService
- [ ] Command: `git commit -m "feat(services): add PyramidService with ghosting prevention"`

---

# 🔍 Foundation Verification (MANDATORY FIRST STEP)

Before generating any plan, verify the initialized foundation exists:

**Step 1: Verify LGConnectionService Exists**

Ask student: "Run this command and paste the output:"
```bash
cat lib/services/lg_connection_service.dart | grep "Future<void>"
```

**Expected Output Must Include ALL FOUR methods:**
```dart
Future<void> connect(String host, String username, String password) async {}
Future<void> sendKML(String kml) async {}
Future<void> clearKML() async {}
Future<void> sendScreenOverlay({
```

**If ANY method is missing:**
→ STOP immediately
→ Say: "Your initialized LGConnectionService is incomplete or missing. Please return to lg-project-initializer Phase 5 and verify all methods are scaffolded."
→ DO NOT generate a plan
→ Activate `lg-skeptical-mentor`

---

**Step 2: Verify LGConfig Exists**

Ask student: "Run this command:"
```bash
cat lib/core/constants/lg_config.dart | grep "worldWidth"
```

**Expected output:**
```dart
static int get worldWidth => screenWidth * screenCount;
```

**If file is missing:**
→ STOP immediately
→ Say: "LGConfig not found. Return to lg-project-initializer Phase 3."
→ DO NOT proceed

---

**Step 3: Verify Test Directory Structure**

Ask student: "Run this command:"
```bash
ls test/ 2>/dev/null || echo "MISSING"
```

**Expected**: Directory listing (not "MISSING")

**If missing:**
→ Create test directory: `mkdir -p test/mocks test/services test/core/utils`
→ Inform student this was created

---

## Foundation Verification Result

**Only if ALL verifications pass:**
→ Say: "✅ Foundation verified. Proceeding with plan generation."

**If ANY verification failed:**
→ STOP
→ List missing components
→ Direct student back to appropriate initialization phase
→ DO NOT proceed with plan generation

---

# 📖 Design Document Integration (MANDATORY)

Before generating plan, read and parse the design document created in brainstormer.

**Step 1: Verify Design Document Exists**

Ask student: "Run this command:"
```bash
ls docs/plans/*T2-design.md 2>/dev/null | head -1
```

**Expected**: File path (e.g., `docs/plans/2025-02-16-T2-design.md`)

**If no file found:**
→ STOP immediately
→ Say: "Cannot generate plan without design document. Run `lg-brainstormer` first to create the design document."
→ DO NOT proceed
→ Activate `lg-skeptical-mentor`

---

**Step 2: Extract Architecture Strategy**

Ask student: "Run this command:"
```bash
grep "Architecture Strategy:" docs/plans/*T2-design.md
```

**Expected output format:**
```
**Architecture Strategy**: (Parallel / Master-only) - [Justification]
```

**Parse the strategy**:
- If contains "Parallel" → Architecture = Parallel
- If contains "Master-only" → Architecture = Master-only
- If neither → Error

**If strategy not found or unclear:**
→ STOP
→ Say: "Design document doesn't specify Architecture Strategy clearly. Please update Section 1 of your design document with either 'Parallel' or 'Master-only'."
→ DO NOT proceed

---

**Step 3: Extract LG Method Usage**

Ask student: "Run this command:"
```bash
grep -A 3 "LG Method Usage:" docs/plans/*T2-design.md
```

**Expected output format:**
```
**LG Method Usage**:
- `clearKML()`: [When called]
- `sendKML()`: [When called]
- `sendScreenOverlay()`: [When called]
```

**Verify all three methods are listed.**

**If any method missing:**
→ STOP
→ Say: "Design document incomplete. Section 5 must list when all three LG methods are called."
→ DO NOT proceed

---

**Step 4: Extract Failure Cases**

Ask student: "Run this command:"
```bash
grep -A 5 "Failure Cases Prevented:" docs/plans/*T2-design.md | grep "Failure Case"
```

**Expected**: List of failure cases (minimum 2)

**These will be referenced in task prevention notes.**

---

## Design Document Verification Result

**Only if ALL extractions succeed:**
→ Say: "✅ Design document parsed successfully. Architecture: [Parallel/Master-only]. Generating plan based on your design decisions."

**If ANY extraction failed:**
→ STOP
→ Specify which field is missing
→ Direct student to update design document
→ DO NOT proceed with plan generation

---

# 🚫 Service Integration Rule (ENFORCED)

The plan MUST use ONLY the methods scaffolded in `LGConnectionService`:

- `connect(String host, String username, String password)`
- `clearKML()`
- `sendKML(String kml)`
- `sendScreenOverlay({required String imageUrl, required double overlayX, required double overlayY, double sizeX, double sizeY})`

**Forbidden in plan**:
❌ Creating new SSH service classes
❌ Creating new socket connection classes
❌ Duplicating SSH logic
❌ Direct dartssh2 usage outside LGConnectionService

**If plan violates this rule:**
→ Plan is invalid
→ Reject and regenerate

---

# 📂 Plan Save Location

Save plan to:

`docs/plans/YYYY-MM-DD-T2-plan.md`

Where `YYYY-MM-DD` matches the design document date.

Example: If design doc is `2025-02-16-T2-design.md`, plan is `2025-02-16-T2-plan.md`

**Critical**: Plan MUST be saved before execution begins.

---

# 📄 Plan Header Format (STRICT)

Every plan MUST start with this exact header structure:

```markdown
# Liquid Galaxy T2 Demo - Implementation Plan

**Date**: YYYY-MM-DD
**Design Document**: docs/plans/YYYY-MM-DD-T2-design.md
**Architecture Strategy**: [Parallel / Master-only] (as extracted from design doc)

---

## 🎯 Implementation Goal

[Copy from design doc "Goal" field]

---

## 🏗 Architecture Decision

**Chosen Strategy**: [Parallel / Master-only]

**Justification**: [Copy from design doc Section 9 "Trade-Off Decision"]

**Technical Implications**:
- [List based on strategy]

---

## 🔧 LG Method Usage Plan

| Method | When Called | Purpose |
|--------|------------|---------|
| `clearKML()` | [From design doc] | [Purpose] |
| `sendKML()` | [From design doc] | [Purpose] |
| `sendScreenOverlay()` | [From design doc] | [Purpose] |

---

## 🛡 Failure Cases This Plan Prevents

- [ ] [Failure Case #1 from design doc]
- [ ] [Failure Case #2 from design doc]
- [ ] [Failure Case #3 from design doc]

Each task below will specify which failure case it prevents.

---

## 🧰 Tech Stack

- Flutter (UI framework)
- Dart (programming language)
- dartssh2 (SSH client for LG connection)
- xml (KML generation)
- mockito (testing framework)

---

## 📋 Implementation Task Checklist
```

**Then list all tasks** (see Task Generation section below)

---

# 📌 Task Template (MANDATORY STRUCTURE)

Every task in the plan MUST follow this exact structure:

```markdown
---

### Task N: [Component Name]

**Purpose**: [One sentence describing what this accomplishes]

**Failure Case Prevention**: [Which failure case from design doc does this prevent?]
(If none: "N/A - Foundational utility")

**Files**:
- Create: [Exact file paths to create]
- Modify: [Exact file paths to modify]
- Test: [Exact test file paths to create]

---

## Step 1: Architectural Justification

**Why this component exists**:
[Explain which Clean Architecture layer and why]

**Clean Architecture Principle**: [Which principle this follows]
- Separation of Concerns
- Dependency Inversion
- Single Responsibility
- Testability

---

## Step 2: Implementation

**Complete Code**:

[Full Dart code with comments explaining critical decisions]

**Critical Implementation Details**:
- [Detail 1: e.g., "clearKML() called before sendKML()"]
- [Detail 2: e.g., "Using sendScreenOverlay() not sendKML()"]

---

## Step 3: Verification

**Test Strategy**: [What are we testing?]

**Test File**: `[exact test file path]`

**Complete Test Code**:

[Full test code with setup, execution, assertions]

**Expected Test Results**:
- ✅ [Specific assertion 1]
- ✅ [Specific assertion 2]
- ✅ [Failure case check: e.g., "verifyNever(sendKML)"]

**Run Tests**:
```bash
flutter test [test_file_path]
```

**Expected Output**: `00:0X +N: All tests passed!`

---

## Step 4: Static Analysis

Run:
```bash
flutter analyze [file_path]
```

**Expected**: No issues found

**If warnings exist**:
→ Fix before committing
→ Do NOT proceed with warnings

---

## Step 5: Commit

```bash
git add [specific files only, not "git add ."]
git commit -m "[type](scope): [description]"
```

**Commit Message Format**:
- Type: feat | fix | refactor | test | docs
- Scope: services | core | presentation | domain | data
- Description: Imperative mood, max 50 chars

**Example**: `feat(core): add KML pyramid builder with loop closure validation`

---

**Task Completion Checklist**:
- [ ] Code implements specified logic
- [ ] Tests written and passing
- [ ] Failure case prevention verified in tests
- [ ] Flutter analyze clean (no warnings)
- [ ] Committed with proper message format

---

# 🏗 Task Generation Based on Architecture

## If Architecture = Master-only (Most Common)

Generate these tasks in order:

### Task 1: Create KmlBuilder Utility
- File: `lib/core/utils/kml_builder.dart`
- Purpose: Generate pyramid KML geometry
- Prevention: Polygon loop break bug

### Task 2: Create PyramidService
- File: `lib/services/pyramid_service.dart`
- Purpose: Orchestrate pyramid display with ghosting prevention
- Prevention: Ghosting bug

### Task 3: Create LogoService
- File: `lib/services/logo_service.dart`
- Purpose: Display persistent logo using sendScreenOverlay
- Prevention: Logo disappearance bug

### Task 4: Create LocationService (if API-based)
- File: `lib/services/location_service.dart`
- Purpose: Fetch coordinates via geocoding API
- Prevention: N/A - Data retrieval

### Task 5: Create MockLGConnectionService
- File: `test/mocks/mock_lg_service.dart`
- Purpose: Test infrastructure
- Prevention: Enables failure case verification

### Task 6: Write PyramidService Tests
- File: `test/services/pyramid_service_test.dart`
- Purpose: Verify ghosting prevention and correct method usage
- Prevention: All pyramid-related failure cases

### Task 7: Write LogoService Tests
- File: `test/services/logo_service_test.dart`
- Purpose: Verify correct method usage
- Prevention: Logo disappearance bug

### Task 8: Integrate Services in Presentation Layer
- File: Modify `lib/presentation/screens/home_screen.dart`
- Purpose: Wire services to UI
- Prevention: N/A - Integration

---

## If Architecture = Parallel (Advanced)

Generate these ADDITIONAL tasks:

### Task X: Create ParallelConnectionManager
- File: `lib/services/parallel_connection_manager.dart`
- Purpose: Manage multiple SSH connections to slave nodes
- Prevention: Connection race conditions

### Task X+1: Implement Synchronization Strategy
- File: `lib/services/sync_coordinator.dart`
- Purpose: Ensure commands execute in correct order across slaves
- Prevention: Visual desynchronization

---

# 📝 Complete Task Example (REFERENCE FOR ALL TASKS)

Here is ONE fully completed task showing exactly what each section should contain:

```markdown
---

### Task 2: Create PyramidService

**Purpose**: Orchestrate pyramid display with proper clearKML() → sendKML() sequencing to prevent ghosting.

**Failure Case Prevention**: ❌ Failure Case #2 - Ghosting (old pyramids persist without clearing)

**Files**:
- Create: `lib/services/pyramid_service.dart`
- Create: `test/services/pyramid_service_test.dart`
- Modify: None

---

## Step 1: Architectural Justification

**Why this component exists**:

The `PyramidService` belongs in the **services layer** because:
- It orchestrates LG communication (calls `LGConnectionService`)
- It coordinates KML generation (uses `KmlBuilder` from core/utils)
- It handles the critical `clearKML()` → `sendKML()` sequence
- It has no UI logic (presentation layer concern)
- It has no business logic (domain layer concern)

**Clean Architecture Principle**: **Separation of Concerns**

Services handle I/O and external communication. Pyramid display requires SSH communication to LG, so it belongs here, not in presentation (UI) or domain (business logic).

---

## Step 2: Implementation

**Complete Code**:

```dart
// lib/services/pyramid_service.dart
import 'package:your_app/services/lg_connection_service.dart';
import 'package:your_app/core/utils/kml_builder.dart';

/// Service responsible for displaying 3D pyramids on Liquid Galaxy.
/// 
/// CRITICAL: Always calls clearKML() before sendKML() to prevent ghosting.
class PyramidService {
  final LGConnectionService _lgService;

  PyramidService(this._lgService);

  /// Displays a colored pyramid at the given coordinates.
  /// 
  /// Automatically clears previous geospatial content before sending
  /// new pyramid to prevent ghosting (multiple pyramids visible).
  /// 
  /// Parameters:
  /// - [latitude]: Pyramid base center latitude
  /// - [longitude]: Pyramid base center longitude
  /// - [height]: Pyramid apex height in meters (default 500m)
  /// - [color]: KML color in AABBGGRR format (default red)
  /// 
  /// Throws [Exception] if SSH connection fails.
  Future<void> displayPyramid({
    required double latitude,
    required double longitude,
    double height = 500,
    String color = 'ff0000ff', // Red
  }) async {
    // CRITICAL STEP 1: Clear old geospatial content
    // Without this, old pyramids persist → ghosting bug
    await _lgService.clearKML();

    // STEP 2: Generate pyramid KML geometry
    final pyramidKML = KmlBuilder.buildPyramid(
      baseLat: latitude,
      baseLng: longitude,
      height: height,
      color: color,
    );

    // STEP 3: Send pyramid as geospatial content
    // Uses sendKML() because pyramid is geospatial (has lat/lng position)
    // NOT sendScreenOverlay() (that's for persistent UI like logos)
    await _lgService.sendKML(pyramidKML);
  }

  /// Clears the currently displayed pyramid from Liquid Galaxy.
  /// 
  /// This is a convenience method that just calls clearKML().
  Future<void> clearPyramid() async {
    await _lgService.clearKML();
  }
}
```

**Critical Implementation Details**:
1. ✅ **clearKML() called BEFORE sendKML()** - Prevents ghosting
2. ✅ **Uses sendKML() not sendScreenOverlay()** - Pyramid is geospatial
3. ✅ **Dependency injection** - LGConnectionService passed in constructor (testable)
4. ✅ **Detailed comments** - Future developers understand critical sequence

---

## Step 3: Verification

**Test Strategy**: 

Verify that:
1. `clearKML()` is called before `sendKML()` (ghosting prevention)
2. `sendKML()` is called with valid pyramid geometry
3. `sendScreenOverlay()` is NEVER called (wrong method for pyramid)
4. Error handling works (SSH connection failure)

**Test File**: `test/services/pyramid_service_test.dart`

**Complete Test Code**:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:your_app/services/pyramid_service.dart';
import 'package:your_app/services/lg_connection_service.dart';

// Generate mock: flutter pub run build_runner build
@GenerateMocks([LGConnectionService])
import 'pyramid_service_test.mocks.dart';

void main() {
  late MockLGConnectionService mockLGService;
  late PyramidService pyramidService;

  setUp(() {
    mockLGService = MockLGConnectionService();
    pyramidService = PyramidService(mockLGService);
  });

  group('PyramidService.displayPyramid', () {
    test('calls clearKML before sendKML (ghosting prevention)', () async {
      // Arrange
      when(mockLGService.clearKML()).thenAnswer((_) async => {});
      when(mockLGService.sendKML(any)).thenAnswer((_) async => {});

      // Act
      await pyramidService.displayPyramid(
        latitude: 28.6139,
        longitude: 77.2090,
      );

      // Assert - CRITICAL: Verify call order
      verifyInOrder([
        mockLGService.clearKML(),
        mockLGService.sendKML(any),
      ]);
    });

    test('calls sendKML with valid pyramid geometry', () async {
      // Arrange
      when(mockLGService.clearKML()).thenAnswer((_) async => {});
      when(mockLGService.sendKML(any)).thenAnswer((_) async => {});

      // Act
      await pyramidService.displayPyramid(
        latitude: 28.6139,
        longitude: 77.2090,
        height: 500,
      );

      // Assert - Capture actual KML sent
      final captured = verify(
        mockLGService.sendKML(captureAny),
      ).captured.single as String;

      // Verify KML structure
      expect(captured, contains('<Polygon>'));
      expect(captured, contains('77.2090,28.6139,500')); // Apex coordinate
      expect(captured, contains('<extrude>1</extrude>'));
      expect(captured, contains('<altitudeMode>relativeToGround</altitudeMode>'));
    });

    test('NEVER calls sendScreenOverlay (failure case prevention)', () async {
      // Arrange
      when(mockLGService.clearKML()).thenAnswer((_) async => {});
      when(mockLGService.sendKML(any)).thenAnswer((_) async => {});

      // Act
      await pyramidService.displayPyramid(
        latitude: 28.0,
        longitude: 77.0,
      );

      // Assert - CRITICAL: Verify wrong method NOT called
      // This test catches the bug where pyramid is sent as overlay
      verifyNever(mockLGService.sendScreenOverlay(
        imageUrl: anyNamed('imageUrl'),
        overlayX: anyNamed('overlayX'),
        overlayY: anyNamed('overlayY'),
        sizeX: anyNamed('sizeX'),
        sizeY: anyNamed('sizeY'),
      ));
    });

    test('calls sendKML exactly once per pyramid', () async {
      // Arrange
      when(mockLGService.clearKML()).thenAnswer((_) async => {});
      when(mockLGService.sendKML(any)).thenAnswer((_) async => {});

      // Act
      await pyramidService.displayPyramid(
        latitude: 28.0,
        longitude: 77.0,
      );

      // Assert
      verify(mockLGService.sendKML(any)).called(1);
    });

    test('handles SSH connection failure gracefully', () async {
      // Arrange
      when(mockLGService.clearKML()).thenAnswer((_) async => {});
      when(mockLGService.sendKML(any))
        .thenThrow(Exception('SSH connection failed'));

      // Act & Assert
      expect(
        () => pyramidService.displayPyramid(
          latitude: 28.0,
          longitude: 77.0,
        ),
        throwsException,
      );
    });
  });

  group('PyramidService.clearPyramid', () {
    test('calls clearKML', () async {
      // Arrange
      when(mockLGService.clearKML()).thenAnswer((_) async => {});

      // Act
      await pyramidService.clearPyramid();

      // Assert
      verify(mockLGService.clearKML()).called(1);
    });
  });
}
```

**Expected Test Results**:
- ✅ Test 1: Verifies clearKML() → sendKML() order (prevents ghosting)
- ✅ Test 2: Verifies valid KML structure sent
- ✅ Test 3: Verifies sendScreenOverlay() NEVER called (prevents wrong method bug)
- ✅ Test 4: Verifies single call (no duplicate sends)
- ✅ Test 5: Verifies error handling

**Run Tests**:
```bash
flutter test test/services/pyramid_service_test.dart
```

**Expected Output**:
```
00:02 +5: All tests passed!
```

---

## Step 4: Static Analysis

Run:
```bash
flutter analyze lib/services/pyramid_service.dart
```

**Expected**: 
```text
Analyzing your_app...
No issues found!
```

**If warnings exist**:
→ Fix before committing (e.g., missing dartdoc comments, unused imports)
→ Do NOT proceed with warnings

---

## Step 5: Commit

```bash
git add lib/services/pyramid_service.dart test/services/pyramid_service_test.dart
git commit -m "feat(services): add PyramidService with ghosting prevention"
```

**Verify commit**:
```bash
git log -1 --oneline
```

Expected: Recent commit with message appears

---

**Task Completion Checklist**:
- [x] Code implements clearKML() → sendKML() sequence
- [x] Tests verify call order (ghosting prevention)
- [x] Tests verify sendScreenOverlay() never called (failure case #1 prevention)
- [x] Flutter analyze clean
- [x] Committed with proper message format

---

**THIS LEVEL OF DETAIL IS REQUIRED FOR EVERY TASK IN THE PLAN.**

---

# 🧪 Mock Service Requirement (MANDATORY TASK)

Every plan MUST include this task:

---

### Task 5: Create MockLGConnectionService for Testing

**Purpose**: Provide test infrastructure for mocking LGConnectionService in all service layer tests.

**Failure Case Prevention**: N/A - Enables all other failure case verifications

**Files**:
- Create: `test/mocks/mock_lg_service.dart`
- Modify: None
- Test: None (this IS the test infrastructure)

---

## Step 1: Architectural Justification

**Why this exists**:

Mock services belong in `test/mocks/` because:
- They're test-only infrastructure (not production code)
- Shared across multiple test files
- Centralized location for all mocks
- Follows testing best practices

**Testing Principle**: **Test Doubles**

Use mocks to isolate unit tests from external dependencies (SSH, network).

---

## Step 2: Implementation

**Complete Code**:

```dart
// test/mocks/mock_lg_service.dart
import 'package:mockito/mockito.dart';
import 'package:your_app/services/lg_connection_service.dart';

/// Mock implementation of LGConnectionService for testing.
/// 
/// Usage in tests:
/// ```dart
/// final mockLG = MockLGConnectionService();
/// when(mockLG.sendKML(any)).thenAnswer((_) async => {});
/// ```
class MockLGConnectionService extends Mock implements LGConnectionService {}
```

**That's it.** Mockito generates the rest at build time.

---

## Step 3: Verification

**Generate mock methods**:
```bash
flutter pub run build_runner build
```

**Expected**: File `test/mocks/mock_lg_service.mocks.dart` generated

**Verify mock can be imported**:
```dart
import 'mock_lg_service.mocks.dart'; // Should have no errors
```

---

## Step 4: Static Analysis

```bash
flutter analyze test/mocks/mock_lg_service.dart
```

**Expected**: No issues

---

## Step 5: Commit

```bash
git add test/mocks/mock_lg_service.dart
git commit -m "test(mocks): add MockLGConnectionService for service layer tests"
```

---
```

---

# 🧪 Test Verification Syntax (CORRECTED)

**Common verification patterns** (use these in all tests):

## ✅ CORRECT Verification Examples

```dart
// Verify method called exactly once
verify(mockLG.sendKML(any)).called(1);

// Verify method called with specific arguments
verify(mockLG.sendScreenOverlay(
  imageUrl: 'logo.png',
  overlayX: 0.05,
  overlayY: 0.95,
  sizeX: anyNamed('sizeX'),
  sizeY: anyNamed('sizeY'),
)).called(1);

// Verify method NEVER called (NO .called(0), just verifyNever)
verifyNever(mockLG.sendKML(any));
verifyNever(mockLG.sendScreenOverlay(
  imageUrl: anyNamed('imageUrl'),
  overlayX: anyNamed('overlayX'),
  overlayY: anyNamed('overlayY'),
));

// Verify call order
verifyInOrder([
  mockLG.clearKML(),
  mockLG.sendKML(any),
]);

// Capture argument for inspection
final captured = verify(mockLG.sendKML(captureAny)).captured.single;
expect(captured, contains('<Polygon>'));
```

## ❌ WRONG Verification (DO NOT USE)

```dart
// WRONG: verifyNever does NOT take .called(0)
verifyNever(mockLG.sendScreenOverlay(...)).called(0); // SYNTAX ERROR

// CORRECT version:
verifyNever(mockLG.sendScreenOverlay(...));
```

---

# 🎓 Educational Verification Phase (WITH SCORING)

Before execution begins, verify student understanding with progressive questioning.

**Announce**: "Before we begin implementation, I need to verify your understanding of the plan's architectural decisions."

---

## Question 1: Ghosting Prevention (Deepens Brainstormer Q3)

**Ask**: "In our plan, PyramidService calls clearKML() before sendKML(). What specific file on the Master node gets cleared by this operation?"

**Expected Answer**: `/tmp/query.txt`

**Scoring**:
- ✅ **Full credit**: Mentions `/tmp/query.txt` specifically
- ⚠️ **Partial credit**: Says "query file" or "temp file" without path
  - Follow-up: "What's the exact file path?"
  - If correct on retry: Give full credit
- ❌ **No credit**: Says "cache" or "memory" or doesn't know

**If no credit after follow-up**:
→ Explain: "clearKML() executes: `echo "" > /tmp/query.txt` on the Master node. This file stores all current geospatial KML content."
→ Re-ask simplified: "Now, what happens to /tmp/query.txt when clearKML() runs?"
→ Expected: "It gets emptied"

---

## Question 2: Polygon Loop Closure (Deepens Brainstormer Q2)

**Ask**: "Our KmlBuilder creates pyramid faces. Why does each LinearRing have its first and last coordinates identical?"

**Expected Answer**: "To close the polygon loop. Without closing, Google Earth cannot render filled faces."

**Scoring**:
- ✅ **Full credit**: Mentions both "close loop" AND "filled faces/rendering"
- ⚠️ **Partial credit**: Mentions only one aspect
  - Follow-up: "What visual consequence occurs if we DON'T close the loop?"
  - Expected: "No fill, outline only, or no rendering"
- ❌ **No credit**: Says "it's required" without explanation

**If no credit after follow-up**:
→ Show visual:
```
❌ Open loop: A → B → C (gap)
   Result: Outline only, no fill

✅ Closed loop: A → B → C → A
   Result: Filled face renders correctly
```
→ Re-ask: "Now explain why closing matters."

---

## Question 3: Method Selection (Deepens Brainstormer Q4)

**Ask**: "Our plan has PyramidService and LogoService. Which LGConnectionService method does each use, and why?"

**Expected Answer**: 
- "PyramidService uses sendKML() because pyramid is geospatial content with lat/lng position"
- "LogoService uses sendScreenOverlay() because logo is persistent UI fixed to screen space"

**Scoring**:
- ✅ **Full credit**: Correctly identifies both methods AND explains geospatial vs persistent UI distinction
- ⚠️ **Partial credit**: Correct methods but vague reason ("because it's a logo")
  - Follow-up: "What would happen if LogoService used sendKML() instead?"
  - Expected: "Logo would disappear when clearKML() is called"
- ❌ **No credit**: Wrong method assignment or can't explain

---

## Question 4: Service Centralization (NEW)

**Ask**: "Why does our plan use the initialized LGConnectionService instead of creating a new SSH service?"

**Expected Answer**: "Because LGConnectionService centralizes SSH connection logic, avoiding duplicate connection management and following DRY principle."

**Scoring**:
- ✅ **Full credit**: Mentions centralization, avoiding duplication, or DRY
- ⚠️ **Partial credit**: Says "because it exists" without architectural reason
  - Follow-up: "What problems would multiple SSH services cause?"
  - Expected: "Multiple connections, harder debugging, connection conflicts"
- ❌ **No credit**: Doesn't know or says "because you said so"

---

## Question 5: Test Verification Pattern (NEW - IMPLEMENTATION LEVEL)

**Ask**: "In PyramidService tests, which line of code verifies that we're NOT making the 'logo as placemark' mistake?"

**Show them the test**:
```dart
verifyNever(mockLGService.sendScreenOverlay(
  imageUrl: anyNamed('imageUrl'),
  ...
));
```

**Expected Answer**: "The `verifyNever` line ensures sendScreenOverlay is never called by PyramidService, catching the bug where pyramid is sent as overlay instead of geospatial."

**Scoring**:
- ✅ **Full credit**: Identifies `verifyNever` as the key check
- ❌ **No credit**: Identifies wrong line or doesn't understand mock verification

**If no credit**:
→ Explain: "`verifyNever` asserts a method was NOT called. This catches bugs where wrong methods are used."

---

## Verification Scoring Summary

| Score | Outcome | Action |
|-------|---------|--------|
| **5/5** | ✅ PROCEED | Excellent understanding, begin Task 1 immediately |
| **4/5** | ✅ PROCEED | Good understanding, provide brief clarification on missed point |
| **3/5** | ⚠️ CONDITIONAL | Adequate but shaky - re-explain failed concepts, then proceed |
| **2/5** | ❌ BORDERLINE | Re-teach failed concepts, re-test all questions. If pass: proceed. If fail: Skeptical Mentor |
| **0-1/5** | ❌ FAIL | Activate `lg-skeptical-mentor`, return to design review, DO NOT proceed |

---

## Document Verification Results

Add this section to the plan file:

```markdown
---

## 📝 Educational Verification Results

**Verified by**: [Assistant name]
**Date**: YYYY-MM-DD HH:MM

| Question | Topic | Score | Notes |
|----------|-------|-------|-------|
| Q1 | Ghosting prevention | ✅ Full | Identified /tmp/query.txt correctly |
| Q2 | Loop closure | ✅ Full | Explained rendering consequence |
| Q3 | Method selection | ⚠️ Partial | Correct methods, needed follow-up on "why" |
| Q4 | Service centralization | ✅ Full | Understood DRY principle |
| Q5 | Test pattern | ✅ Full | Identified verifyNever correctly |

**Final Score**: 5/5 (100%)

**Decision**: ✅ PROCEED TO TASK 1

**Clarifications Provided**: Q3 required follow-up on geospatial vs persistent UI distinction.

---
```

**Only proceed if score ≥ 3/5 AND documented.**

---

# 🚦 Plan Generation Complete

**After**:
- Foundation verified
- Design document parsed
- Architecture strategy extracted
- All tasks generated with complete examples
- Educational verification passed (≥ 3/5)
- Plan saved to `docs/plans/YYYY-MM-DD-T2-plan.md`

**Say**:

"✅ Implementation plan complete and saved.

**Plan Summary**:
- Architecture: [Parallel/Master-only]
- Total Tasks: [N]
- Failure Cases Prevented: [List from design doc]
- Educational Verification: [Score]/5

Your plan is deterministic and executable. Each task includes:
- Complete implementation code
- Complete test code
- Verification steps
- Commit instructions

Ready to begin Task 1?"

**Wait for student confirmation.**

**Upon confirmation, activate:**

```lg-plan-executer```

---

**No implementation without saved plan.**
**No shortcuts.**
**Every task must follow the complete example structure.**