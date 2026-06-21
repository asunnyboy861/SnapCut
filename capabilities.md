# Capabilities Configuration

## Analysis
Based on operation guide analysis, the following capabilities were detected:

| Keyword Found | Capability | Source |
|---------------|------------|--------|
| "CloudKit", "社区", "分享" | iCloud (CloudKit) | Guide section 7.3, us.md Feature #5, #10 |
| "订阅", "购买", "$1.99/月", "IAP" | In-App Purchase | Guide section 8.2, us.md Feature #13, #14 |
| "API key", "Keychain" | Keychain Access | Guide section 7.2.1, us.md Feature #12 |
| "API", "cloud", "联网" | Network Client (Outgoing) | Guide section 7.2.1, us.md Feature #1 |
| ".shortcut", "导入", "安装" | File Sharing / Document Import | Guide section 7.2.2, us.md Feature #6 |

## Auto-Configured Capabilities

| Capability | Status | Method |
|------------|--------|--------|
| iCloud (CloudKit) | ✅ Configured | Created `SnapCut.entitlements` with CloudKit container `iCloud.com.zzoutuo.SnapCut` |
| In-App Purchase | ✅ Configured | Created `Products.storekit` configuration file with 5 IAP products (2 subscriptions + 3 non-consumables) |
| Keychain Access | ✅ Configured | Default Keychain access via standard data protection class (no entitlement needed) |
| Network Client (Outgoing) | ✅ Configured | ATS allows HTTPS by default; no entitlement needed |
| File Sharing / Document Import | ✅ Configured | Added `UIFileSharingEnabled` and `LSSupportsOpeningDocumentsInPlace` to Info.plist keys in project.pbxproj |

## Manual Configuration Required

| Capability | Status | Steps |
|------------|--------|-------|
| CloudKit Container (Production) | ⏳ Pending | 1. Login to Apple Developer Portal → Certificates, Identifiers & Profiles → Identifiers → iCloud Containers → Create new container `iCloud.com.zzoutuo.SnapCut`. 2. Enable iCloud capability in Xcode Signing & Capabilities → check CloudKit → select the container. 3. Create CloudKit schema (Record Types: `CommunityTemplate`, `Comment`, `Rating`) in CloudKit Dashboard after first run. **Note**: App works without this — community features gracefully degrade; local templates and AI creation work fully offline. |
| App Store Connect IAP Products | ⏳ Pending | 1. Login to App Store Connect → My Apps → SnapCut → In-App Purchases → Create 5 products matching IDs in `Products.storekit`. 2. Add pricing, descriptions, and screenshots. 3. Submit for review with app binary. **Note**: App works with StoreKit local configuration for testing; production IAP requires App Store Connect setup. |

## No Configuration Needed

- Push Notifications — not used (app does not send notifications)
- HealthKit — not used (app creates shortcuts, doesn't access health data directly)
- Location Services — not used by app directly (shortcuts handle their own location access)
- Apple Watch — Phase 3 feature, not in MVP
- Camera/Photo Library — not used
- Siri — not directly integrated (shortcuts can be invoked via Siri after install)
- Background Modes — not needed (all processing is foreground)
- Sign in with Apple — not used (anonymous local user by default)
- HomeKit — not used (shortcuts handle HomeKit, not the app)

## Entitlements File
- Path: `SnapCut/SnapCut/SnapCut.entitlements`
- Contents: iCloud container identifier, CloudKit service, ubiquity-kvstore-identifier
- Referenced in: `project.pbxproj` (both Debug and Release configurations)

## StoreKit Configuration
- Path: `SnapCut/Products.storekit`
- Products:
  - `com.zzoutuo.SnapCut.pro.monthly` — Auto-renewable, $1.99/month
  - `com.zzoutuo.SnapCut.pro.yearly` — Auto-renewable, $9.99/year (7-day free trial)
  - `com.zzoutuo.SnapCut.pack.holiday` — Non-consumable, $0.99
  - `com.zzoutuo.SnapCut.pack.fitness` — Non-consumable, $0.99
  - `com.zzoutuo.SnapCut.pack.travel` — Non-consumable, $0.99

## Info.plist Keys Added
- `CFBundleDisplayName` = SnapCut
- `UIFileSharingEnabled` = YES (for .shortcut file import via Files app)
- `LSSupportsOpeningDocumentsInPlace` = YES (for opening .shortcut files in place)

## Graceful Degradation
- **Without CloudKit container**: Community features disabled; local templates, AI creation, visual editor, and import all work fully
- **Without App Store Connect IAP**: StoreKit local config enables testing; production purchases require App Store Connect setup
- **Without API key**: Free tier (3/day) uses app's key; Pro tier requires user's key; on-device AI fallback if available

## Verification
- Build succeeded after configuration: ✅ (5.1s build time, iPhone 17 Pro simulator iOS 26.4)
- All entitlements correct: ✅
- StoreKit configuration valid: ✅
