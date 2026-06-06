# CAPCARD PRO — COMPLETE UI/UX ELEMENT BREAKDOWN
# From SplashScreen to Export Complete
# Every button, element, animation, and interaction specified

================================================================================
PART 1: ROOT SCREENS (29 screens)
================================================================================

--------------------------------------------------------------------------------
SCREEN 1: SplashScreen
Route: /splash
Priority: P0
Status: Done (T-003)
--------------------------------------------------------------------------------

LAYOUT:
┌─────────────────────────────┐
│                             │
│                             │
│        [LOGO ICON]          │  ← Center, 120x120dp, brand500
│                             │
│        "CapCard"            │  ← 28sp, w700, textHigh
│        "Pro"                │  ← 20sp, w600, brand300, smaller
│                             │
│      [Loading Indicator]    │  ← Circular, brand500, 4dp stroke
│                             │
│      v1.0.0                 │  ← Bottom, 12sp, textLow
│                             │
└─────────────────────────────┘

ELEMENTS:
| # | Element | Type | Size | Color | Animation |
|---|---------|------|------|-------|-----------|
| 1 | Logo Icon | SVG/Image | 120x120dp | brand500 | Scale 0→1, spring physics |
| 2 | "CapCard" Text | Text | 28sp, w700 | textHigh | Fade in, 100ms delay |
| 3 | "Pro" Text | Text | 20sp, w600 | brand300 | Fade in, 200ms delay |
| 4 | Loading Spinner | CircularProgress | 32dp | brand500 | Rotate infinite, 1s linear |
| 5 | Version Text | Text | 12sp, w400 | textLow | Fade in, 400ms delay |

BUTTONS: None (auto-transition after 2.5s)

INTERACTIONS:
- Auto-navigates to OnboardingScreen (first launch) or MainScreen (returning user)
- Transition: Fade out 300ms → cross-fade to next screen

ANIMATIONS:
- Logo: Scale 0.5→1.0 with overshoot (spring: damping 0.7, stiffness 200, mass 0.5)
- Text: Opacity 0→1, translateY 20→0, staggered 100ms apart
- Spinner: Fade in after logo settles
- Background: Solid bgBase (#0A0A0F)

HAPTICS: None

--------------------------------------------------------------------------------
SCREEN 2: OnboardingScreen
Route: /onboarding
Priority: P0
Status: Done (T-004)
--------------------------------------------------------------------------------

LAYOUT:
┌─────────────────────────────┐
│  [Skip]          [• • •]    │  ← Top bar
├─────────────────────────────┤
│                             │
│  ┌─────────────────────┐    │
│  │                     │    │  ← Illustration (parallax)
│  │    ILLUSTRATION     │    │  ← 280x280dp, centered
│  │                     │    │
│  └─────────────────────┘    │
│                             │
│  "Edit Like a Pro"          │  ← Headline, 28sp, w700
│  "Professional timeline..." │  ← Description, 16sp, textMedium
│                             │
│                             │
│  [        Next        ]     │  ← Slides 1-2: "Next"
│                             │  ← Slide 3: "Get Started" (brand500)
└─────────────────────────────┘

ELEMENTS:
| # | Element | Type | Size | Color | Animation |
|---|---------|------|------|-------|-----------|
| 1 | Skip Button | TextButton | Wrap | textLow | Fade in, top-right |
| 2 | Page Indicator | Row of dots | 8dp each | brand500 (active), textLow (inactive) | Scale active dot 1.0→1.2 |
| 3 | Illustration | Image/Lottie | 280x280dp | - | Parallax scroll effect |
| 4 | Headline | Text | 28sp, w700 | textHigh | Slide up + fade per slide |
| 5 | Description | Text | 16sp, w400 | textMedium | Slide up + fade, 100ms delay |
| 6 | CTA Button | ElevatedButton | Full-48dp | bgSurface (Next), brand500 (Get Started) | Scale in, 200ms delay |

BUTTONS:
| # | Button | Label | Action | Visual |
|------|--------|-------|--------|--------|
| 1 | Skip | "Skip" | Navigate to LoginScreen | TextButton, textLow |
| 2 | CTA (Slides 1-2) | "Next" | Next slide with parallax | bgSurface, textHigh |
| 3 | CTA (Slide 3) | "Get Started" | Navigate to SignupScreen | brand500 bg, white text, pulse glow |

SLIDES (3 total):
| Slide | Headline | Description | Illustration |
|-------|----------|-------------|--------------|
| 1 | "Edit Like a Pro" | "Professional timeline editing with magnetic snap and GPU effects" | Phone with timeline |
| 2 | "AI-Powered Creation" | "Auto captions, voice clone, and text-to-video in one tap" | AI robot + sparkles |
| 3 | "Export in Seconds" | "4K exports with one tap. Share everywhere instantly" | Export/share icons |

INTERACTIONS:
- Horizontal swipe: Changes slide with parallax (illustration moves 0.5x speed of text)
- Page indicator: Tap dot → jump to slide
- CTA press: Spring scale 0.95→1.0
- Skip press: Fade out, navigate to login

ANIMATIONS:
- Slide transition: Shared element, illustration parallax
- Parallax: Illustration translateX = scrollOffset * 0.3
- CTA on last slide: Subtle pulse glow (brand500 at 30% opacity, 2s loop)
- Page indicator: Active dot scale 1.0→1.2, 200ms

HAPTICS:
- Slide swipe complete: Light impact
- CTA tap: Light impact
- Last slide CTA: Medium impact (celebratory)

--------------------------------------------------------------------------------
SCREEN 3: LoginScreen
Route: /login
Priority: P0
Status: Done (T-006)
--------------------------------------------------------------------------------

LAYOUT:
┌─────────────────────────────┐
│  [← Back]                   │
├─────────────────────────────┤
│      Welcome Back           │
│      Sign in to continue    │
│                             │
│  [📧 Email input    ]       │
│  [🔒 Password input ]       │
│                             │
│  [      Sign In      ]      │
│                             │
│  ───── or continue with ────│
│                             │
│  [🟢 Google]  [⚫ Apple]    │
│                             │
│  Forgot Password?           │
│  Don't have account? Sign Up│
│                             │
└─────────────────────────────┘

ELEMENTS:
| # | Element | Type | Size | Color | Animation |
|---|---------|------|------|-------|-----------|
| 1 | Back Button | IconButton | 48x48dp | textHigh | Slide in from left |
| 2 | "Welcome Back" | Text | 28sp, w700 | textHigh | Fade in |
| 3 | "Sign in to continue" | Text | 16sp, w400 | textMedium | Fade in, 200ms delay |
| 4 | Email Field | TextField | Full-56dp | bgSurface border | Slide up, 300ms delay |
| 5 | Email Icon | Prefix icon | 24dp | textLow | Fade in with field |
| 6 | Password Field | TextField | Full-56dp | bgSurface border | Slide up, 400ms delay |
| 7 | Password Icon | Prefix icon | 24dp | textLow | Fade in with field |
| 8 | Eye Toggle | Suffix icon | 48x48dp | textLow | Tap to show/hide password |
| 9 | Sign In Button | ElevatedButton | Full-48dp | brand500 | Scale in, 500ms delay |
| 10 | Divider Line | Container | 1dp | bgOverlay | Fade in |
| 11 | "or continue with" | Text | 14sp | textLow | Fade in |
| 12 | Google Button | OutlinedButton | 120x48dp | bgSurface | Slide up, 600ms delay |
| 13 | Google Icon | Image | 24dp | Original colors | Fade in |
| 14 | Apple Button | OutlinedButton | 120x48dp | bgSurface | Slide up, 700ms delay |
| 15 | Apple Icon | Image | 24dp | White | Fade in |
| 16 | "Forgot Password?" | TextButton | Wrap | brand500 | Fade in |
| 17 | "Don't have account?" | Text | 14sp | textMedium | Fade in |
| 18 | "Sign Up" link | TextButton | Wrap | brand500 | Fade in |

BUTTONS:
| # | Button | Label | Action | Visual |
|------|--------|-------|--------|--------|
| 1 | Back | Arrow left | Pop to Splash/Onboarding | IconButton |
| 2 | Sign In | "Sign In" | Validate → API call → MainScreen | brand500, spring press |
| 3 | Google | "Google" | OAuth flow → MainScreen | Outlined, white bg |
| 4 | Apple | "Apple" | Sign in with Apple → MainScreen | Outlined, white bg |
| 5 | Forgot Password | "Forgot Password?" | Navigate to ForgotPasswordScreen | Text, brand500 |
| 6 | Sign Up | "Sign Up" | Navigate to SignupScreen | Text, brand500, bold |

FORM VALIDATION:
| Field | Rule | Error Message | Error State |
|-------|------|---------------|-------------|
| Email | Valid email regex | "Please enter a valid email" | Border error color, shake |
| Password | 8+ chars, 1 uppercase, 1 number | "Password must be 8+ chars with uppercase and number" | Border error color, shake |

ANIMATIONS:
- Fields: Slide up from 20dp offset + fade
- Sign In button: Pulse glow when form valid
- Error: Shake animation (translateX -8→8→-8→8→0, 400ms)
- Loading: Button text → CircularProgress (24dp, white)
- Success: Navigate with fade transition

HAPTICS:
- Field focus: Light impact
- Invalid submit: Error buzz (3x light impact)
- Valid submit: Medium impact
- Social login: Medium impact

--------------------------------------------------------------------------------
SCREEN 4: SignupScreen
Route: /signup
Priority: P0
Status: Done (T-007)
--------------------------------------------------------------------------------

LAYOUT: Similar to LoginScreen with additional fields

ADDITIONAL ELEMENTS:
| # | Element | Type | Size | Color | Action |
|---|---------|------|------|-------|--------|
| 1 | Name Field | TextField | Full-56dp | bgSurface border | Full name input |
| 2 | Phone Field | TextField | Full-56dp | bgSurface border | Optional phone |
| 3 | Confirm Password | TextField | Full-56dp | bgSurface border | Must match password |
| 4 | Terms Checkbox | Checkbox | 24dp | brand500 | Required |
| 5 | "I agree to Terms" | Text | 14sp | textMedium | Tap opens Terms sheet |
| 6 | "and Privacy Policy" | Text | 14sp | textMedium | Tap opens Privacy sheet |

BUTTONS:
| # | Button | Label | Action |
|------|--------|-------|--------|
| 1 | Sign Up | "Create Account" | Validate all → API → OTP screen |
| 2 | Login link | "Already have account? Log In" | Navigate to LoginScreen |

OTP FLOW:
- After signup: Auto-navigate to OtpVerificationScreen with phone number passed
- Resend OTP: 30s countdown, then "Resend" button activates

--------------------------------------------------------------------------------
SCREEN 5: OtpVerificationScreen
Route: /otp-verification
Priority: P0
Status: Done (T-008)
--------------------------------------------------------------------------------

LAYOUT:
┌─────────────────────────────┐
│  [← Back]                   │
├─────────────────────────────┤
│      Verify Phone           │
│      Code sent to +91...    │
│                             │
│  [ 1 ] [ 2 ] [ 3 ] [ 4 ]    │  ← 4 boxes, 56x56dp each
│                             │
│  [      Verify      ]       │
│                             │
│  Resend code in 00:30       │  ← Countdown timer
│                             │
└─────────────────────────────┘

ELEMENTS:
| # | Element | Type | Size | Color | Animation |
|---|---------|------|------|-------|-----------|
| 1 | Back | IconButton | 48x48dp | textHigh | Slide in |
| 2 | "Verify Phone" | Text | 28sp, w700 | textHigh | Fade in |
| 3 | Phone Number | Text | 16sp, w400 | textMedium | Fade in |
| 4-7 | OTP Boxes | Container | 56x56dp | bgSurface border | Scale in staggered |
| 8 | Verify Button | ElevatedButton | Full-48dp | brand500 (when filled) | Scale in |
| 9 | Resend Timer | Text | 14sp | textLow | Countdown animation |
| 10 | Resend Button | TextButton | Wrap | brand500 (when timer 0) | Fade in |

BUTTONS:
| # | Button | Label | Action | Visual |
|------|--------|-------|--------|--------|
| 1 | Back | Arrow left | Pop to Signup | IconButton |
| 2 | Verify | "Verify" | API call → MainScreen | brand500 when 4 digits entered |
| 3 | Resend | "Resend Code" | API call → reset timer | TextButton, appears after 30s |

INTERACTIONS:
- Auto-focus first box on open
- Typing fills boxes left-to-right
- Backspace clears current, moves left
- Paste: Auto-distributes 4 digits
- Box focus: Border brand500, scale 1.05
- Box filled: Background bgSurface, textHigh
- Wrong OTP: All boxes shake, border error color

ANIMATIONS:
- Boxes: Scale 0.8→1.0, staggered 50ms
- Box fill: Scale 1.0→1.1→1.0, border color transition
- Wrong OTP: Shake (translateX -8→8→0, 3 cycles)
- Success: All boxes fill brand500, fade out, navigate

HAPTICS:
- Digit enter: Light impact per box
- Wrong OTP: Error buzz (3x light impact)
- Success: Medium impact + success chime

--------------------------------------------------------------------------------
SCREEN 6: ForgotPasswordScreen
Route: /forgot-password
Priority: P0
Status: Done (T-009)
--------------------------------------------------------------------------------

LAYOUT: Minimal — email field + send button + back to login

ELEMENTS:
| # | Element | Type | Action |
|---|---------|------|--------|
| 1 | Back | IconButton | Pop to Login |
| 2 | "Reset Password" | Text | Header |
| 3 | "Enter your email..." | Text | Subheader |
| 4 | Email Field | TextField | Input |
| 5 | Send Button | ElevatedButton | API → success state |
| 6 | Success Illustration | Icon | Checkmark circle |
| 7 | "Check your email" | Text | Appears after send |
| 8 | Back to Login | TextButton | Navigate to Login |

STATES:
| State | Visual |
|-------|--------|
| Input | Email field active, button "Send Reset Link" |
| Loading | Button shows CircularProgress |
| Success | Checkmark icon, "Check your email" text, button becomes "Back to Login" |

--------------------------------------------------------------------------------
SCREEN 7: MainScreen (Home Dashboard)
Route: /
Priority: P0
Status: Done (T-018)
--------------------------------------------------------------------------------

LAYOUT:
┌─────────────────────────────┐
│  [Menu]  CapCard    [👤]   │  ← AppBar
├─────────────────────────────┤
│  "Good evening, Alex"       │  ← Greeting, 22sp, w600
│  "Ready to create?"         │  ← Subtitle, 14sp, textMedium
├─────────────────────────────┤
│  ┌─────┐ ┌─────┐           │
│  │  +  │ │ 📁  │           │  ← Quick Actions, 2x2 grid
│  │ New │ │Import│           │  ← 80x80dp cards, brand500 accent
│  └─────┘ └─────┘           │
│  ┌─────┐ ┌─────┐           │
│  │ 🤖  │ │ 🎬  │           │
│  │ AI  │ │Templ│           │
│  └─────┘ └─────┘           │
├─────────────────────────────┤
│  Continue Editing           │  ← Section header
│  [Project 1] [Project 2]    │  ← Horizontal scroll, 160x120dp cards
│  [Project 3] ...            │  ← Thumbnail + title + progress bar
├─────────────────────────────┤
│  Suggested for You          │  ← Section header
│  [Template 1] [Template 2]  │  ← Horizontal scroll, 120x160dp
│  ...                        │  ← Preview GIF + category tag
├─────────────────────────────┤
│  [🏠] [🎬] [🤖] [👤]       │  ← Bottom Nav, 56dp
└─────────────────────────────┘

ELEMENTS:
| # | Element | Type | Size | Color | Action |
|---|---------|------|------|-------|--------|
| 1 | Menu Button | IconButton | 48x48dp | textHigh | Opens drawer (future) |
| 2 | App Title | Text | 20sp, w600 | textHigh | Static |
| 3 | Profile Avatar | CircleAvatar | 40dp | - | Navigate to Settings |
| 4 | Greeting | Text | 22sp, w600 | textHigh | Dynamic by time of day |
| 5 | Subtitle | Text | 14sp, w400 | textMedium | Static |
| 6 | New Project Card | InkWell Card | 80x80dp | brand500 20% | Create new project → Editor |
| 7 | New Icon | Icon | 32dp | brand500 | Inside card |
| 8 | "New" Label | Text | 12sp, w500 | textHigh | Below icon |
| 9 | Import Card | InkWell Card | 80x80dp | bgSurface | Opens import bottom sheet |
| 10 | Import Icon | Icon | 32dp | textMedium | Inside card |
| 11 | "Import" Label | Text | 12sp, w500 | textHigh | Below icon |
| 12 | AI Studio Card | InkWell Card | 80x80dp | brand500 20% | Navigate to AiStudioScreen |
| 13 | AI Icon | Icon | 32dp | brand500 | Inside card, subtle pulse |
| 14 | "AI" Label | Text | 12sp, w500 | textHigh | Below icon |
| 15 | Templates Card | InkWell Card | 80x80dp | bgSurface | Navigate to TemplatesScreen |
| 16 | Templates Icon | Icon | 32dp | textMedium | Inside card |
| 17 | "Templates" Label | Text | 12sp, w500 | textHigh | Below icon |
| 18 | "Continue Editing" Header | Text | 17sp, w600 | textHigh | Section title |
| 19 | "See All" | TextButton | Wrap | brand500 | Navigate to ProjectsScreen |
| 20 | Recent Project Card 1-N | Card | 160x120dp | bgSurface | Navigate to Editor |
| 21 | Project Thumbnail | Image | 160x90dp | - | Top of card |
| 22 | Project Title | Text | 14sp, w500 | textHigh | Below thumbnail |
| 23 | Project Duration | Text | 12sp, w400 | textLow | Bottom of card |
| 24 | Progress Bar | LinearProgress | 160x2dp | brand500 | If project in progress |
| 25 | "Suggested for You" Header | Text | 17sp, w600 | textHigh | Section title |
| 26 | Template Card 1-N | Card | 120x160dp | bgSurface | Tap → TemplateDetail |
| 27 | Template Preview | Image/GIF | 120x160dp | - | Full card background |
| 28 | Template Category Tag | Chip | Wrap | brand500 20% | Top-left overlay |
| 29 | Template Name | Text | 12sp, w500 | textHigh | Bottom gradient overlay |
| 30 | Bottom Nav Home | NavItem | 56dp | brand500 (active) | MainScreen |
| 31 | Bottom Nav Projects | NavItem | 56dp | textLow (inactive) | ProjectsScreen |
| 32 | Bottom Nav AI | NavItem | 56dp | textLow (inactive) | AiStudioScreen |
| 33 | Bottom Nav Profile | NavItem | 56dp | textLow (inactive) | SettingsScreen |

BUTTONS:
| # | Button | Label/Icon | Action | Visual |
|------|--------|------------|--------|--------|
| 1 | Menu | Hamburger | Open navigation drawer | IconButton |
| 2 | Profile | Avatar image | Navigate to Settings | CircleAvatar |
| 3 | New Project | Plus icon | Create new project → Editor | Card with spring press |
| 4 | Import | Folder icon | Open import bottom sheet | Card with spring press |
| 5 | AI Studio | Robot icon | Navigate to AI Studio | Card with subtle glow |
| 6 | Templates | Film icon | Navigate to Templates | Card with spring press |
| 7 | See All | "See All" | Navigate to ProjectsScreen | TextButton |
| 8 | Project Card 1-N | Thumbnail + title | Navigate to Editor | Card with elevation on press |
| 9 | Template Card 1-N | Preview + tag | Navigate to TemplateDetail | Card with parallax |
| 10 | Bottom Nav Home | Home icon | MainScreen | Active: brand500, scale 1.1 |
| 11 | Bottom Nav Projects | Film icon | ProjectsScreen | Inactive: textLow |
| 12 | Bottom Nav AI | Sparkle icon | AiStudioScreen | Inactive: textLow |
| 13 | Bottom Nav Profile | Person icon | SettingsScreen | Inactive: textLow |

ANIMATIONS:
- Cards: Scale 0.95→1.0 on press, spring release
- AI Studio card: Subtle pulse glow (brand500 opacity 0.1→0.3, 3s loop)
- Recent projects: Staggered fade-in on screen load (50ms apart)
- Templates: Parallax scroll (image moves slower than card)
- Bottom nav: Active item scale 1.0→1.1, color transition 150ms
- Pull-to-refresh: Rotate arrow, bounce on release

HAPTICS:
- Card press: Light impact
- Nav switch: Light impact
- New project: Medium impact (excitement)

--------------------------------------------------------------------------------
SCREEN 8: ProjectsScreen
Route: /projects
Priority: P0
Status: Done (T-019, T-026)
--------------------------------------------------------------------------------

LAYOUT:
┌─────────────────────────────┐
│  [←]  My Projects    [🔍]  │
├─────────────────────────────┤
│  [All][Video][Draft][Done]  │  ← Filter chips
├─────────────────────────────┤
│  ┌─────┐ ┌─────┐ ┌─────┐  │
│  │     │ │     │ │     │  │  ← Masonry grid
│  │ P1  │ │ P2  │ │ P3  │  │  ← 2 columns, variable height
│  │     │ │     │ │     │  │
│  └─────┘ └─────┘ └─────┘  │
│  ...                        │
├─────────────────────────────┤
│        [    +    ]          │  ← FAB, brand500
└─────────────────────────────┘

ELEMENTS:
| # | Element | Type | Size | Color | Action |
|---|---------|------|------|-------|--------|
| 1 | Back | IconButton | 48x48dp | textHigh | Pop to MainScreen |
| 2 | "My Projects" | Text | 20sp, w600 | textHigh | Static |
| 3 | Search | IconButton | 48x48dp | textHigh | Expand search bar |
| 4 | Search Bar | TextField | Full-56dp | bgSurface | Filter projects inline |
| 5 | Filter Chip "All" | ChoiceChip | Wrap | brand500 (selected) | Filter all |
| 6 | Filter Chip "Video" | ChoiceChip | Wrap | textLow | Filter videos |
| 7 | Filter Chip "Draft" | ChoiceChip | Wrap | textLow | Filter drafts |
| 8 | Filter Chip "Done" | ChoiceChip | Wrap | textLow | Filter completed |
| 9 | Project Card 1-N | Card | 160x200dp | bgSurface | Long-press menu |
| 10 | Project Thumbnail | Image | 160x120dp | - | Top of card |
| 11 | Project Title | Text | 14sp, w500 | textHigh | Below thumbnail |
| 12 | Project Date | Text | 12sp, w400 | textLow | Below title |
| 13 | Project Duration | Text | 12sp, w400 | textLow | Bottom right |
| 14 | More Options | IconButton | 32x32dp | textLow | Opens context menu |
| 15 | FAB New Project | FloatingActionButton | 56dp | brand500 | Navigate to Editor (new) |

BUTTONS:
| # | Button | Action | Visual |
|------|--------|--------|--------|
| 1 | Back | Pop to Main | IconButton |
| 2 | Search | Expand search bar | IconButton → TextField |
| 3 | Filter chips | Filter grid | ChoiceChip |
| 4 | Project Card | Navigate to Editor | Card with elevation |
| 5 | More Options | Open context menu | IconButton |
| 6 | FAB | Create new project | brand500, spring scale |

CONTEXT MENU (Long-press on card):
| # | Option | Icon | Action |
|---|--------|------|--------|
| 1 | Rename | Edit icon | Inline rename field |
| 2 | Duplicate | Copy icon | Clone project |
| 3 | Share | Share icon | Share sheet |
| 4 | Export | Download icon | Quick export dialog |
| 5 | Delete | Trash icon | Delete confirmation dialog |

ANIMATIONS:
- Grid: Staggered fade-in (50ms apart per card)
- Filter change: Cross-fade grid
- Search expand: Width 0→full, opacity 0→1
- FAB: Scale 0→1 on scroll up, scale 1→0 on scroll down
- Card long-press: Scale 1.0→1.05, haptic feedback

--------------------------------------------------------------------------------
SCREEN 9: TemplatesScreen
Route: /templates
Priority: P1
Status: Done (T-081)
--------------------------------------------------------------------------------

LAYOUT: Similar to ProjectsScreen but with categories

ADDITIONAL ELEMENTS:
| # | Element | Type | Action |
|---|---------|------|--------|
| 1 | Category Tabs | TabBar | Instagram, YouTube, TikTok, Reels, etc. |
| 2 | Trending Badge | Chip | "🔥 Trending" on hot templates |
| 3 | Premium Badge | Chip | "👑 Pro" on paid templates |
| 4 | Use Template Button | ElevatedButton | Navigate to Editor with template |
| 5 | Preview Button | OutlinedButton | Play template preview |

--------------------------------------------------------------------------------
SCREEN 10: TemplateDetailScreen
Route: /templates/:id
Priority: P1
Status: Done (T-082)
--------------------------------------------------------------------------------

LAYOUT:
┌─────────────────────────────┐
│  [←]              [❤️][⬇]  │
├─────────────────────────────┤
│  ┌─────────────────────┐    │
│  │                     │    │  ← Full preview
│  │    TEMPLATE PREVIEW │    │  ← 16:9, auto-play loop
│  │                     │    │
│  └─────────────────────┘    │
├─────────────────────────────┤
│  "Wedding Highlights"       │  ← Title, 22sp
│  "Perfect for Indian..."    │  ← Description, 14sp
│  By @creator_name           │  ← Author, 12sp
├─────────────────────────────┤
│  [     Use Template     ]   │  ← Full width, brand500
│  [   Preview   ] [Share]   │  ← Secondary actions
└─────────────────────────────┘

ELEMENTS:
| # | Element | Type | Size | Color | Action |
|---|---------|------|------|-------|--------|
| 1 | Back | IconButton | 48x48dp | textHigh | Pop to Templates |
| 2 | Favorite | IconButton | 48x48dp | textLow → error (when fav) | Toggle favorite |
| 3 | Download | IconButton | 48x48dp | textLow | Download for offline |
| 4 | Preview Player | VideoPlayer | Full-16:9 | - | Auto-play loop |
| 5 | Template Title | Text | 22sp, w600 | textHigh | Static |
| 6 | Description | Text | 14sp, w400 | textMedium | Static |
| 7 | Author | Text | 12sp, w500 | brand500 | Tap → author profile |
| 8 | Use Template | ElevatedButton | Full-48dp | brand500 | Navigate to Editor with template preloaded |
| 9 | Preview | OutlinedButton | 120x48dp | bgSurface | Fullscreen preview |
| 10 | Share | OutlinedButton | 120x48dp | bgSurface | Share sheet |

BUTTONS:
| # | Button | Action | Visual |
|------|--------|--------|--------|
| 1 | Back | Pop | IconButton |
| 2 | Favorite | Toggle favorite | Heart icon, fills error on active |
| 3 | Download | Save offline | Download icon |
| 4 | Use Template | Editor with template | brand500, pulse on load |
| 5 | Preview | Fullscreen preview | Outlined |
| 6 | Share | Share template | Outlined |

ANIMATIONS:
- Preview: Auto-play with subtle zoom (Ken Burns effect)
- Favorite: Scale 1.0→1.3→1.0, heart fills with particle burst
- Download: Progress arc around icon
- Use Template: Glow pulse on appear

--------------------------------------------------------------------------------
SCREEN 11: AiStudioScreen
Route: /ai-studio
Priority: P1
Status: Done (T-102)
--------------------------------------------------------------------------------

LAYOUT:
┌─────────────────────────────┐
│  AI Studio          [💎]    │  ← Credit balance badge
├─────────────────────────────┤
│  "What will you create?"    │
│  [Search AI tools...    ]   │  ← Search bar
├─────────────────────────────┤
│  Quick Actions              │
│  ┌─────┐ ┌─────┐ ┌─────┐  │
│  │  CC │ │ 🎙  │ │ 🎬  │  │
│  │Caps │ │Voice│ │Gen  │  │
│  └─────┘ └─────┘ └─────┘  │
├─────────────────────────────┤
│  AI Tools                   │
│  ┌─────────────────────┐    │
│  │ 🤖 Auto Captions    │    │  ← List tiles
│  │ 🎙 Voice Clone      │    │
│  │ 🎬 Text to Video    │    │
│  │ ...                 │    │
│  └─────────────────────┘    │
├─────────────────────────────┤
│  Recent AI Jobs             │
│  [Job 1] [Job 2] ...        │  ← Status cards
└─────────────────────────────┘

ELEMENTS:
| # | Element | Type | Size | Color | Action |
|---|---------|------|------|-------|--------|
| 1 | "AI Studio" | Text | 20sp, w600 | textHigh | Static |
| 2 | Credit Badge | Chip | Wrap | brand500 | Tap → SubscriptionScreen |
| 3 | Search Bar | TextField | Full-56dp | bgSurface | Filter tools |
| 4 | Quick Action 1-N | Card | 80x80dp | bgSurface | Navigate to specific AI tool |
| 5 | Tool Icon | Icon | 32dp | brand500 | Inside card |
| 6 | Tool Label | Text | 12sp, w500 | textHigh | Below icon |
| 7 | AI Tool Tile 1-N | ListTile | Full-72dp | bgSurface | Tap → tool flow |
| 8 | Tool Icon | Icon | 40dp | brand500 | Leading |
| 9 | Tool Name | Text | 16sp, w500 | textHigh | Title |
| 10 | Tool Description | Text | 14sp, w400 | textMedium | Subtitle |
| 11 | Credit Cost | Chip | Wrap | brand500 20% | Trailing |
| 12 | "Recent AI Jobs" Header | Text | 17sp, w600 | textHigh | Section |
| 13 | Job Card 1-N | Card | 160x100dp | bgSurface | Tap for status/details |
| 14 | Job Status | Chip | Wrap | success/warning/error | Queued/Processing/Done/Failed |

BUTTONS:
| # | Button | Action | Visual |
|------|--------|--------|--------|
| 1 | Credit Badge | Navigate to subscription | Chip |
| 2 | Quick Actions | Navigate to specific tool | Card |
| 3 | Tool Tiles | Open tool flow | ListTile |
| 4 | Job Cards | View job details/status | Card |

AI TOOLS LIST (12 total):
| # | Tool | Icon | Description | Credit Cost |
|---|------|------|-------------|-------------|
| 1 | Auto Captions | CC | Generate subtitles from audio | 5 |
| 2 | Voice Clone | 🎙 | Clone voice from 30s sample | 20 |
| 3 | Text to Video | 🎬 | Generate video from prompt | 50 |
| 4 | AI Thumbnail | 🖼 | Generate thumbnail from video | 10 |
| 5 | AI Music | 🎵 | Generate background music | 15 |
| 6 | AI Dubbing | 🗣 | Translate and dub audio | 30 |
| 7 | Background Removal | ✂️ | Remove video background | 10 |
| 8 | Smart Crop | 🎯 | Auto-crop for platforms | 5 |
| 9 | Video Enhance | ✨ | Upscale and denoise | 20 |
| 10 | Style Transfer | 🎨 | Apply artistic style | 15 |
| 11 | Motion Tracking | 🎯 | Track object and apply effect | 10 |
| 12 | Script to Video | 📝 | Generate video from script | 50 |

ANIMATIONS:
- Tool tiles: Staggered slide-up (30ms apart)
- Credit badge: Pulse when low (<10 credits)
- Job status: Progress bar animates, color transitions
- Quick actions: Scale 0.9→1.0 on load

HAPTICS:
- Tool tap: Light impact
- Job complete notification: Success chime
