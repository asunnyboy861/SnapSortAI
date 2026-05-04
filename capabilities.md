# Capabilities Configuration

## Analysis
Based on operation guide analysis:
- Photo Library access required (screenshot detection and management)
- Face ID / Touch ID required (protect sensitive screenshots)
- Notifications required (cleanup reminders for temporary screenshots)
- In-App Purchase required (subscription model with free + premium tiers)
- No iCloud sync in initial version (100% local processing)
- No HealthKit, Camera, Location, or Watch needed

## Auto-Configured Capabilities
| Capability | Status | Method |
|------------|--------|--------|
| Photo Library | ✅ Configured | Info.plist NSPhotoLibraryUsageDescription |
| Face ID | ✅ Configured | Info.plist NSFaceIDUsageDescription |
| Notifications | ✅ Configured | UserNotifications framework (no entitlement needed) |
| In-App Purchase | ✅ Configured | StoreKit 2 (no entitlement needed for basic IAP) |

## Manual Configuration Required
| Capability | Status | Steps |
|------------|--------|-------|
| In-App Purchase (App Store Connect) | ⏳ Pending | 1. Create app record in App Store Connect 2. Create subscription group 3. Create monthly/yearly subscription products |

## No Configuration Needed
- iCloud / CloudKit (not used - 100% local processing)
- HealthKit (not health-related)
- Camera (reads existing screenshots, doesn't take photos)
- Location Services (not needed)
- Apple Watch (no companion app)
- Siri (no Siri integration)
- Background Modes (uses notifications only)
- Sign in with Apple (no account system)

## Verification
- Build succeeded after configuration: ⏳ Pending
- All entitlements correct: ✅
