# CAPCARD PRO — COMPLETE UI/UX ELEMENT BREAKDOWN
# PART 2: EDITOR + SUB-SURFACES

================================================================================
SCREEN 12: EditorScreen
Route: /editor/:projectId
Priority: P0
Status: In Progress
THE MOST COMPLEX SCREEN — FULL BREAKDOWN BELOW
================================================================================

LAYOUT (5 Zones):
┌─────────────────────────────┐  Zone 1: Toolbar (56dp)
│ [←][↶][↷] Title [⚙][↑][Exp]│
├─────────────────────────────┤
│                             │  Zone 2: Preview (~35%)
│      [    PREVIEW    ]       │
│      16:9 canvas            │
│                             │
│  [⏮] [▶] [⏭]  0:00/2:30  │
├─────────────────────────────┤
│  [Seek Bar]                 │  Zone 3: Seek Bar (32dp)
├─────────────────────────────┤
│  ┌───────────────────────┐  │  Zone 4: Timeline (~25%)
│  │Video│████████████│    │  │
│  │Audio│════════════│    │  │
│  │Text │ "Hello"    │    │  │
│  └───────────────────────┘  │
├─────────────────────────────┤
│ [🎵][T][⭐][⊕][✨][↔]...   │  Zone 5: Tool Dock (56dp)
└─────────────────────────────┘

=== ZONE 1: TOOLBAR (7 elements) ===

| # | Element | Icon | Tap Action | Long-Press Action | Animation |
|---|---------|------|------------|-------------------|-----------|
| 1 | Back | ← | Exit editor (unsaved check) | - | Slide in from left |
| 2 | Undo | ↶ | Undo last command | Show undo history panel | Enable/disable opacity |
| 3 | Redo | ↷ | Redo last command | - | Enable/disable opacity |
| 4 | Project Title | Text | Inline rename | - | Tap → text field expand |
| 5 | Settings | ⚙ | Project settings sheet | - | Rotate 90° on open |
| 6 | Share | ↑ | Share sheet | - | Scale 0.9→1.0 |
| 7 | Export | "Export" | Export flow | - | Pulse glow when ready |

Toolbar Animations:
- Undo/Redo: Enable/disable with opacity 1.0→0.3, 150ms
- Title edit: Text → TextField expand, 200ms
- Settings: Icon rotate 0→90° when sheet open
- Export: Subtle pulse glow (brand500 at 20% opacity, 2s loop) when timeline has content

=== ZONE 2: PREVIEW CANVAS (17 elements) ===

VIDEO PLAYER:
| # | Element | Type | Size | Interaction |
|---|---------|------|------|-------------|
| 8 | Video Player | VideoPlayer | 16:9 aspect | Tap = Play/Pause |
| 9 | Play/Pause Overlay | IconButton | 64dp center | Tap = Toggle playback |
| 10 | Buffering Indicator | CircularProgress | 32dp | Show when loading |

PLAYBACK CONTROLS (Auto-hide after 3s of inactivity):
| # | Element | Icon | Tap Action | Long-Press Action |
|---|---------|------|------------|-------------------|
| 11 | Rewind 10s | ⏮ | Jump back 10s | Continuous rewind (accelerating) |
| 12 | Play/Pause | ▶/❚❚ | Toggle playback | - |
| 13 | Forward 10s | ⏭ | Jump forward 10s | Continuous forward (accelerating) |
| 14 | Current Time | Text | Shows 0:00 / 2:30 | - |
| 15 | Fullscreen | ⛶ | Toggle fullscreen | - |

CANVAS OVERLAYS (Contextual, based on selection):
| # | Element | When Visible | Appearance | Interaction |
|---|---------|-----------|------------|-------------|
| 16 | Safe Zone Guides | Text selected | White lines, 20% opacity, 90%/93% boundaries | Static |
| 17 | Grid Overlay | Toggle on | Rule of thirds, 15% opacity | Static |
| 18 | Text Bounding Box | Text selected | Purple border (brand500), drag handles at corners | Drag = move, corner drag = scale, rotate handle = rotate |
| 19 | Sticker Bounding Box | Sticker selected | Same as text, pink border (trackText) | Same as text |
| 20 | Picture-in-Picture Frame | PiP selected | Gold border (trackOverlay), corner resize handles | Drag = move, corner = resize, maintain aspect ratio |
| 21 | Crop Handles | Crop mode active | White lines with 8 drag points (4 corners, 4 edges) | Drag points = crop, edge drag = single axis, corner = free crop |
| 22 | Chroma Key Color Picker | Chroma key active | Circular loupe showing color under finger | Tap on video = pick color, slider = tolerance |
| 23 | Mask Shape | Mask mode active | Shape outline (linear, radial, custom) with feather slider | Drag = position, slider = feather |

PREVIEW GESTURES:
| Gesture | Action | Condition |
|---------|--------|-----------|
| Tap | Play/Pause | No overlay selected |
| Double-tap | Toggle fullscreen | Always |
| Pinch | Zoom canvas | Always |
| Two-finger pan | Pan canvas | Zoomed in |
| Single-finger drag | Move selected overlay | Overlay selected |
| Long-press | Context menu | Always |
| Tap on canvas (no overlay) | Deselect all | Always |

Preview Animations:
- Play/Pause overlay: Fade in on tap, fade out after 1s
- Bounding box: Scale 0.9→1.0 on select, spring physics
- Crop handles: Appear with staggered fade (50ms apart)
- Safe zones: Fade in 200ms when text selected, fade out on deselect

=== ZONE 3: SEEK BAR (5 elements) ===

| # | Element | Type | Size | Color | Interaction |
|---|---------|------|------|-------|-------------|
| 24 | Track Background | Container | Full-4dp | bgOverlay | Tap to jump |
| 25 | Buffered Progress | Container | Variable | textLow 30% | Shows loaded range |
| 26 | Played Progress | Container | Variable | brand500 | Fills as video plays |
| 27 | Scrubber Thumb | Circle | 16dp | brand500 | Drag to scrub |
| 28 | Time Tooltip | Container | Wrap | bgSurface | Shows time while dragging |

Seek Bar Interactions:
- Tap track: Jump to position, haptic light impact
- Drag thumb: Scrub with time tooltip following finger
- Drag near edges: Auto-scroll timeline at variable speed
- Release: Snap to nearest frame, haptic light impact
- Update: Progress animates smoothly during playback

Seek Bar Animations:
- Thumb: Scale 1.0→1.3 on drag, spring release
- Tooltip: Fade in on drag, fade out on release
- Progress: Width animates with 60fps sync

=== ZONE 4: TIMELINE (32 elements) ===

RULER:
| # | Element | Type | Size | Color | Interaction |
|---|---------|------|------|-------|-------------|
| 29 | Ruler Background | Container | Full-24dp | bgTimeline (#080810) | - |
| 30 | Time Markers | Text | 10sp | textLow | Every 1s/5s/10s based on zoom |
| 31 | Beat Markers | Small ticks | 4dp | brand500 | If beat detection enabled |
| 32 | Playhead Line | Vertical line | 2dp | textHigh | Follows playback |
| 33 | Playhead Shadow | Container | 2dp blur | 20% black | 8px below line |
| 34 | Playhead Time Bubble | Container | Wrap | bgSurface | Shows current time, follows playhead |
| 35 | Markers | Small flags | 12x8dp | warning | Tap to edit, drag to move |

TRACK HEADERS (Left, 48dp wide):
| # | Element | Type | Size | Color | Interaction |
|---|---------|------|------|-------|-------------|
| 36 | Track Icon | Icon | 24dp | textMedium | Tap to lock/hide |
| 37 | Lock Toggle | IconButton | 24dp | textLow → warning (locked) | Toggle track lock |
| 38 | Eye Toggle | IconButton | 24dp | textMedium → textLow (hidden) | Toggle track visibility |
| 39 | Add Track Button | IconButton | 24dp | brand500 | Opens add track menu |

TRACKS (4 types):
| # | Track Type | Color | Clip Appearance | Clip Content |
|---|------------|-------|-----------------|--------------|
| 40 | Video | #4A3DB5 | Filmstrip thumbnails + duration badge | 3 frames from clip |
| 41 | Audio | #00CEC9 | Waveform visualization | Amplitude data |
| 42 | Text | #FD79A8 | Pink bar with text preview | First 20 chars |
| 43 | Effects | #F39C12 | Gold bar with effect icon | Effect name + icon |

CLIP INTERACTIONS (When Selected):
| # | Element | Type | Size | Color | Interaction |
|---|---------|------|------|-------|-------------|
| 44 | Left Trim Handle | Vertical bar | 8dp wide | textHigh | Drag to trim start |
| 45 | Right Trim Handle | Vertical bar | 8dp wide | textHigh | Drag to trim end |
| 46 | Split Indicator | Dashed line | 1dp | textHigh | At playhead, tap to split |
| 47 | Delete Button | IconButton | 32dp | error | Tap to delete clip |
| 48 | Copy Button | IconButton | 32dp | textMedium | Tap to duplicate |
| 49 | Replace Button | IconButton | 32dp | textMedium | Tap to swap media |
| 50 | Speed Button | IconButton | 32dp | textMedium | Opens speed panel |
| 51 | Volume Button | IconButton | 32dp | textMedium | Opens volume slider |
| 52 | Animation Button | IconButton | 32dp | textMedium | Opens animation presets |
| 53 | Edit Button | IconButton | 32dp | brand500 | Opens full clip editor |

CLIP STATES:
| State | Visual | Duration |
|-------|--------|----------|
| Idle | Normal opacity, no border | - |
| Selected | brand500 border (2dp), subtle glow, handles appear | 150ms fade |
| Dragging | Opacity 80%, ghost preview, snap guides | Real-time |
| Trimming | Handle highlights, time tooltip | Real-time |
| Splitting | Flash at split point | 100ms |

SNAP SYSTEM:
| # | Element | Visual | Trigger |
|---|---------|--------|---------|
| 54 | Snap Guide Line | Yellow dashed, 1dp, 4px dash | During drag, near snap target |
| 55 | Snap Target Highlight | Clip edge glows yellow | When playhead/clip aligns |
| 56 | Snap Haptic | Light impact | On snap |

TIMELINE GESTURES:
| Gesture | Action | Haptic |
|---------|--------|--------|
| Horizontal pan | Scroll timeline | None |
| Pinch | Zoom timeline (0.1x→10x) | Light impact at snap points |
| Two-finger vertical pan | Reorder tracks | Light impact per track |
| Tap clip | Select clip | Light impact |
| Double-tap clip | Enter edit mode | Medium impact |
| Long-press clip | Lift for drag | Medium impact + lift animation |
| Drag clip | Move with magnetic snap | Light impact per snap |
| Drag trim handle | Resize clip | Light impact at frame boundaries |
| Drag playhead | Scrub preview | None (smooth) |
| Swipe clip left | Quick delete (with undo) | Heavy impact |

=== ZONE 5: TOOL DOCK (24 elements) ===

PRIMARY TOOLS (Always visible):
| # | Tool | Icon | Label | Panel Opened | Color |
|------|------|------|-------|--------------|-------|
| 57 | Audio | 🎵 | "Audio" | Audio panel (add music, sound effects, voiceover) | textMedium |
| 58 | Text | T | "Text" | Text panel (add titles, captions, credits) | textMedium |
| 59 | Stickers | ⭐ | "Stickers" | Sticker panel (browse, search, favorites) | textMedium |
| 60 | Overlay | ⊕ | "Overlay" | Overlay panel (picture-in-picture) | textMedium |
| 61 | Effects | ✨ | "Effects" | Effects panel (visual effects grid) | textMedium |

SWIPE LEFT REVEALS (Secondary tools):
| # | Tool | Icon | Label | Panel Opened | Color |
|------|------|------|-------|--------------|-------|
| 62 | Transitions | ↔ | "Trans" | Transition panel (crossfade, wipe, slide) | textMedium |
| 63 | Filters | 🎨 | "Filter" | Filter panel (LUTs, color filters) | textMedium |
| 64 | Adjust | ☀ | "Adjust" | Color grading panel (exposure, contrast, etc.) | textMedium |
| 65 | Format | ▭ | "Format" | Aspect ratio panel (9:16, 1:1, 16:9, 4:3) | textMedium |
| 66 | Background | ⬛ | "BG" | Background panel (color, blur, image) | textMedium |
| 67 | Canvas | □ | "Canvas" | Canvas settings (color, pattern) | textMedium |
| 68 | Speed | ⏩ | "Speed" | Speed panel (0.1x-100x, curves) | textMedium |
| 69 | Reverse | ↩ | "Reverse" | Reverse dialog (confirm + preview) | textMedium |
| 70 | Freeze | ❄ | "Freeze" | Freeze frame tool (duration selector) | textMedium |
| 71 | Voice Effects | 🎙 | "Voice FX" | Voice changer (chipmunk, robot, etc.) | textMedium |
| 72 | Voiceover | 🎤 | "Voiceover" | Recording panel (countdown + record) | textMedium |
| 73 | Reduce Noise | 🔇 | "Denoise" | Toggle + intensity slider | textMedium |
| 74 | Beat Sync | 🥁 | "Beat" | Beat detection + auto-sync cuts | textMedium |
| 75 | Auto Captions | CC | "Captions" | AI captioning flow | textMedium |
| 76 | Auto Lyrics | 🎶 | "Lyrics" | AI lyrics sync (for music videos) | textMedium |
| 77 | 3D Zoom | 3D | "3D Zoom" | Ken Burns effect panel | textMedium |
| 78 | Mask | 🎭 | "Mask" | Mask tool (linear, radial, custom) | textMedium |
| 79 | Chroma Key | 🟩 | "Chroma" | Green screen (color pick + tolerance) | textMedium |
| 80 | Retouch | ✨ | "Retouch" | Beauty/retouch panel (smooth, whiten, etc.) | textMedium |

TOOL DOCK INTERACTIONS:
- Tap tool: Panel slides up from bottom (250ms, easeOutCubic)
- Active tool: Icon scale 1.15, brand500 color, glow effect
- Swipe dock: Horizontal scroll with snap physics
- Long-press tool: Tooltip with tool name
- Panel drag down: Dismiss with velocity-based fling
- Multiple panels: Only one open at a time, previous slides down

TOOL DOCK ANIMATIONS:
- Tool select: Scale 1.0→1.15→1.0, 200ms spring
- Panel open: translateY 100%→0%, 250ms easeOutCubic
- Panel close: translateY 0%→100%, 200ms easeInCubic
- Content stagger: Items appear 20ms apart, slideUp + fadeIn
- Background: BackdropFilter blur 0→10, 200ms

EDITOR SCREEN TOTAL: 80 interactive elements

================================================================================
SURFACES 1-10: EDITOR SUB-SURFACES
================================================================================

SURFACE 1: Audio Panel
Trigger: Tap "Audio" (🎵) in tool dock
Type: Bottom sheet (60% height)

ELEMENTS:
| # | Element | Type | Action |
|---|---------|------|--------|
| 1 | Panel Header | Row | "Audio", close button |
| 2 | Search Bar | TextField | Search audio library |
| 3 | Category Tabs | TabBar | Featured, Music, Sound Effects, Voiceover, Extracted |
| 4 | Audio Item | ListTile | Preview, duration, add to timeline |
| 5 | Favorite Button | IconButton | Toggle favorite |
| 6 | Volume Preview | Slider | Preview volume before adding |
| 7 | Import Audio | Button | Import from device |
| 8 | Record Voiceover | Button | Open recording panel |
| 9 | Extract Audio | Button | Extract from video clip |

SURFACE 2: Text Panel
Trigger: Tap "Text" (T) in tool dock
Type: Bottom sheet

ELEMENTS:
| # | Element | Type | Action |
|---|---------|------|--------|
| 1 | Header | Row | "Text", close |
| 2 | Quick Add | Button | "Add Text" → adds default text clip |
| 3 | Text Templates | Grid | Pre-designed text animations |
| 4 | Template Card | Card | Preview GIF, tap to apply |
| 5 | Custom Text | Button | "Custom" → inline text editor |
| 6 | Captions | Button | "Auto Captions" → AI flow |
| 7 | Credits | Button | "Credits" → rolling credits template |
| 8 | Lower Thirds | Button | "Lower Third" → news-style template |

SURFACE 3: Stickers Panel
Trigger: Tap "Stickers" (⭐)
Type: Bottom sheet

ELEMENTS:
| # | Element | Type | Action |
|---|---------|------|--------|
| 1 | Header | Row | "Stickers", close |
| 2 | Search | TextField | Search stickers |
| 3 | Category Pills | Chips | Trending, Emotions, Celebrations, Reactions |
| 4 | Sticker Grid | GridView | 4 columns, tap to add |
| 5 | Sticker Item | Image/GIF | Animated or static |
| 6 | Favorite | IconButton | Toggle favorite |
| 7 | Recently Used | Section | Horizontal scroll |
| 8 | Import Sticker | Button | Upload custom sticker |

SURFACE 4: Overlay Panel
Trigger: Tap "Overlay" (⊕)
Type: Bottom sheet

ELEMENTS:
| # | Element | Type | Action |
|---|---------|------|--------|
| 1 | Header | Row | "Overlay", close |
| 2 | Add Overlay | Button | Select video/image for PiP |
| 3 | Overlay List | List | Existing overlays in project |
| 4 | Blend Mode | Dropdown | Normal, Screen, Multiply, Overlay, Soft Light |
| 5 | Opacity | Slider | 0-100% |
| 6 | Mask | Button | Apply mask to overlay |
| 7 | Animation | Button | Entry/exit animation |

SURFACE 5: Effects Panel
Trigger: Tap "Effects" (✨)
Type: Bottom sheet

ELEMENTS:
| # | Element | Type | Action |
|---|---------|------|--------|
| 1 | Header | Row | "Effects", close |
| 2 | Search | TextField | Search effects |
| 3 | Category Tabs | TabBar | Trending, Basic, Cinematic, Retro, Glitch, Beauty |
| 4 | Effect Grid | GridView | 3 columns, preview thumbnail |
| 5 | Effect Card | Card | Preview GIF, name, duration |
| 6 | Favorite | IconButton | Toggle favorite |
| 7 | Intensity | Slider | 0-100% after apply |
| 8 | Duration | Slider | Effect duration on timeline |
| 9 | Pro Badge | Chip | "Pro" on premium effects |
| 10 | Apply Button | Button | Appears on hover/select |

SURFACE 6: Transitions Panel
Trigger: Tap "Trans" (↔)
Type: Bottom sheet

ELEMENTS:
| # | Element | Type | Action |
|---|---------|------|--------|
| 1 | Header | Row | "Transitions", close |
| 2 | Category Tabs | TabBar | Basic, Slide, Wipe, Fade, 3D, Glitch |
| 3 | Transition Grid | GridView | 3 columns |
| 4 | Transition Card | Card | Preview video, name |
| 5 | Duration | Slider | 0.5-5 seconds |
| 6 | Apply to All | Button | Apply transition between all clips |
| 7 | Pro Badge | Chip | "Pro" on premium transitions |

SURFACE 7: Filters Panel
Trigger: Tap "Filter" (🎨)
Type: Horizontal scroll panel (bottom)

ELEMENTS:
| # | Element | Type | Action |
|---|---------|------|--------|
| 1 | Filter Strip | ListView | Horizontal, 80x120dp cards |
| 2 | Filter Card | Card | Preview thumbnail, name |
| 3 | Intensity Slider | Slider | 0-100% |
| 4 | Compare Button | Button | Hold to see before/after |
| 5 | Reset | Button | Remove filter |
| 6 | Custom | Button | "Create Custom" → adjust panel |

SURFACE 8: Adjust (Color Grading) Panel
Trigger: Tap "Adjust" (☀)
Type: Full-screen sheet (85% height)

ELEMENTS:
| # | Element | Type | Action |
|---|---------|------|--------|
| 1 | Header | Row | "Adjust", close, reset, compare |
| 2 | Presets | Grid | "Normal", "Bright", "Cinematic", "Moody", etc. |
| 3 | Adjustment List | ListView | Exposure, Contrast, Highlights, Shadows, Whites, Blacks, Saturation, Vibrance, Temperature, Tint, Sharpness, Clarity, Dehaze, Vignette, Grain |
| 4 | Adjustment Slider | Slider | -100 to +100 per adjustment |
| 5 | Value Display | Text | Current value |
| 6 | Before/After | Split | Drag to compare |
| 7 | Histogram | CustomPaint | Real-time waveform |
| 8 | Curves | Button | "Curves" → Curves Editor |
| 9 | Color Wheels | Button | "Color Wheels" → Wheels Editor |
| 10 | HSL | Button | "HSL" → Hue/Saturation/Lightness per color |

SURFACE 9: Curves Editor
Trigger: Tap "Curves" in Adjust panel
Type: Modal (90% height)

SURFACE 10: Color Wheels Editor
Trigger: Tap "Color Wheels" in Adjust panel
Type: Modal

================================================================================
SURFACES 11-20: ADVANCED TOOLS
================================================================================

SURFACES 11-20: Speed, Reverse, Freeze, Voice Effects, Voiceover, Denoise, Beat Sync, 3D Zoom, Mask, Chroma Key, Retouch
Pattern: Bottom sheet or modal with specific controls

SURFACE 21: AI Captioning Flow
Trigger: Tap "Captions" in tool dock or AI Studio
Type: Multi-step wizard sheet

STEP 1: Language Selection
STEP 2: Processing
STEP 3: Review & Edit

SURFACE 22: Properties Panel (Contextual)
Trigger: Tap any clip
Type: Side panel (right, 280dp, slides in)

SURFACE 23: Multi-select Toolbar
Trigger: Long-press → select multiple
Type: Floating bar (bottom, above tool dock)

SURFACE 24: Context Menu (Radial)
Trigger: Long-press clip
Type: Radial menu around finger

SURFACE 25: Timeline Zoom Controls
Trigger: Pinch or tap zoom button
Type: Floating slider

SURFACE 26: Track Header Menu
Trigger: Tap track name
Type: Dropdown

SURFACE 27: Add Track Menu
Trigger: Tap "+" next to tracks
Type: Bottom sheet

SURFACE 28: Marker Editor
Trigger: Tap marker on ruler
Type: Inline label + color picker

SURFACE 29: Snap Guide Config
Trigger: Tap settings in timeline
Type: Toggle sheet

SURFACE 30: Proxy Media Toggle
Trigger: Tap settings → "Proxy"
Type: Confirmation + progress

SURFACE 31: Undo History Panel
Trigger: Tap undo arrow → hold
Type: Scrollable list sheet

SURFACE 32: Project Settings
Trigger: Tap title → "Settings"
Type: Bottom sheet

SURFACE 33: Share Sheet
Trigger: Tap "Share"
Type: Native share + custom options

SURFACE 34: Export Settings Panel
Trigger: Tap "Export"
Type: Bottom sheet

SURFACE 35: Export Progress Overlay
Trigger: During export
Type: Full-screen with cancel

SURFACE 36: Export Complete Celebration
Trigger: After export
Type: Confetti + share buttons

SURFACE 37: Keyboard Shortcuts Help
Trigger: Tap "?" in toolbar
Type: Overlay cheat sheet

SURFACES 38-50: Additional tool-specific panels
