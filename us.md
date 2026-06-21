# SnapCut - iOS Development Guide

## Executive Summary

**SnapCut** is an AI-powered shortcut builder for iOS/iPadOS/macOS that lets users create Apple Shortcuts by simply describing what they want in natural language. The app's tagline — *"Describe it. SnapCut it. Done."* — captures its 3-step zero-learning-cost philosophy.

### Product Vision
Replace Apple Shortcuts' complex visual scripting interface with an AI-first, template-rich, visually editable experience. Target the 75% of users who have heard of Shortcuts but are intimidated by its complexity (P1/P2 pain points from Reddit r/shortcuts, r/macapps).

### Key Differentiators
1. **3-step creation**: Describe → Preview → Install (vs. Apple's 20+ tap workflow)
2. **Template marketplace**: Start from verified templates, not from scratch
3. **Visual step editor**: AI generates, user can manually adjust any step
4. **Offline-first**: Local templates + on-device AI fallback (privacy + no-network use)
5. **Price disruptor**: $1.99/mo vs. ShortcutStudio's $8.99/mo (78% cheaper)
6. **Community-driven**: Share, rate, and comment on templates (network effects)
7. **Open-source engine**: Built on clean-shortcuts (Apache 2.0) — commercially safe

### Target Market
- **Primary**: United States
- **Platform**: iOS 17+ / iPadOS 17+ / macOS 14+ (Apple Silicon)
- **Audience**: Shortcuts beginners (45%), occasional users (30%), power users (15%), developers (10%)

### iOS 27 Threat Mitigation
Apple will natively support AI shortcut creation in iOS 27 (Fall 2026). SnapCut's moat: template marketplace + third-party app action support + visual editor + community — features Apple won't replicate. Must launch BEFORE iOS 27 to capture market.

---

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| **ShortcutStudio** | First-mover, template market, AI iteration | $8.99/mo expensive, online-only, no visual editor, no 3rd-party app actions, 10 msg/day free limit | 78% cheaper, offline-first, visual editor, full 3rd-party actions, community-driven |
| **AI Shortcuts Builder** | Free + IAP | 3.0/5 rating, unreliable generation, no templates, no editor | Higher quality AI, templates, visual editor, community |
| **Ai Shortcuts - Smart Actions** | Multi-LLM provider support, JSON output | One-time $24.90 purchase, no AI shortcut generation (only LLM actions inside shortcuts), no template market | AI generates complete shortcuts (not just LLM actions), subscription model, templates |
| **LLM Shortcut Toolkit** | Free AI access, multi-provider, Siri automation | Chinese-focused, no template marketplace, no visual editor | US market focus, template market, visual editor |
| **Apple Shortcuts (iOS 27)** | Free, native, Apple Intelligence powered | Limited to Apple ecosystem, no template market, no visual editor, requires A17+ | Template market, 3rd-party app actions, visual editor, works on more devices |
| **Cherri / Jellycuts** | Code-based shortcut generation | GPL license (Cherri), outdated actions (Jellycuts), requires coding knowledge | No-code AI approach, Apache 2.0 engine, beginner-friendly |

---

## ⚠️ Feature Inventory (MANDATORY — Every Feature Listed)

### Primary Features

| # | Feature | User Operation Flow | Data Input | Processing | Data Output | Persistence | Acceptance Criteria |
|---|---------|--------------------|------------|------------|-------------|-------------|---------------------|
| 1 | **AI Create Mode** | 1. Open app → 2. Tap "Create" tab → 3. Type description in input box → 4. Tap "SnapCut It!" button → 5. View preview → 6. Tap "Install" | Natural language text (e.g., "When I arrive home, turn on lights and play jazz") | AIEngine: NL → YAML via system prompt with action catalog → ShortcutCompiler: YAML → .shortcut file via clean-shortcuts | Preview view showing numbered action steps; .shortcut file in temp directory | UserShortcut SwiftData entity (name, yaml, icon, color, createdAt); file URL | User can type description, see preview within 3s, install to Shortcuts.app successfully |
| 2 | **Template Gallery** | 1. Tap "Templates" tab → 2. Browse categories or search → 3. Tap template card → 4. Fill parameters (if any) → 5. Tap "Install" | Template selection; optional parameter values (text, number, location, contact, app, time, toggle) | TemplateViewModel: load YAML from bundle/CloudKit → render parameter form → substitute placeholders → compile | Template preview with steps; parameter form; .shortcut file | ShortcutTemplate SwiftData entity; bundled YAML in Resources/Templates/ | User can browse ≥10 built-in templates, filter by 8 categories, install any template with custom parameters |
| 3 | **Visual Step Editor** | 1. From preview, tap "Edit Steps" → 2. Add/reorder/delete steps → 3. Modify action parameters → 4. Tap "Done" → 5. Preview updates | Step modifications (add action, delete action, reorder, edit params) | EditorViewModel: steps array → YAML regeneration → recompile | Updated step list view; refreshed .shortcut file | UserShortcut entity updated; draft state in viewState | User can add/delete/reorder steps, edit parameters, see live preview update |
| 4 | **My Shortcuts Library** | 1. Tap "My Cuts" tab → 2. View list of created/imported shortcuts → 3. Tap to view detail → 4. Options: run, share, edit, delete | User taps (no input) | MyShortcutsViewModel: fetch from SwiftData → sort by date → display | List of shortcut cards with icon, name, step count, date | UserShortcut SwiftData entity | User sees all created/imported shortcuts, can tap to view details, can delete |
| 5 | **Community Sharing** | 1. Tap "Community" tab → 2. Browse trending/top-rated/newest → 3. Tap template → 4. View author, rating, comments → 5. Tap "Install" | User taps; optional search query | CommunityViewModel: fetch from CloudKit public DB → paginate → display | Community template feed; template detail with comments | CloudKit public database; local cache in SwiftData | User can browse community templates, see ratings/comments, install community templates (free: 5/day, Pro: unlimited) |
| 6 | **Import Existing Shortcut** | 1. From "My Cuts" tap "+" → 2. Select "Import" → 3. Pick .shortcut file from Files → 4. App decompiles → 5. Preview → 6. Save to library | .shortcut file (UTI: com.apple.shortcut) | ShortcutCompiler.decompile: .shortcut → YAML via clean-shortcuts decompiler → parse to steps | Preview of imported shortcut steps; editable YAML | UserShortcut entity with source="imported" | User can import .shortcut file, see its steps, edit and save to library (Pro only) |
| 7 | **AI Iterative Modification** | 1. From preview/detail, tap "Modify with AI" → 2. Type modification request → 3. AI updates YAML → 4. Preview changes → 5. Install | Modification text (e.g., "Add a notification at the end") | AIEngine.refineShortcutYAML: current YAML + modification → updated YAML → recompile | Updated preview with highlighted changes | UserShortcut entity updated | User can request AI modifications, see changes applied, install updated shortcut (Pro only) |
| 8 | **Action Discovery** | 1. In Step Editor, tap "Add Action" → 2. Browse discovered actions by category → 3. Search actions → 4. Select action → 5. Configure params | Search query; category filter; action selection | ActionDiscoveryService: load bundled catalog.json (iOS) / run clean-shortcuts discover (macOS) → filter → display | Categorized action list; action detail with parameters | Bundled catalog.json in Resources/Actions/ | User can browse ≥100 actions, search by name, add any action to shortcut |
| 9 | **Custom Template Save** | 1. From shortcut detail, tap "Save as Template" → 2. Enter template name, icon, color, category → 3. Define parameters → 4. Save | Template metadata (name, icon, color, category); parameter definitions | TemplateViewModel: extract YAML → replace values with placeholders → save | Template appears in "My Templates" section | ShortcutTemplate entity with isBuiltIn=false, authorID=user | User can save any shortcut as reusable template with parameters (Pro only) |
| 10 | **Share to Community** | 1. From shortcut/template detail, tap "Share" → 2. Add description → 3. Tap "Publish" → 4. Template appears in community | Description text; optional tags | CommunityViewModel: upload YAML + metadata to CloudKit public DB | Share card preview; community entry | CloudKit public database | User can publish templates to community, others can install and rate (Pro only) |
| 11 | **Onboarding Flow** | 1. First launch → 2. See 3-mode selection screen → 3. Choose: "Try a Template" / "Create with AI" / "Start from Scratch" → 4. Enter selected mode | Mode selection tap | AppState: check isFirstLaunch UserDefaults → show onboarding → set flag | Onboarding view; transition to selected mode | UserDefaults isFirstLaunch=false | First-time users see 3-option onboarding, select one, enter mode directly, never see onboarding again |
| 12 | **Settings & API Key** | 1. Tap gear icon → 2. View settings: API key, subscription, about, privacy → 3. Enter API key → 4. Manage subscription | API key text; subscription selection | SettingsViewModel: save API key to Keychain → validate → update AIEngine | Settings form; subscription paywall; API key status | Keychain (API key); UserDefaults (preferences); StoreKit (subscription) | User can enter/manage API key, view/manage subscription, access privacy policy and terms |
| 13 | **Subscription Paywall** | 1. Tap "Go Pro" or any Pro feature → 2. See paywall with features, pricing → 3. Select monthly/yearly → 4. Confirm with Face ID → 5. Pro unlocked | Plan selection; purchase confirmation | StoreKitManager: present purchase → verify transaction → update entitlements | Paywall view; success animation; Pro badge | StoreKit local config; UserDefaults proStatus | User can purchase Pro monthly ($1.99) or yearly ($9.99), 7-day trial for yearly, entitlements unlock immediately |
| 14 | **Template Pack IAP** | 1. In Templates, tap "Theme Packs" → 2. Browse packs (holiday, fitness, travel) → 3. Tap pack → 4. Purchase → 5. Pack templates unlocked | Pack selection; purchase confirmation | StoreKitManager: purchase non-consumable → unlock pack templates | Pack detail; purchase flow; unlocked templates | StoreKit; UserDefaults unlockedPacks | User can purchase themed template packs ($0.99 each), templates appear in gallery after purchase |

### Sub-Features & Detail Interactions

| # | Parent Feature | Sub-Feature | Detail Description | Interaction Pattern |
|---|---------------|-------------|-------------------|--------------------|
| 1.1 | AI Create | Real-time step preview | As AI generates YAML, steps appear progressively with animation | Streaming text + spring animation per step |
| 1.2 | AI Create | Example prompts | Tappable example prompts below input ("When I arrive home...", "Every morning at 7am...") | Tap → fills input field |
| 1.3 | AI Create | Magic generation animation | Purple particles flow from input to preview during generation | CAEmitterLayer + Lottie |
| 2.1 | Templates | Category filter | 8 categories: Smart Home, Productivity, Health, Social, Travel, Finance, Media, Device | Horizontal scroll chips |
| 2.2 | Templates | Search | Search by name, description, or action type | Search bar + live filtering |
| 2.3 | Templates | Parameter form | Dynamic form based on template's TemplateParameter array | Form fields render by type |
| 3.1 | Step Editor | Drag to reorder | Long-press step → drag to new position | Drag and drop |
| 3.2 | Step Editor | Swipe to delete | Swipe left on step to reveal delete button | Swipe action |
| 3.3 | Step Editor | Action picker | Browse/search action catalog when adding new step | Sheet presentation |
| 4.1 | My Shortcuts | Sort options | Sort by date created, name, most used | Sort menu |
| 4.2 | My Shortcuts | Swipe actions | Swipe to delete, share, or edit | Swipe action |
| 5.1 | Community | Rating | 1-5 star rating for templates | Tap stars |
| 5.2 | Community | Comments | View and add comments on templates | Comment list + input |
| 5.3 | Community | Report | Report inappropriate templates | Report button → reason picker |
| 9.1 | Custom Template | Parameter definition | Define name, type, placeholder, default for each parameter | Form in save flow |
| 11.1 | Onboarding | Skip option | "Skip" button to go directly to AI Create | Text button |
| 12.1 | Settings | API key validation | Test API key by making a simple request | Button → loading → success/error |
| 12.2 | Settings | Restore purchases | Restore previous StoreKit purchases | Button → StoreKit restore |
| 13.1 | Paywall | Price comparison | Show "ShortcutStudio charges $8.99/mo. SnapCut Pro is just $1.99/mo." | Static text |
| 13.2 | Paywall | Feature checklist | List of Pro features with checkmarks | Static list |

### Cross-Feature Dependencies

| Dependency | Source Feature | Target Feature | Data Passed | Trigger Condition |
|------------|---------------|----------------|-------------|-------------------|
| Create → Library | AI Create (#1) | My Shortcuts (#4) | UserShortcut entity | After successful install |
| Template → Library | Template Gallery (#2) | My Shortcuts (#4) | UserShortcut entity | After template install |
| Editor → Preview | Step Editor (#3) | AI Create Preview | Updated YAML/steps | After editing "Done" tap |
| Import → Library | Import (#6) | My Shortcuts (#4) | UserShortcut entity | After successful import |
| AI Modify → Preview | AI Modify (#7) | AI Create Preview | Updated YAML | After AI modification |
| Custom Template → Templates | Custom Template Save (#9) | Template Gallery (#2) | ShortcutTemplate entity | After save |
| Share → Community | Share to Community (#10) | Community (#5) | CloudKit record | After publish |
| Template Pack → Templates | Template Pack IAP (#14) | Template Gallery (#2) | Unlocked pack templates | After purchase |
| Settings → AI Engine | Settings (#12) | AI Create (#1) | API key | After API key saved |

**⚠️ VERIFICATION CHECK**: 14 primary features + 19 sub-features + 9 cross-feature dependencies documented. Matches Chinese guide's described functionality (sections 5, 6, 7, 8, 9). ✅ YES

---

## ⚠️ App Store Compliance — AI Features

### Guideline 2.1(a) — App Completeness
This app uses a **BYO (Bring Your Own) API key** model for cloud AI features, with on-device fallback. Apple reviewers need a way to test AI functionality.

**Required Actions**:
1. Create `app_review_info.md` with demo API key configuration instructions
2. Add clear onboarding guidance for new users (API key setup in Settings)
3. NEVER show clickable AI buttons that lead to errors when no key is configured
4. `canGenerate` logic: `isPremium || hasAPIKey` — no free generation counting
5. Free tier (3/day) uses app's own API key budget; Pro tier requires user's key OR app's key

### Dead Code Prevention
- ❌ NEVER add: `freeGenerationsUsed`, `maxFreeGenerations`, `canGenerateFree`, `incrementGenerationCount()`
- These are dead code in BYO Key model and cause App Store rejections
- Free tier limits are enforced server-side or via simple UserDefaults counter (not in code paths that gate AI buttons)

### On-Device AI Fallback
- App MUST work without API key for basic template installation
- AI Create requires either: user's API key (Pro) OR free daily quota (3/day, app's key)
- If no key AND quota exhausted: show friendly message + "Get Pro" or "Add API Key" CTAs

---

## ⚠️ App Store Compliance — Subscriptions

### Guideline 3.1.2(c) — Subscription Information
Apple REQUIRES the following in the Paywall view:
- Functional link to Privacy Policy
- Functional link to Terms of Use (EULA)
- Subscription title, length, and price
- Auto-renewal disclosure text: "Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period."

### BYO Key + Subscription Model
- Subscription value: "Unlock Premium Features" — NOT "Unlimited AI Generations"
- Paywall feature list: Lead with app features (visual editor, import, community sharing, custom templates), not AI usage
- AI generation is ALWAYS unlimited for users with their own key
- Free tier (3/day) is a marketing feature, not a paywall gate

### IAP Products
| Product ID | Type | Price | Duration | Features |
|------------|------|-------|----------|----------|
| `com.zzoutuo.SnapCut.pro.monthly` | Auto-renewable | $1.99 | 1 month | All Pro features |
| `com.zzoutuo.SnapCut.pro.yearly` | Auto-renewable | $9.99 | 1 year (7-day trial) | All Pro features |
| `com.zzoutuo.SnapCut.pack.holiday` | Non-consumable | $0.99 | One-time | Holiday template pack |
| `com.zzoutuo.SnapCut.pack.fitness` | Non-consumable | $0.99 | One-time | Fitness template pack |
| `com.zzoutuo.SnapCut.pack.travel` | Non-consumable | $0.99 | One-time | Travel template pack |

---

## Apple Design Guidelines Compliance

- **Human Interface Guidelines**: Follow SwiftUI standard components, use SF Symbols, respect Dynamic Type, support Dark Mode (dark-first design per US market preference)
- **Modality**: Use sheets for preview, edit, and paywall; full-screen cover for onboarding
- **Navigation**: TabView with 4 tabs (Create, Templates, My Cuts, Community) — clear information hierarchy
- **Feedback**: Haptic feedback (UIImpactFeedbackGenerator) on install success, spring animations on step cards
- **Accessibility**: VoiceOver labels for all icons, reduce-motion support, sufficient color contrast (WCAG AA)
- **Privacy**: All user data local (SwiftData) or CloudKit private database; API key in Keychain; no third-party analytics

---

## Technical Architecture

- **Language**: Swift 6.0+ (strict concurrency, all public types `Sendable`)
- **Framework**: SwiftUI (primary), UIKit (UIDocumentInteractionController for .shortcut install)
- **Data**: SwiftData (NOT CoreData — per guide section 7.3) for local persistence; CloudKit for community sync
- **AI**: On-device (Apple Foundation Models, iOS 18+) with cloud API fallback (OpenAI-compatible, BYO key)
- **Shortcut Engine**: clean-shortcuts Swift Package (Apache 2.0) — YAML/JSON → signed .shortcut file
- **Networking**: URLSession (no third-party HTTP libraries)
- **Payments**: StoreKit 2 (modern, Swift-native)
- **Minimum iOS**: 17.0 (SwiftData requirement; guide says 16+ but SwiftData needs 17+)

---

## Module Structure

```
SnapCut/
├── SnapCutApp.swift                    # App entry, SwiftData container, onboarding gate
├── Models/
│   ├── UserShortcut.swift              # SwiftData @Model for user's shortcuts
│   ├── ShortcutTemplate.swift          # SwiftData @Model for templates
│   ├── ActionCatalog.swift             # Action discovery models
│   └── SubscriptionState.swift         # StoreKit entitlements
├── Views/
│   ├── RootView.swift                  # Onboarding vs MainTabView switch
│   ├── Onboarding/
│   │   └── OnboardingView.swift        # 3-mode selection
│   ├── MainTabView.swift               # 4-tab container
│   ├── Create/
│   │   ├── CreateView.swift            # AI input + generate
│   │   ├── PreviewView.swift           # Step preview + install
│   │   └── StepEditorView.swift        # Visual step editor
│   ├── Templates/
│   │   ├── TemplateGalleryView.swift   # Browse + search templates
│   │   ├── TemplateDetailView.swift    # Template detail + params
│   │   └── TemplatePackView.swift      # IAP template packs
│   ├── MyShortcuts/
│   │   ├── MyShortcutsView.swift       # Library list
│   │   └── ShortcutDetailView.swift    # Detail with run/share/edit
│   ├── Community/
│   │   ├── CommunityView.swift         # Community feed
│   │   └── CommunityTemplateView.swift # Template detail + comments
│   ├── Settings/
│   │   ├── SettingsView.swift          # Settings root
│   │   ├── PaywallView.swift           # Subscription paywall
│   │   └── APIKeyView.swift            # API key management
│   └── Components/
│       ├── StepCard.swift              # Reusable step card
│       ├── TemplateCard.swift          # Reusable template card
│       └── ModeButton.swift            # Onboarding mode button
├── ViewModels/
│   ├── CreateViewModel.swift           # AI create + preview state
│   ├── TemplateViewModel.swift         # Template gallery + install
│   ├── EditorViewModel.swift           # Step editor state
│   ├── MyShortcutsViewModel.swift      # Library management
│   ├── CommunityViewModel.swift        # Community feed + sync
│   └── SettingsViewModel.swift         # Settings + API key + subscription
├── Services/
│   ├── AIEngine.swift                  # NL → YAML (on-device + cloud)
│   ├── ShortcutCompiler.swift          # YAML/JSON → .shortcut (clean-shortcuts)
│   ├── ActionDiscovery.swift           # Discover available actions
│   ├── InstallService.swift            # Install .shortcut to Shortcuts.app
│   ├── StoreKitManager.swift           # IAP + subscription management
│   └── KeychainService.swift           # API key secure storage
├── AI/
│   ├── AIConfiguration.swift           # Provider config, model selection
│   ├── OpenAIService.swift             # OpenAI-compatible API client
│   ├── AIProfileManager.swift          # User AI profiles
│   └── Prompts.swift                   # System prompts for YAML generation
├── Resources/
│   ├── Templates/                      # Built-in YAML templates
│   │   ├── smart_home_arrive.yaml
│   │   ├── morning_routine.yaml
│   │   ├── workout_starter.yaml
│   │   └── ... (10+ templates)
│   ├── Actions/
│   │   └── catalog.json                # Bundled action catalog
│   └── Localizable.strings             # EN localization
└── Packages/
    └── clean-shortcuts/                # Swift Package (Apache 2.0)
```

---

## ⚠️ Data Flow Diagram (MANDATORY — Every Feature's Data Lifecycle)

### Feature 1: AI Create Mode
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Text description in CreateView TextEditor            │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── CreateViewModel.generate()                           │
│      ├── Validate input not empty                         │
│      ├── Check canGenerate (isPremium || hasAPIKey)       │
│      ├── Call AIEngine.generateShortcutYAML()             │
│      │   ├── Try on-device model first (if available)     │
│      │   └── Fallback to cloud API (OpenAI-compatible)    │
│      ├── Parse returned YAML to steps array               │
│      └── Update @Published previewSteps                   │
│       │                                                   │
│  Model/Persistence                                        │
│  └── After install: SwiftData UserShortcut entity saved   │
│       │                                                   │
│  Display Output                                           │
│  └── PreviewView shows numbered step cards                │
│      └── "Install" button → InstallService                │
│           └── UIDocumentInteractionController opens .shortcut │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── UserShortcut appears in MyShortcutsView              │
└───────────────────────────────────────────────────────────┘
```

### Feature 2: Template Gallery
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Category filter, search query, parameter values      │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── TemplateViewModel                                    │
│      ├── Load bundled YAML from Resources/Templates/      │
│      ├── Load CloudKit templates (Community section)      │
│      ├── Filter by category/search                        │
│      └── For install: substitute parameters in YAML       │
│       │                                                   │
│  Model/Persistence                                        │
│  └── ShortcutTemplate SwiftData entity (built-in + user)  │
│      └── After install: UserShortcut entity created       │
│       │                                                   │
│  Display Output                                           │
│  └── TemplateGalleryView: grid of TemplateCard            │
│  └── TemplateDetailView: parameter form + preview         │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Installed template appears in MyShortcutsView        │
└───────────────────────────────────────────────────────────┘
```

### Feature 3: Visual Step Editor
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Add/delete/reorder steps, edit parameters            │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── EditorViewModel                                      │
│      ├── Maintain steps array as @Published               │
│      ├── On add: present ActionDiscovery catalog          │
│      ├── On reorder: update array indices                 │
│      ├── On delete: remove from array                     │
│      └── On param edit: update step dictionary            │
│       │                                                   │
│  Model/Persistence                                        │
│  └── Steps → YAML string regeneration                     │
│      └── Update CreateViewModel.previewYAML               │
│       │                                                   │
│  Display Output                                           │
│  └── StepEditorView: List of editable StepCard            │
│      └── Live preview updates in PreviewView              │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Updated YAML → ShortcutCompiler → new .shortcut      │
└───────────────────────────────────────────────────────────┘
```

### Feature 4: My Shortcuts Library
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Tap shortcut card, swipe actions                     │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── MyShortcutsViewModel                                 │
│      ├── @FetchRequest UserShortcut sorted by createdAt   │
│      ├── Delete: remove from SwiftData                    │
│      └── Share: generate share sheet with .shortcut file  │
│       │                                                   │
│  Model/Persistence                                        │
│  └── UserShortcut SwiftData entity                        │
│       │                                                   │
│  Display Output                                           │
│  └── MyShortcutsView: List of shortcut cards              │
│  └── ShortcutDetailView: steps, run, share, edit, delete  │
└───────────────────────────────────────────────────────────┘
```

### Feature 5: Community Sharing
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Browse, search, install, rate, comment               │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── CommunityViewModel                                   │
│      ├── Fetch CKQuery from CloudKit public database      │
│      ├── Paginate results                                 │
│      ├── Rate: update CKRecord rating                    │
│      └── Comment: add CKRecord comment                   │
│       │                                                   │
│  Model/Persistence                                        │
│  └── CloudKit public database (community templates)       │
│  └── Local cache in SwiftData for offline viewing         │
│       │                                                   │
│  Display Output                                           │
│  └── CommunityView: Trending, Top Rated, Newest sections  │
│  └── CommunityTemplateView: detail + comments + install   │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Installed community template → MyShortcutsView       │
└───────────────────────────────────────────────────────────┘
```

### Feature 6: Import Existing Shortcut
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Select .shortcut file from Files app                 │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── CreateViewModel.importShortcut()                     │
│      ├── Read file data                                   │
│      ├── Call ShortcutCompiler.decompile()                │
│      │   └── clean-shortcuts decompiler → YAML            │
│      ├── Parse YAML to steps                              │
│      └── Show in PreviewView                              │
│       │                                                   │
│  Model/Persistence                                        │
│  └── After save: UserShortcut entity with source="imported" │
│       │                                                   │
│  Display Output                                           │
│  └── PreviewView with imported steps                      │
│      └── "Save to Library" button                         │
└───────────────────────────────────────────────────────────┘
```

### Feature 7: AI Iterative Modification
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Modification request text                            │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── CreateViewModel.modifyWithAI()                       │
│      ├── Get current YAML from previewState               │
│      ├── Call AIEngine.refineShortcutYAML()               │
│      │   └── Send current YAML + modification to AI       │
│      ├── Parse updated YAML                               │
│      └── Update previewSteps with diff highlight          │
│       │                                                   │
│  Model/Persistence                                        │
│  └── Update UserShortcut entity after install             │
│       │                                                   │
│  Display Output                                           │
│  └── PreviewView with highlighted changes                 │
│      └── "Install Updated Shortcut" button                │
└───────────────────────────────────────────────────────────┘
```

### Feature 8: Action Discovery
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Search query, category filter, action selection      │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── ActionDiscoveryService.discoverActions()             │
│      ├── iOS: load bundled catalog.json                   │
│      └── macOS: run `swift run shortcuts-cli discover`    │
│      └── Filter by query/category                         │
│       │                                                   │
│  Model/Persistence                                        │
│  └── Bundled catalog.json (read-only)                     │
│       │                                                   │
│  Display Output                                           │
│  └── ActionPickerView: categorized action list            │
│      └── Action detail with parameter form                │
└───────────────────────────────────────────────────────────┘
```

### Feature 9: Custom Template Save
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Template name, icon, color, category, parameters     │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── TemplateViewModel.saveAsTemplate()                   │
│      ├── Extract current YAML                             │
│      ├── Replace concrete values with placeholders        │
│      ├── Create ShortcutTemplate entity                   │
│      └── Save to SwiftData                                │
│       │                                                   │
│  Model/Persistence                                        │
│  └── ShortcutTemplate entity (isBuiltIn=false)            │
│       │                                                   │
│  Display Output                                           │
│  └── Template appears in "My Templates" section           │
└───────────────────────────────────────────────────────────┘
```

### Feature 10: Share to Community
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Description, tags                                    │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── CommunityViewModel.publishTemplate()                 │
│      ├── Create CKRecord with YAML + metadata             │
│      ├── Upload to CloudKit public database               │
│      └── Confirm publish success                          │
│       │                                                   │
│  Model/Persistence                                        │
│  └── CloudKit public database                             │
│       │                                                   │
│  Display Output                                           │
│  └── Success animation + "View in Community" button       │
└───────────────────────────────────────────────────────────┘
```

### Feature 11: Onboarding
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Mode selection tap (Template/AI/Scratch)             │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── AppState.checkFirstLaunch()                          │
│      ├── Read UserDefaults isFirstLaunch                  │
│      ├── If true: show OnboardingView                     │
│      └── On selection: set selectedMode + isFirstLaunch=false │
│       │                                                   │
│  Model/Persistence                                        │
│  └── UserDefaults isFirstLaunch (bool)                    │
│       │                                                   │
│  Display Output                                           │
│  └── OnboardingView: 3 mode cards                         │
│      └── Transition to selected mode in MainTabView       │
└───────────────────────────────────────────────────────────┘
```

### Feature 12: Settings & API Key
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── API key text, subscription selection                 │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── SettingsViewModel                                    │
│      ├── Save API key to Keychain                         │
│      ├── Validate by test API call                        │
│      ├── Manage StoreKit subscription                     │
│      └── Open privacy/terms URLs                          │
│       │                                                   │
│  Model/Persistence                                        │
│  └── Keychain (API key)                                   │
│  └── UserDefaults (preferences)                           │
│  └── StoreKit (subscription entitlements)                 │
│       │                                                   │
│  Display Output                                           │
│  └── SettingsView: form sections                          │
│  └── PaywallView: subscription options                    │
│  └── APIKeyView: key entry + validation                   │
└───────────────────────────────────────────────────────────┘
```

### Feature 13: Subscription Paywall
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Plan selection (monthly/yearly), purchase confirm    │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── StoreKitManager.purchase()                           │
│      ├── Present StoreKit sheet                           │
│      ├── Verify transaction                               │
│      ├── Update entitlements (UserDefaults proStatus)     │
│      └── Sync across devices (StoreKit sync)              │
│       │                                                   │
│  Model/Persistence                                        │
│  └── StoreKit local configuration                         │
│  └── UserDefaults proStatus + expirationDate              │
│       │                                                   │
│  Display Output                                           │
│  └── PaywallView: features, pricing, legal links          │
│  └── Success animation + Pro badge throughout app         │
└───────────────────────────────────────────────────────────┘
```

### Feature 14: Template Pack IAP
```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Pack selection, purchase confirm                     │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── StoreKitManager.purchasePack()                       │
│      ├── Purchase non-consumable IAP                      │
│      ├── Unlock pack templates in TemplateViewModel       │
│      └── Persist unlocked state                           │
│       │                                                   │
│  Model/Persistence                                        │
│  └── StoreKit; UserDefaults unlockedPacks array           │
│       │                                                   │
│  Display Output                                           │
│  └── TemplatePackView: pack detail + purchase             │
│  └── Pack templates appear in gallery with "PRO" badge    │
└───────────────────────────────────────────────────────────┘
```

**⚠️ VERIFICATION CHECK**: 14 data flow diagrams documented, one per primary feature. All data lifecycles traced from user input → ViewModel → Model/Persistence → Display → Cross-Feature Output. ✅ YES

---

## Implementation Flow

1. **Project Setup**: Configure Xcode project with SwiftData, capabilities (CloudKit, StoreKit), min iOS 17.0
2. **App Icon & Assets**: Generate app icon (purple magic theme), accent color, SF Symbols
3. **Data Models**: Implement UserShortcut, ShortcutTemplate SwiftData @Model classes
4. **AI Engine**: Implement AIEngine with on-device + cloud API; system prompt for YAML generation
5. **Shortcut Compiler**: Integrate clean-shortcuts Swift Package; implement YAML → .shortcut pipeline
6. **Action Catalog**: Bundle catalog.json with 100+ common Shortcuts actions
7. **Built-in Templates**: Create 10+ YAML templates across 8 categories
8. **Create Flow**: Build CreateView, PreviewView, StepEditorView with animations
9. **Template Gallery**: Build TemplateGalleryView, TemplateDetailView with parameter forms
10. **My Shortcuts**: Build MyShortcutsView, ShortcutDetailView with SwiftData @FetchRequest
11. **Community**: Build CommunityView with CloudKit integration (Phase 2 feature, stub for MVP)
12. **Settings & Paywall**: Build SettingsView, PaywallView, APIKeyView with StoreKit 2
13. **Onboarding**: Build OnboardingView with 3-mode selection
14. **Install Service**: Implement UIDocumentInteractionController for .shortcut import
15. **Testing**: Unit tests for AIEngine, ShortcutCompiler; UI tests for main flows
16. **Build & Push**: Build for iPhone simulator, push to GitHub

---

## UI/UX Design Specifications

### Color Scheme
- **Primary**: Purple (#8B5CF6) — creativity + magic
- **Secondary**: Blue (#3B82F6) — trust + tech
- **Success**: Green (#10B981) — install success
- **Warning**: Amber (#F59E0B) — attention needed
- **Error**: Red (#EF4444) — generation failure
- **Background Dark**: #0F172A
- **Background Light**: #F8FAFC

### Typography
- **Large Title**: SF Pro Display Bold 34pt
- **Title**: SF Pro Display Bold 22pt
- **Body**: SF Pro Text Regular 17pt
- **Caption**: SF Pro Text Regular 13pt
- **Button**: SF Pro Text Semibold 17pt

### Layout
- **Tab Bar**: 4 tabs (Create, Templates, My Cuts, Community) with SF Symbols
- **Cards**: Rounded corners 16pt, subtle shadow
- **Spacing**: 24pt between sections, 16pt between cards, 12pt internal padding
- **Safe Areas**: Respect all safe areas; extend background to edges

### Animations
- **AI Generation**: Purple particle effect (CAEmitterLayer) flowing from input to preview
- **Step Cards**: Spring animation with 0.1s staggered delay
- **Install Success**: Full-screen purple confetti + checkmark (Lottie)
- **Tab Switch**: Smooth slide + icon scale (matchedGeometryEffect)
- **Button Press**: Scale 0.95 + haptic feedback

### Dark Mode (Default)
- App defaults to Dark Mode per US market preference
- Supports Light Mode via system setting
- All colors have adaptive variants

---

## Code Generation Rules

- One feature per module, high cohesion, low coupling
- Semantic naming, clear file structure (per Module Structure above)
- Never add comments in code unless asked
- Apple native first: prioritize SwiftUI/Swift/SwiftData/StoreKit 2
- Open source first: integrate clean-shortcuts (Apache 2.0) for shortcut compilation
- Swift 6.0+ strict concurrency: all public types marked `Sendable`
- Privacy first: no third-party analytics, all data local or CloudKit private DB
- Version dynamic: read from Bundle.main.infoDictionary, never hardcode
- BYO Key compliance: no free generation counting dead code
- Subscription compliance: Paywall has Privacy + Terms links, auto-renewal disclosure

---

## Build & Deployment Checklist

- [ ] Xcode project configured with SwiftData capability
- [ ] CloudKit capability enabled (for community sync)
- [ ] StoreKit configuration file with 5 IAP products
- [ ] App icon generated (purple magic theme)
- [ ] clean-shortcuts Swift Package integrated
- [ ] Bundled catalog.json with 100+ actions
- [ ] 10+ built-in YAML templates in Resources/Templates/
- [ ] AIEngine with on-device + cloud fallback
- [ ] All 14 primary features implemented
- [ ] Dark mode default with light mode support
- [ ] Onboarding flow for first launch
- [ ] Paywall with legal links (Privacy, Terms)
- [ ] API key management in Settings
- [ ] Build succeeds for iPhone simulator
- [ ] Build succeeds for iPad simulator
- [ ] Code pushed to GitHub
- [ ] Policy pages deployed to GitHub Pages
- [ ] ASO keytext.md generated
- [ ] app_review_info.md created (for App Store review)

---

## Global Variables (PHASE 1 Output)

```
APP_NAME: SnapCut
BUNDLE_ID: com.zzoutuo.SnapCut
MIN_IOS: 17.0
GITHUB_USER: asunnyboy861
CONTACT_EMAIL: iocompile67692@gmail.com
MONETIZATION_HINT: subscription
AI_FEATURE_NEEDED: yes
AI_MODEL_TYPE: byo_key
GUIDE_REFERENCES:
  - https://github.com/damionrashford/clean-shortcuts (Apache 2.0, primary engine)
  - https://github.com/electrikmilk/cherri (GPL-2.0, reference only)
  - https://github.com/taylorarndt/perspective-cuts (reference)
  - https://github.com/extratone/jellycuts (reference)
FEATURE_COUNT: 14
SUB_FEATURE_COUNT: 19
CROSS_FEATURE_DEPENDENCIES: 9
DATA_FLOW_COUNT: 14
⚠️ VERIFICATION: FEATURE_COUNT in us.md matches the actual feature count in the Chinese guide: ✅ YES
```
