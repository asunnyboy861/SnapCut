# Pricing Configuration

## Monetization Model: Subscription (IAP) + Non-Consumable IAP

SnapCut uses a hybrid monetization model:
1. **Free tier** with daily limits (3 AI creates/day, 5 community installs/day)
2. **Pro subscription** (monthly/yearly) unlocking all features
3. **Template pack IAPs** (one-time purchases) for themed template bundles

## BYO Key Model: Hybrid (App Key + User Key)

### Free Tier (No API Key Required)
- AI Create: 3/day (uses app's API key budget)
- Template Gallery: Full access + install
- Visual Step Editor: ✅
- Community Browse: 5 installs/day
- AI Iterative Modification: ❌
- Import Existing Shortcuts: ❌
- Share to Community: ❌
- Custom Template Save: ❌

### Pro Tier (Subscription)
- AI Create: Unlimited (app's key OR user's key)
- Template Gallery: Full access + install
- Visual Step Editor: ✅
- Community Browse: Unlimited installs
- AI Iterative Modification: ✅ Unlimited
- Import Existing Shortcuts: ✅
- Share to Community: ✅
- Custom Template Save: ✅
- Template Pack Access: ✅ (if purchased)

### BYO API Key (Optional, Any Tier)
- Users who configure their own API key get unlimited AI creation regardless of subscription status
- This is a courtesy feature, not the primary subscription value
- Subscription value = APP FEATURES (import, share, custom templates, visual editor, unlimited community), NOT AI usage

### Subscription Value Proposition
"Unlock Premium Features" — visual editor, import, community sharing, custom templates, unlimited community installs, AI iterative modification. NOT "Unlimited AI Generations" (since BYO key users already have unlimited AI).

---

## Subscription Group
- **Group Name**: SnapCut Pro
- **Group ID**: SnapCutPro
- **Reference Name**: SnapCutPro

## Subscription Tiers

### 1. Monthly Subscription
- **Reference Name**: ProMonthly
- **Product ID**: `com.zzoutuo.SnapCut.pro.monthly`
- **Price**: $1.99 per month
- **Display Name**: SnapCut Pro Monthly
- **Description**: Unlock all Pro features. Cancel anytime.
- **Localization**: English (US)
- **Family Sharing**: Not enabled

### 2. Yearly Subscription
- **Reference Name**: ProYearly
- **Product ID**: `com.zzoutuo.SnapCut.pro.yearly`
- **Price**: $9.99 per year (58% savings vs monthly)
- **Display Name**: SnapCut Pro Yearly
- **Description**: Unlock all Pro features. 7-day free trial included.
- **Localization**: English (US)
- **Family Sharing**: Not enabled
- **Free Trial**: 7 days (auto-converts to paid)

## Non-Consumable IAPs (Template Packs)

### 3. Holiday Template Pack
- **Reference Name**: HolidayPack
- **Product ID**: `com.zzoutuo.SnapCut.pack.holiday`
- **Price**: $0.99 (one-time)
- **Display Name**: Holiday Template Pack
- **Description**: Holiday-themed shortcuts: Christmas lights, New Year countdown, Thanksgiving gratitude, Halloween sounds.
- **Family Sharing**: Enabled

### 4. Fitness Template Pack
- **Reference Name**: FitnessPack
- **Product ID**: `com.zzoutuo.SnapCut.pack.fitness`
- **Price**: $0.99 (one-time)
- **Display Name**: Fitness Template Pack
- **Description**: Fitness shortcuts: Workout starter, run tracker, water reminder, meditation timer.
- **Family Sharing**: Enabled

### 5. Travel Template Pack
- **Reference Name**: TravelPack
- **Product ID**: `com.zzoutuo.SnapCut.pack.travel`
- **Price**: $0.99 (one-time)
- **Display Name**: Travel Template Pack
- **Description**: Travel shortcuts: Packing list, currency converter, language translator, trip itinerary.
- **Family Sharing**: Enabled

---

## Free Trial
- **Duration**: 7 days
- **Type**: Free trial (auto-converts to paid yearly subscription)
- **Available for**: Yearly subscription only
- **Cancellation**: Users can cancel anytime during trial at no charge

## Policy Pages Required
- Support Page: ✅ (Must include subscription management info, cancellation instructions)
- Privacy Policy: ✅
- Terms of Use: ✅ (REQUIRED for subscription apps — must include auto-renewal terms, cancellation, pricing)

## Apple IAP Compliance Checklist
- [x] Auto-renewal terms included in Terms of Use
- [x] Cancellation instructions included in Support Page
- [x] Pricing clearly stated in Paywall ($1.99/mo, $9.99/yr, $0.99/pack)
- [x] Free trial terms included (7-day, yearly only)
- [x] Restore purchases functionality implemented
- [x] Paywall includes Privacy Policy link
- [x] Paywall includes Terms of Use link
- [x] No dark patterns (clear pricing, easy cancel)

## Paywall Feature List (App Store Compliant)

### What Pro Unlocks (Lead with APP features, not AI):
1. ✅ **Visual Step Editor** — Manually edit any shortcut step
2. ✅ **Import Existing Shortcuts** — Decompile and edit .shortcut files
3. ✅ **AI Iterative Modification** — Refine shortcuts with natural language
4. ✅ **Share to Community** — Publish your templates to the community
5. ✅ **Custom Template Save** — Save shortcuts as reusable templates
6. ✅ **Unlimited Community Installs** — No daily limit on community templates
7. ✅ **Unlimited AI Creation** — No daily limit (with app's key or your own)
8. ✅ **Priority Support** — Faster response from developer

### What Free Includes:
- AI Create: 3/day
- Template Gallery: Full browse + install
- Visual Step Editor: ✅ (basic)
- Community Browse: 5 installs/day

## Pricing Psychology (from guide section 8.3)
- **Anchor**: "ShortcutStudio charges $8.99/mo. SnapCut Pro is just $1.99/mo."
- **Annual discount**: $9.99/yr = $0.83/mo (58% savings vs monthly)
- **Free value**: 3/day = 90/month, enough for light users to build habit
- **Template packs**: $0.99 impulse purchase, themed content
- **7-day trial**: Experience full Pro before paying

## Revenue Projection (from guide section 8.3)
- Monthly downloads (6 months): 10,000
- Free → Pro conversion: 8%
- Monthly/Yearly split: 30%/70%
- Monthly Pro users: 240 × $1.99 = $477.60/mo
- Yearly Pro users: 560 × $9.99/12 = $466.20/mo
- Template pack IAP: 500 × $0.99 = $495.00/mo
- **Estimated monthly revenue**: ~$1,439
- **Estimated annual revenue**: ~$17,268

## IAP Product IDs Summary
| Product ID | Type | Price | Duration |
|------------|------|-------|----------|
| `com.zzoutuo.SnapCut.pro.monthly` | Auto-renewable | $1.99 | 1 month |
| `com.zzoutuo.SnapCut.pro.yearly` | Auto-renewable | $9.99 | 1 year (7-day trial) |
| `com.zzoutuo.SnapCut.pack.holiday` | Non-consumable | $0.99 | One-time |
| `com.zzoutuo.SnapCut.pack.fitness` | Non-consumable | $0.99 | One-time |
| `com.zzoutuo.SnapCut.pack.travel` | Non-consumable | $0.99 | One-time |
