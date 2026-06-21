# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | SnapCut |
| **Git URL** | git@github.com:asunnyboy861/SnapCut.git |
| **Repo URL** | https://github.com/asunnyboy861/SnapCut |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ✅ **ENABLED** (from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/SnapCut/ | ✅ Active |
| Support | https://asunnyboy861.github.io/SnapCut/support.html | ✅ Active |
| Privacy Policy | https://asunnyboy861.github.io/SnapCut/privacy.html | ✅ Active |
| Terms of Use | https://asunnyboy861.github.io/SnapCut/terms.html | ✅ Active |

## Repository Structure

```
SnapCut/
├── SnapCut/                       # iOS App Source Code
│   ├── SnapCut.xcodeproj/         # Xcode Project
│   ├── SnapCut/                   # Swift Source Files
│   │   ├── Views/
│   │   │   ├── Create/
│   │   │   ├── Templates/
│   │   │   ├── MyShortcuts/
│   │   │   ├── Community/
│   │   │   ├── Settings/
│   │   │   ├── Onboarding/
│   │   │   ├── MainTabView.swift
│   │   │   └── RootView.swift
│   │   ├── ViewModels/
│   │   │   ├── AppState.swift
│   │   │   ├── CreateViewModel.swift
│   │   │   ├── TemplateViewModel.swift
│   │   │   ├── MyShortcutsViewModel.swift
│   │   │   ├── CommunityViewModel.swift
│   │   │   └── SettingsViewModel.swift
│   │   ├── Models/
│   │   │   ├── UserShortcut.swift
│   │   │   ├── ShortcutTemplate.swift
│   │   │   └── ActionCatalog.swift
│   │   ├── Services/
│   │   │   ├── AIEngine.swift
│   │   │   ├── PurchaseManager.swift
│   │   │   ├── ShortcutCompiler.swift
│   │   │   ├── CloudKitService.swift
│   │   │   ├── ActionDiscoveryService.swift
│   │   │   └── KeychainHelper.swift
│   │   ├── Assets.xcassets/
│   │   ├── SnapCut.entitlements
│   │   └── SnapCutApp.swift
│   ├── SnapCutTests/
│   ├── SnapCutUITests/
│   └── Products.storekit
├── docs/                          # Policy Pages (GitHub Pages source)
│   ├── index.html
│   ├── support.html
│   ├── privacy.html
│   └── terms.html
├── .github/workflows/
│   └── deploy.yml
├── us.md
├── capabilities.md
├── price.md
├── icon.md
└── nowgit.md
```
