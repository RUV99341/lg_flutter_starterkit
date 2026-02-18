---
name: Liquid Galaxy Flutter Brainstormer
description: MUST be used before implementing any feature. Converts validated LG foundation into precise logic mapping for Flutter + Liquid Galaxy.
---

# 🧠 Liquid Galaxy Flutter Brainstormer

SECOND stage in pipeline:

Init → Brainstorm → Plan → Execute → Review → Quiz

Project structure and LGConnectionService were created in `lg-project-initializer`.

This skill does NOT scaffold.

This skill maps LOGIC to real KML + Dart behavior.

---

# 🔍 Foundation Verification (MANDATORY FIRST STEP)

Before brainstorming, verify initialization artifacts exist:

**Step 1: Verify LGConnectionService**

Ask student: "Run this command and paste the output:"
```bash
cat lib/services/lg_connection_service.dart | grep "Future<void>"
```

**Expected output MUST include ALL four methods:**
```dart
Future<void> connect(String host, String username, String password) async {}
Future<void> sendKML(String kml) async {}
Future<void> clearKML() async {}
Future<void> sendScreenOverlay({
```

**Step 2: Verify LGConfig**

Ask student: "Run this command:"
```bash
cat lib/core/constants/lg_config.dart | grep "worldWidth"
```

**Expected output:**
```dart
static int get worldWidth => screenWidth * screenCount;
```

**Step 3: Verify Directory Structure**

Ask student: "Run this command:"
```bash
ls docs/plans docs/reviews lib/presentation lib/domain lib/data lib/services lib/core
```

**Expected**: All directories exist with no "No such file or directory" errors

---

## Verification Result

**If ANY verification fails:**
→ STOP immediately
→ Say: "Your initialization is incomplete. The following files/directories are missing: [list them]"
→ Say: "Please run `lg-project-initializer` again and complete all phases."
→ DO NOT proceed with brainstorming
→ Activate `lg-skeptical-mentor`

**Only if ALL verifications pass:**
→ Say: "✅ Foundation verified. Proceeding with brainstorming."

---

# 🔀 Workflow Mode Behavior

The active workflow dictates the scope of this session. Adjust focus based on the `mode` parameter:

| Mode | Focus Areas | Skip / Ignore |
| :--- | :--- | :--- |
| **api-only** | API endpoints, JSON contracts, status code handling, rate limiting. | KML geometry, screen overlays, pyramid math. |
| **screen-only** | Navigation flow, widget hierarchy, state management, interactive zones. | LG service architecture, SSH command strategy. |
| **full** (Default) | End-to-end architecture (FA-001 to FA-040). | Nothing. |

**MANDATE:** If `api-only` is active, do NOT ask about `WORLD_WIDTH` or `clearKML`. Focus strictly on the data contract.


# 🌐 LG Rig Constraint Verification

Ask:

"What is WORLD_WIDTH for your rig?"

Expected:
WORLD_WIDTH = screenWidth × screenCount

If incorrect:
→ Re-explain once
→ Activate `lg-skeptical-mentor`

No repetition of initializer theory.

---

# 🎯 Purpose

Bridge idea → real technical mapping for:

- T2 3D Pyramid
- Persistent Logo Overlay
- Home City Fly-To
- Correct SSH/KML command ordering
- Testable Dart service logic

This is engineering logic. Not UI brainstorming.

---

# 🏗 Phase 2 — Architecture Trade-Offs (Must Choose)

## Option A — Parallel Execution (Advanced)

**What This Means**:
- SSH commands sent to multiple slave IPs simultaneously (e.g., 42-101, 42-102, 42-103)
- Each screen may receive offset content
- KML distributed across rig nodes
- Maximizes panoramic immersion

**Technical Implications**:
- Must manage multiple SSH connections
- Synchronization complexity increases
- Risk: race conditions if commands not sequenced properly

**Use When**:
- Large panoramic visual effects (e.g., pyramid spanning all screens)
- Content benefits from true distributed rendering
- Team has advanced SSH orchestration experience

**Code Pattern**:
```dart
// Parallel execution to all slaves
for (final slaveIP in ['42-101', '42-102', '42-103']) {
  await SSHClient.connect(slaveIP);
  await SSHClient.sendCommand(...);
}
```

---

## Option B — Master-Only Execution (Recommended for T2)

**What This Means**:
- All KML sent to Master node (.1 node, typically 42-100)
- Master automatically relays to slaves via internal LG networking
- Single connection point
- Google Earth on master propagates to all screens

**Technical Implications**:
- Simpler mental model (one connection)
- Lower sync risk
- Master node acts as authoritative source
- Sufficient for pyramid + overlay + fly-to

**Use When**:
- Standard geospatial visualization
- Content doesn't require per-screen customization
- First-time LG development

**Code Pattern**:
```dart
// Single master connection
await lgService.connect('42-100', 'lg', 'lg'); // Master IP
await lgService.sendKML(pyramidKML); // Master relays to slaves
```

---

## Decision Point

**Ask student**:

"Does your demo require **per-screen customization** (e.g., different pyramid on each screen), or is it **unified content** (same pyramid visible across all screens)?"

**If per-screen customization needed**:
→ Recommend Option A (Parallel)
→ Student must justify why unified content isn't sufficient

**If unified content**:
→ Recommend Option B (Master-only)
→ This is the default for T2 requirements

**Student must explicitly state their choice and save it to design doc.**

No default acceptance.

---

# 📌 LG Integration Strategy (Concrete)

The initialized `LGConnectionService` provides these methods:

**1. `sendKML(String kml)`**
- Use for: Geospatial content (Placemarks, Polygons, LookAt, Tours)
- Clears: Can be cleared with `clearKML()`
- Example: 3D pyramid, city markers, camera fly-to

**2. `sendScreenOverlay({imageUrl, overlayX, overlayY, ...})`**
- Use for: Persistent UI elements (logos, HUD, watermarks)
- Clears: NOT cleared by `clearKML()` - persists across camera movements
- Example: Company logo, dashboard overlay

**3. `clearKML()`**
- Use for: Removing previous geospatial content before sending new content
- Effect: Clears `/tmp/query.txt` on master node
- Does NOT clear: ScreenOverlays

**Ask student**: "Which method will you use for the pyramid? Which for the logo?"

**Expected**:
- Pyramid: `sendKML()` (it's geospatial)
- Logo: `sendScreenOverlay()` (it's persistent UI)

If incorrect → Explain failure cases below → Re-ask

---

# ⚠️ Failure Cases (With Real Code)

## ❌ FAILURE CASE #1 — Sending Logo as Placemark

**Wrong Code**:
```xml
<Placemark>
  <name>Logo</name>
  <Point>
    <coordinates>0,0,0</coordinates>
  </Point>
  <Icon>
    <href>https://example.com/logo.png</href>
  </Icon>
</Placemark>
```

**Dart implementation**:
```dart
final logoKML = '''<Placemark>...</Placemark>''';
await lgService.sendKML(logoKML); // WRONG METHOD
```

**What happens**:
- Logo is treated as geospatial content
- Logo moves with camera during fly-to (should stay fixed)
- Logo disappears when `clearKML()` is called for pyramid
- Logo positioned at coordinates (0,0,0) in ocean near Africa

**Why this fails**:
`sendKML()` is for geospatial content that has a lat/lng position in the world. Logos should be fixed to screen space, not world space.

---

## ✅ CORRECT — ScreenOverlay

**Correct XML**:
```xml
<ScreenOverlay>
  <name>Logo</name>
  <Icon>
    <href>https://example.com/logo.png</href>
  </Icon>
  <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
  <screenXY x="0.02" y="0.95" xunits="fraction" yunits="fraction"/>
  <size x="0.2" y="0.2" xunits="fraction" yunits="fraction"/>
</ScreenOverlay>
```

**Dart implementation**:
```dart
await lgService.sendScreenOverlay(
  imageUrl: 'https://example.com/logo.png',
  overlayX: 0.02, // 2% from left
  overlayY: 0.95, // 95% from top (5% from bottom)
  sizeX: 0.2,
  sizeY: 0.2,
);
```

**Why this works**:
- Logo stays in fixed screen position (bottom-left corner)
- Persists during camera fly-to
- NOT cleared by `clearKML()`
- Positioned in screen fraction coordinates (0.0 to 1.0)

**Must call**: `sendScreenOverlay()` method

---

## ❌ FAILURE CASE #2 — Ghosting (No Clear)

**Wrong Code**:
```dart
// First pyramid in New Delhi
await lgService.sendKML(createPyramid(28.6139, 77.2090));

// User selects different city
// Later: Second pyramid in Mumbai (WITHOUT clearing first)
await lgService.sendKML(createPyramid(19.0760, 72.8777));
```

**What happens**:
- Both pyramids visible on screen
- Visual clutter (two pyramids at different locations)
- User sees "ghost" of old pyramid
- Cannot distinguish current vs previous content

**Why this fails**:
KML content sent via `sendKML()` appends to `/tmp/query.txt`. Without clearing, old content remains.

---

## ✅ CORRECT — Clear First

**Correct Code**:
```dart
// Clear old geospatial content first
await lgService.clearKML();

// Then send new pyramid
await lgService.sendKML(createPyramid(19.0760, 72.8777));
```

**Alternative approach** (if implementing clearKML yourself):
```dart
// Send empty string to clear query.txt
await sshClient.execute('echo "" > /tmp/query.txt');

// Then send new KML
await lgService.sendKML(pyramidKML);
```

**Why this works**:
- `clearKML()` removes previous geospatial content
- Only current pyramid is visible
- Clean visual state before each new injection

**Student must explain**: "Why does ghosting occur if we skip clearKML()?"

**Expected answer**: "Because KML content appends to `/tmp/query.txt` without clearing, causing old and new content to render simultaneously."

---

## ❌ FAILURE CASE #3 — Assuming clearKML() Removes ScreenOverlay

**Wrong Assumption**:
```dart
// Display logo
await lgService.sendScreenOverlay(imageUrl: 'logo.png', ...);

// Later, try to remove logo
await lgService.clearKML(); // DOES NOT REMOVE OVERLAY!
```

**What happens**:
- Logo persists on screen
- `clearKML()` only removes Placemarks, Polygons, LookAt, Tours
- No way to remove ScreenOverlay with current scaffold

**Why this fails**:
`clearKML()` only clears `/tmp/query.txt` which contains geospatial KML. ScreenOverlays are sent to a different file/mechanism.

**Current workaround**:
ScreenOverlays are intended to be persistent. If removal is needed, you must:
1. Send a transparent/empty overlay to replace it, OR
2. Extend `LGConnectionService` with `clearScreenOverlay()` method (future work)

**Ask student**: "In your feature, does the logo need to be removed, or can it stay persistent?"

---

# 🧮 Pressure Point — 3D Pyramid Math

A pyramid uses `<Polygon>` with extrusion.

**Complete Example** (showing all 4 faces):
```xml
<Placemark>
  <name>Colored Pyramid</name>
  <Style>
    <PolyStyle>
      <color>ff0000ff</color> <!-- Red (AABBGGRR format) -->
    </PolyStyle>
  </Style>
  
  <!-- Face 1: North -->
  <Polygon>
    <extrude>1</extrude>
    <altitudeMode>relativeToGround</altitudeMode>
    <outerBoundaryIs>
      <LinearRing>
        <coordinates>
          77.0,28.0,0
          77.001,28.0,0
          77.0005,28.001,500
          77.0,28.0,0
        </coordinates>
      </LinearRing>
    </outerBoundaryIs>
  </Polygon>
  
  <!-- Face 2: East -->
  <Polygon>
    <extrude>1</extrude>
    <altitudeMode>relativeToGround</altitudeMode>
    <outerBoundaryIs>
      <LinearRing>
        <coordinates>
          77.001,28.0,0
          77.001,28.001,0
          77.0005,28.001,500
          77.001,28.0,0
        </coordinates>
      </LinearRing>
    </outerBoundaryIs>
  </Polygon>
  
  <!-- Faces 3 & 4: Similar pattern -->
  
</Placemark>
```

**Critical Rules**:
1. **First and last coordinate MUST match** (closes the loop)
   - Wrong: `A → B → C` (open loop, no fill)
   - Correct: `A → B → C → A` (closed loop, filled)

2. **altitudeMode must be `relativeToGround`**
   - `clampToGround`: Ignores altitude, sticks to terrain
   - `relativeToGround`: Altitude measured from ground level ✅
   - `absolute`: Altitude from sea level (not recommended)

3. **extrude must be 1**
   - `extrude=1`: Makes polygon 3D (fills from ground to shape)
   - `extrude=0`: Only draws outline at altitude (no fill)

4. **Apex must have altitude > 0**
   - Base corners: `lng,lat,0` (ground level)
   - Apex: `lng,lat,500` (500 meters above ground)

5. **Coordinates follow `lng,lat,alt` format** (NOT lat,lng!)
   - Common mistake: reversing longitude and latitude
   - Correct order: `77.0,28.0,500` (longitude first)

---

## Verification Questions

**Ask student**:

**Q1**: "Why must the first and last coordinates in a LinearRing be identical?"

**Expected answer**: "To close the polygon loop. Without closing, Google Earth cannot render a filled face—it will show as an outline only or not render at all."

**Q2**: "What happens if you use `altitudeMode=clampToGround` for a pyramid?"

**Expected answer**: "The altitude values are ignored, and the polygon is flattened to ground level. The pyramid loses its 3D shape and becomes a flat polygon on the terrain."

**Q3**: "Why do coordinates use `lng,lat,alt` instead of `lat,lng,alt`?"

**Expected answer**: "KML follows the standard coordinate order of longitude (X-axis), latitude (Y-axis), altitude (Z-axis). This matches geographic coordinate systems where longitude is the first component."

**If student cannot explain any of these**:
→ Provide brief explanation
→ Re-ask question
→ If fails twice: Activate `lg-skeptical-mentor`

---

# 🏙 Home City Fly-To

Must generate `<LookAt>` to position camera:

```xml
<LookAt>
  <longitude>77.2090</longitude>
  <latitude>28.6139</latitude>
  <range>5000</range>  <!-- Distance from target in meters -->
  <tilt>45</tilt>      <!-- Camera angle: 0=top-down, 90=horizon -->
  <heading>0</heading> <!-- Direction: 0=North, 90=East, 180=South, 270=West -->
</LookAt>
```

**Parameters explained**:
- `longitude`, `latitude`: Where to look at
- `range`: Distance from target (meters) - smaller = closer zoom
- `tilt`: Camera angle - 0° = looking straight down, 90° = looking at horizon
- `heading`: Compass direction - which way camera faces

**Decision Point**:

**Ask student**: "How will you get the coordinates for the user's home city?"

**Option A: Hardcoded coordinates**
```dart
final homeCity = {
  'lat': 28.6139,
  'lng': 77.2090,
}; // New Delhi hardcoded
```
- **Pro**: No API dependency, no network calls, instant
- **Con**: Not scalable, can't handle user input, requires code change for different cities

**Option B: Geocoding API** (OpenStreetMap Nominatim, Google Places, etc.)
```dart
final coords = await geocodingAPI.getCoordinates('New Delhi');
```
- **Pro**: Scalable, handles user input, dynamic
- **Con**: API rate limits, network latency, requires error handling, API key management

**Student must choose and justify**:

If Option A: "Why is hardcoding acceptable for your demo?"
If Option B: "Which API will you use and how will you handle rate limits?"

**No vague answers like "I'll just get the coordinates"** - must specify the mechanism.

---

# 🧪 Concrete Test Snippet (Mockito)

Must show understanding of service layer testing:

**Example test student should understand**:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([LGConnectionService])
import 'logo_service_test.mocks.dart';

void main() {
  late MockLGConnectionService mockLG;
  late LogoService logoService;

  setUp(() {
    mockLG = MockLGConnectionService();
    logoService = LogoService(mockLG);
  });

  test('displayLogo calls sendScreenOverlay with correct parameters', () async {
    // Act
    await logoService.displayLogo('logo.png');

    // Assert - verify correct method called
    verify(mockLG.sendScreenOverlay(
      imageUrl: 'logo.png',
      overlayX: anyNamed('overlayX'),
      overlayY: anyNamed('overlayY'),
      sizeX: anyNamed('sizeX'),
      sizeY: anyNamed('sizeY'),
    )).called(1);
  });

  test('displayLogo NEVER calls sendKML (failure case prevention)', () async {
    // Act
    await logoService.displayLogo('logo.png');

    // Assert - verify wrong method NOT called
    verifyNever(mockLG.sendKML(any));
  });
}
```

**Ask student**: "Which line in this test catches Failure Case #1 (using sendKML for logo)?"

**Expected answer**: `verifyNever(mockLG.sendKML(any));` - This line ensures sendKML is never called, preventing the bug where logo is sent as geospatial content.

**If student cannot identify this**:
→ Explain mock verification pattern
→ Show how `verifyNever` prevents failure cases
→ Re-ask question
→ If still fails: Activate `lg-skeptical-mentor`

---

# 📄 Rigid Design Document Template

Student must copy this **EXACT** structure into:
`docs/plans/YYYY-MM-DD-T2-design.md`

Replace `YYYY-MM-DD` with actual date (e.g., `2025-02-16-T2-design.md`)

**Template**:

```markdown
# Feature: Liquid Galaxy T2 Demo

**Goal**: [One sentence: Build 3D pyramid at home city with persistent logo overlay and camera fly-to animation]

**Architecture Strategy**: (Parallel / Master-only) - [Justify choice in 2 sentences]

**LG Method Usage**:
- `clearKML()`: [When will this be called? E.g., "Before sending pyramid to prevent ghosting"]
- `sendKML()`: [When will this be called? E.g., "To send pyramid geometry and LookAt camera positioning"]
- `sendScreenOverlay()`: [When will this be called? E.g., "To display persistent logo in bottom-left corner"]

**Tech Stack**:
- Flutter (UI framework)
- Dart (programming language)
- dartssh2 (SSH connection to LG)
- xml (KML generation)
- mockito (testing framework)

**Failure Cases Prevented**:
- ❌ Failure Case #1: Logo sent as Placemark (disappears on clearKML)
- ❌ Failure Case #2: Ghosting (old pyramid persists without clearing)
- ❌ Failure Case #3: Polygon loop not closed (no fill rendering)

---

## 1. LG Screen Target
- **Screen count**: [3 / 5 / 7]
- **Master IP**: [e.g., 42-100 or 192.168.1.100]
- **Execution strategy**: (Parallel / Master-only)
- **Justification**: [Why this strategy fits the demo requirements]

---

## 2. Architecture Layers

**Presentation Layer**:
- Components: [e.g., HomeScreen, PyramidButton, LogoWidget]
- Responsibility: [e.g., User input, button taps, display UI]

**Domain Layer**:
- Components: [e.g., CreatePyramidUseCase, GetCoordinatesUseCase]
- Responsibility: [e.g., Business logic, coordinate validation]

**Data Layer**:
- Components: [e.g., GeocodingRepository, LocationModel]
- Responsibility: [e.g., API calls, data transformation]

**Services Layer**:
- Components: [e.g., LGConnectionService (initialized), PyramidService, LogoService]
- Responsibility: [e.g., SSH communication, KML injection, LG coordination]

---

## 3. Data Flow

```
User Taps Button (Presentation)
        ↓
CreatePyramidUseCase (Domain)
        ↓
LocationRepository.getCoordinates() (Data) [if using API]
        ↓
PyramidService.displayPyramid() (Services)
        ↓
LGConnectionService.clearKML() (Services)
        ↓
LGConnectionService.sendKML(pyramidKML) (Services)
        ↓
SSH to LG Master Node
        ↓
KML injected to /tmp/query.txt
        ↓
Google Earth renders pyramid
```

**Parallel path for logo**:
```
App Startup (Presentation)
        ↓
LogoService.displayLogo() (Services)
        ↓
LGConnectionService.sendScreenOverlay() (Services)
        ↓
SSH to LG Master Node
        ↓
ScreenOverlay rendered (persistent)
```

---

## 4. KML Geometry Math

**Pyramid Base Coordinates** (example for New Delhi):
- Base NW: `77.2080, 28.6149, 0`
- Base NE: `77.2100, 28.6149, 0`
- Base SE: `77.2100, 28.6129, 0`
- Base SW: `77.2080, 28.6129, 0`

**Apex Coordinate**:
- Apex: `77.2090, 28.6139, 500` (center, elevated 500m)

**Loop Closure**:
Each triangular face must close: `BaseCorner1 → BaseCorner2 → Apex → BaseCorner1`

Example for North face:
```
77.2080,28.6149,0 → 77.2100,28.6149,0 → 77.2090,28.6139,500 → 77.2080,28.6149,0
```

**Why loop must close**: Without closing (first coord = last coord), Google Earth cannot render filled polygon faces. Will show outline only or no render.

---

## 5. LG Method Usage Detail

**Method: `clearKML()`**
- **When called**: Before sending new pyramid KML
- **Purpose**: Clear previous geospatial content to prevent ghosting
- **SSH command**: `echo "" > /tmp/query.txt` (clears query file)
- **Does NOT clear**: ScreenOverlays (logo persists)

**Method: `sendKML(String kml)`**
- **When called**: After clearKML(), when sending pyramid geometry and LookAt
- **Purpose**: Inject geospatial KML content
- **SSH command**: `echo '${kml}' > /tmp/query.txt`
- **Content type**: Placemarks, Polygons, LookAt, Tours

**Method: `sendScreenOverlay({...})`**
- **When called**: Once at app startup
- **Purpose**: Display persistent logo
- **SSH command**: Generates ScreenOverlay KML and writes to overlay file
- **Content type**: Fixed UI elements (logos, HUD)

---

## 6. SSH Command Sequence

**Initialization** (one-time):
```
1. SSH connect to Master (42-100:22 or :2222)
2. Authenticate with username/password
3. Verify connection success
```

**Per-Feature Execution**:
```
1. clearKML() → echo "" > /tmp/query.txt
2. sendKML(pyramidKML) → echo '<Placemark>...</Placemark>' > /tmp/query.txt
3. sendKML(lookAtKML) → echo '<LookAt>...</LookAt>' >> /tmp/query.txt (append)
```

**Logo (persistent, separate)**:
```
1. sendScreenOverlay() → echo '<ScreenOverlay>...</ScreenOverlay>' > /var/www/html/kmls.txt (example path)
```

**Critical**: clearKML must execute BEFORE sendKML to prevent ghosting.

---

## 7. Failure Cases Detailed

**Failure Case #1: Logo sent as Placemark**
- **What happens**: Logo positioned at lat/lng in world space, moves with camera, disappears on clearKML
- **Prevention**: Use `sendScreenOverlay()` instead of `sendKML()`
- **Test verification**: `verifyNever(mockLG.sendKML(any))` in LogoService test

**Failure Case #2: Ghosting (no clear before new pyramid)**
- **What happens**: Multiple pyramids visible, visual clutter, cannot distinguish current content
- **Prevention**: Always call `clearKML()` before `sendKML()`
- **Test verification**: `verifyInOrder([mockLG.clearKML(), mockLG.sendKML(any)])` in PyramidService test

**Failure Case #3: Polygon loop not closed**
- **What happens**: Pyramid faces show as outline only, no fill rendering
- **Prevention**: Ensure first coord = last coord in each LinearRing
- **Test verification**: Unit test in KmlBuilder that checks coordinate loop closure

---

## 8. Testing Plan

**Service Layer Tests**:
```dart
// PyramidService
test('displayPyramid calls clearKML before sendKML', () {
  verifyInOrder([mockLG.clearKML(), mockLG.sendKML(any)]);
});

test('displayPyramid calls sendKML with valid pyramid geometry', () {
  verify(mockLG.sendKML(contains('<Polygon>'))).called(1);
});

test('displayPyramid NEVER calls sendScreenOverlay', () {
  verifyNever(mockLG.sendScreenOverlay(...));
});

// LogoService
test('displayLogo calls sendScreenOverlay with correct coordinates', () {
  verify(mockLG.sendScreenOverlay(imageUrl: 'logo.png', ...)).called(1);
});

test('displayLogo NEVER calls sendKML', () {
  verifyNever(mockLG.sendKML(any));
});
```

**Domain Layer Tests**:
```dart
// CreatePyramidUseCase
test('use case transforms coordinates correctly', () {
  // Test business logic without LG dependencies
});
```

**Data Layer Tests** (if using API):
```dart
// GeocodingRepository
test('repository handles 404 API error gracefully', () {
  expect(() => repo.getCoordinates('InvalidCity'), throwsException);
});
```

---

## 9. Trade-Off Decision

**Chosen Strategy**: [Master-only / Parallel]

**Justification**:

[Example for Master-only]
"Master-only execution was chosen because:
1. The T2 demo requires unified content (same pyramid visible across all screens), not per-screen customization
2. Reduces complexity by maintaining single SSH connection to master node
3. Master automatically relays content to slave screens via internal LG networking
4. Lower risk of synchronization issues
5. Sufficient for pyramid + logo + fly-to requirements"

**Rejected Alternative**: [Why the other option wasn't chosen]

[Example]
"Parallel execution was considered but rejected because:
1. Adds unnecessary complexity for unified content
2. Requires managing 3-7 simultaneous SSH connections
3. Higher risk of race conditions
4. No performance benefit for this use case"

---

## 10. Scalability Notes

**Screen Count Scaling**:
- Current: [3/5/7 screens as configured]
- Future: Design supports any screen count via `LGConfig.screenCount`
- WORLD_WIDTH calculation is dynamic: `screenWidth × screenCount`
- No hardcoded screen-specific logic

**Content Scaling**:
- Current: Single pyramid per city
- Future: Could extend to multiple pyramids (requires layer management)
- Current: Single persistent logo
- Future: Could add multiple overlays (dashboard, controls, etc.)

**Performance Considerations**:
- KML generation is synchronous (acceptable for 1 pyramid with 4 faces)
- If scaling to 100+ pyramids: Consider batch KML generation
- If scaling to real-time updates: Consider WebSocket instead of repeated SSH

**Geographic Scaling**:
- Current: Single city selection
- Future: Could extend to city list, search, autocomplete
- API-based geocoding supports any city worldwide (if Option B chosen)

---

## ✅ Completion Checklist
- [ ] All 10 sections filled with actual content (no placeholders, no TODOs)
- [ ] Architecture strategy explicitly chosen and justified
- [ ] All three LG methods have "when called" explanations
- [ ] Data flow diagram is complete with all layers
- [ ] Pyramid geometry math includes actual coordinates
- [ ] Failure cases reference specific test verification code
- [ ] Trade-off decision includes both justification and rejected alternative
- [ ] Document committed to git with message: "docs: add T2 design document"

```

**Critical**: No empty sections, no "TODO", no "[Fill this in]" placeholders allowed.

---

# 🔐 Design Document Commit Verification

After student creates the design document, verify it was saved and committed:

**Step 1: Verify file exists**

Ask student: "Run this command:"
```bash
ls docs/plans/ | grep "T2-design.md"
```

**Expected**: File name appears (e.g., `2025-02-16-T2-design.md`)

**Step 2: Verify content is complete**

Ask student: "Run this command:"
```bash
grep -c "TODO\|Fill this in\|\[.*\]" docs/plans/*T2-design.md
```

**Expected**: `0` (zero placeholders found)

If count > 0: Document has placeholders → INCOMPLETE

**Step 3: Verify commit**

Ask student: "Run this command:"
```bash
git log --oneline --all | grep -i "design"
```

**Expected**: Recent commit message containing "design document" (e.g., "docs: add T2 design document")

---

## Commit Verification Result

**If file doesn't exist**:
→ STOP
→ Say: "Design document not created. Please create `docs/plans/YYYY-MM-DD-T2-design.md` using the template provided."
→ DO NOT proceed

**If file has placeholders (TODO, [fill], etc.)**:
→ STOP
→ Say: "Design document is incomplete. The following sections have placeholders: [list them]"
→ Say: "Please complete all sections before proceeding."
→ DO NOT proceed

**If file not committed**:
→ STOP
→ Say: "Design document must be committed to git. Run:"
```bash
git add docs/plans/*T2-design.md
git commit -m "docs: add T2 design document"
```
→ Wait for commit confirmation
→ Then proceed

**Only if ALL verifications pass**:
→ Say: "✅ Design document verified and committed."

---

# ✅ Brainstorm Completion Gate

All must pass:

**Technical Understanding** (Ask these questions):
1. ✅ Student explains pyramid altitude math (why altitudeMode=relativeToGround needed)
2. ✅ Student explains loop closure (why first coord = last coord)
3. ✅ Student explains ghosting prevention (why clearKML before sendKML)
4. ✅ Student identifies correct LG method for pyramid (sendKML) and logo (sendScreenOverlay)

**Architectural Decisions**:
5. ✅ Student chooses architecture strategy (Parallel / Master-only) and justifies choice
6. ✅ Student decides coordinate source (hardcoded / API) and justifies choice

**Testing Understanding**:
7. ✅ Student identifies which test line catches Failure Case #1 (`verifyNever(mockLG.sendKML(any))`)

**Documentation**:
8. ✅ Design doc created with all 10 sections filled (no placeholders)
9. ✅ Design doc committed to git

---

## Scoring

**9/9 passed**: ✅ PROCEED immediately to lg-plan-writer

**7-8/9 passed**: ⚠️ CONDITIONAL PASS
- Review failed items with student
- Provide brief explanation
- Re-ask failed questions
- If pass on second attempt: Proceed
- If fail on second attempt: Activate `lg-skeptical-mentor`

**6 or fewer passed**: ❌ FAIL
- Activate `lg-skeptical-mentor`
- Say: "Your understanding of LG architecture is not yet solid enough to proceed. Let's review the design concepts together."
- DO NOT proceed to planning
- Recommend returning to initialization or reviewing LG documentation

---

## Final Handoff

**If ALL checkpoints pass**:

Say:

"✅ Brainstorming complete. All checkpoints passed:
- Foundation verified
- Technical understanding confirmed
- Architectural decisions documented
- Design document created and committed

Ready to generate the deterministic implementation plan?"

**Wait for student confirmation.**

**Upon confirmation, activate:**

```lg-plan-writer```

---

**No exceptions. No shortcuts. No plan without verified design.**