---
name: Flutter Liquid Galaxy WOW Asset Generator
description: AI-assisted visual asset generation pipeline for ScreenOverlay usage in Flutter-based Liquid Galaxy demos.
---

# 🎨 WOW Asset Generator (Flutter Edition)

This skill defines how to generate and integrate high-impact visual assets for Liquid Galaxy demos using AI image models.

It is responsible for:

- Crafting deterministic AI prompts
- Enforcing rig-safe asset constraints
- Preparing assets for ScreenOverlay usage
- Ensuring resolution and alignment compliance
- Preventing visual artifacts on LG rigs

It is NOT responsible for:

- Rendering game sprites
- Performing physics calculations
- Building KML geometry
- Sending SSH commands

It generates assets only.

---

# 🎯 Architectural Role

Layer: `presentation/assets/`

This layer:

- Produces image assets
- Supplies URLs or local assets
- Works with MultiScreenVisualizationService for overlay display

It does NOT:

- Call LGConnectionService directly
- Modify KmlBuilder
- Calculate world coordinates

Separation maintained.

---

# 📜 Policy Mapping

| Policy ID | Title | Enforcement |
|-----------|-------|-------------|
| LG-041 | ScreenOverlay Persistence | Assets must be compatible with persistent overlay rendering |
| LG-040 | Bezel-Safe Placement | Design centered for master screen |
| LG-060 | KML Payload Size Limit | Image file size must be optimized (< 500KB recommended) |
| SAF-022 | Error Boundary | Invalid/missing asset must not crash demo |
| SAF-003 | No Hardcoded Credentials | No embedded URLs with secrets |

This skill does NOT enforce geometry rules.

---

# 🎨 Phase 1 — Deterministic AI Prompting

AI models (e.g., Imagen, Gemini image models) must receive structured prompts.

## Prompt Template (Flutter + LG Safe)

> "Centered high-resolution [Object]. Transparent background or solid chroma green (#00FF00). Minimal shadow. High contrast. Symmetrical composition. Designed for 1080x1920 portrait orientation. Clean edges. No watermark."

Important:

- Centered composition
- Portrait safe ratio (LG control tablet is portrait)
- No perspective distortion
- No background clutter

---

# 🧼 Phase 2 — Transparency Strategy

Preferred: Native transparent PNG.

Fallback: Chroma key (#00FF00).

For Flutter, background removal should be done:

- Offline before bundling
- OR using image processing library (NOT in production loop)

Never perform heavy pixel loops in UI thread.

No JS-style canvas hacks.

---

# 📏 Phase 3 — Resolution & Scaling Rules

Liquid Galaxy rigs are high-resolution environments.
Assets must be optimized for clarity, alignment, and performance.

Rules:

- Minimum 1080x1080 for square overlays
- Maximum recommended resolution: 1080x1920 (portrait)
- Avoid assets below 512px (prevents pixelation on rig screens)
- Maintain strict 1:1 or 9:16 ratio
- Crop transparent padding to ensure tight visual alignment
- Center visual subject precisely (bezel-safe composition)
- Optimize using PNG compression (target < 500KB)

Assets exceeding 1080x1920 must be resized before integration.

Do NOT exceed payload optimization limits by embedding large Base64 blobs inside KML.
KML must remain lightweight and geometry-focused.

ScreenOverlay should reference:

- Optimized HTTP URL
OR
- Local pre-synced file path

---

# 🖼 Integration Pattern

Asset must be passed into visualization layer:

```dart
await _visualService.displayLogoOverlay(
  imageUrl: "https://your-cdn.com/logo.png",
  overlayX: 0.5,
  overlayY: 0.9,
);
```

This skill does NOT:

- Call sendScreenOverlay directly
- Clear KML
- Manipulate rig state

# 🧪 Validation Checklist

Before committing an asset:

- Centered composition
- No watermark
- Transparent or clean chroma background
- File size optimized (< 500KB recommended)
- No broken URL
- Works with sendScreenOverlay()

If asset fails to load:

→ Catch error at feature layer (SAF-022)
→ Display fallback UI asset
→ Do NOT crash demo flow
→ Do NOT leave rig in broken overlay state

# 🚫 What This Skill Does NOT Do

❌ Does NOT manipulate KML strings
❌ Does NOT build geometry
❌ Does NOT open SSH
❌ Does NOT calculate payload length
❌ Does NOT embed base64 blobs into KML

Strict asset generation only.

# 🧠 Design Principles

SOLID:

- Single Responsibility → Asset generation only
- Dependency Inversion → Passed into visualization layer

DRY:

- No duplicate overlay logic
- No duplicate compression logic across layers

YAGNI:

- No animation engine
- No sprite physics
- No multi-frame sprite system

Keep it minimal.

# 🏁 Definition of Done

- Asset prompt defined
- Asset generated
- File optimized
- URL or path validated
- Integrated through visualization service
- No direct transport calls
- No policy violation

# 📝 Commit Convention

Commit format must follow:

feat(presentation): add optimized logo asset for LG overlay

Scope MUST be presentation.
No logic changes allowed in this commit.


---

# 🧠 Strategic Question

If someone encodes a 4MB PNG as Base64 directly inside a KML string for convenience,

is that:

PASS  
CONDITIONAL PASS  
or FAIL?

Think in terms of LG-060 and rig stability.