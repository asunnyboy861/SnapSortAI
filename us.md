# SnapSort AI - iOS Development Guide

## Executive Summary

SnapSort AI is an intelligent screenshot manager for iPhone that automatically detects, classifies, and organizes screenshots using on-device AI. The app solves the universal problem of screenshots becoming a "black hole" where useful information disappears forever. Unlike competitors that rely on cloud processing or offer limited free tiers, SnapSort AI processes everything 100% on-device using Apple's Vision framework, ensuring privacy while delivering powerful OCR search, smart categorization, and automatic cleanup of temporary screenshots (OTP codes, QR codes, delivery tracking).

**Target Audience**: US iPhone users aged 18-45 who frequently take screenshots and struggle to find them later.

**Key Differentiators**:
- 100% on-device AI processing (no cloud, no privacy risk)
- Automatic detection of temporary screenshots (OTP, QR, delivery) with smart cleanup reminders
- OCR-powered full-text search across all screenshots
- 13-category smart classification system
- Privacy-first: Face ID protection for sensitive screenshots
- Lightweight: No screenshot duplication, reads directly from Photos library

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| **Screenshots Pro** | Device frames for devs, OCR search, dashboard stats | $2.99/mo subscription, 127MB app size, ad-supported free version, focused on developers not general users | Broader audience, smaller app size, temporary screenshot cleanup, no ads in free version |
| **Captr** | Clean UI, 5.0 rating, organize & protect | Cloud upload (privacy risk), requires network, limited offline | 100% local processing, offline-first, auto-classification |
| **TempSnap** | Temporary vs permanent classification, auto-detection, privacy-first | No OCR search, no auto-categorization beyond temp/permanent, ads, 4.2 rating | 13-category classification, OCR search, Face ID protection, no ads |
| **SnapStash AI** | AI-powered, modern UI | Free tier only 10 screenshots/month, expensive ($4.99-9.99/mo) | Generous free tier, lower price point ($1.99/mo), more categories |
| **Apple Photos** | Built-in, free, iCloud sync | No screenshot-specific features, no auto-classification, no OCR search, no cleanup reminders | Purpose-built for screenshots, AI classification, OCR, cleanup |

## Apple Design Guidelines Compliance

- **Navigation**: Tab-based navigation following iOS 26 patterns (Library + Collections paradigm)
- **Layout**: Full-screen content views with Liquid Glass navigation elements
- **Adaptability**: Responsive layouts for iPhone and iPad using size classes
- **Visual Hierarchy**: Clear separation between navigation and content using materials
- **Privacy**: On-device processing only, Face ID integration for sensitive content
- **Photos Permission**: Minimal PhotoKit access (read screenshots only), never duplicate photos
- **Haptic Feedback**: Use UIImpactFeedbackGenerator for classification and deletion actions
- **Dark Mode**: Full support with adaptive colors and SF Symbols
- **Accessibility**: VoiceOver labels, Dynamic Type support, sufficient contrast ratios

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), UIKit (PhotoKit integration)
- **Data**: SwiftData with @Model classes for local persistence
- **OCR**: Vision Framework (VNRecognizeTextRequest) - 109 languages on-device
- **Image Classification**: Vision Framework (VNClassifyImageRequest) + custom rule-based classifier
- **Barcode Detection**: Vision Framework (VNDetectBarcodesRequest)
- **Photos Access**: PhotoKit (PHAsset, PHPhotoLibrary)
- **Notifications**: UserNotifications framework for cleanup reminders
- **Security**: LocalAuthentication (Face ID/Touch ID), CryptoKit for sensitive data
- **In-App Purchase**: StoreKit 2 for subscription management

## Module Structure

```
SnapSort/
├── SnapSortApp.swift
├── Models/
│   ├── ScreenshotItem.swift
│   ├── ScreenshotCategory.swift
│   └── AppSettings.swift
├── Services/
│   ├── ScreenshotMonitor.swift
│   ├── ScreenshotClassifier.swift
│   ├── OCRService.swift
│   ├── PhotoKitService.swift
│   ├── NotificationService.swift
│   └── PurchaseManager.swift
├── Views/
│   ├── MainTabView.swift
│   ├── Library/
│   │   ├── LibraryView.swift
│   │   ├── ScreenshotGridView.swift
│   │   └── ScreenshotDetailView.swift
│   ├── Categories/
│   │   ├── CategoryListView.swift
│   │   └── CategoryDetailView.swift
│   ├── Search/
│   │   └── SearchView.swift
│   ├── Cleanup/
│   │   ├── CleanupView.swift
│   │   └── TemporaryAlertView.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   ├── ContactSupportView.swift
│   │   └── PaywallView.swift
│   └── Onboarding/
│       └── OnboardingView.swift
├── ViewModels/
│   ├── LibraryViewModel.swift
│   ├── CategoryViewModel.swift
│   ├── SearchViewModel.swift
│   ├── CleanupViewModel.swift
│   └── SettingsViewModel.swift
├── Utilities/
│   ├── Constants.swift
│   └── Extensions.swift
└── Assets.xcassets/
```

## Implementation Flow

1. Set up SwiftData models (ScreenshotItem, ScreenshotCategory, AppSettings)
2. Implement PhotoKit service for screenshot detection and access
3. Build ScreenshotMonitor with PHPhotoLibraryChangeObserver
4. Implement OCR service using Vision VNRecognizeTextRequest
5. Build ScreenshotClassifier with rule-based + Vision classification
6. Create MainTabView with Library, Categories, Search, Cleanup tabs
7. Build Library view with screenshot grid and detail view
8. Build Category list and detail views
9. Implement full-text OCR search
10. Build Cleanup view with temporary screenshot management
11. Add notification service for cleanup reminders
12. Implement Face ID protection for sensitive categories
13. Add StoreKit 2 subscription management
14. Build Paywall and onboarding views
15. Add Settings with policy links and contact support
16. iPad layout optimization with max-width constraints

## UI/UX Design Specifications

- **Color Scheme**: Primary blue (#007AFF), accent orange (#FF9500) for temporary items, green (#34C759) for cleanup actions, system backgrounds
- **Typography**: SF Pro, headline for category names, subheadline for dates, caption for metadata
- **Layout**: Tab-based navigation (4 tabs: Library, Categories, Search, Cleanup), grid layout for screenshots (3 columns iPhone, 5 columns iPad), max-width 720pt for iPad content
- **Animations**: Smooth category badge animations, swipe-to-delete with spring animation, classification progress indicator
- **SF Symbols**: lock.shield (OTP), qrcode (QR), shippingbox (delivery), receipt (receipts), message (social), note.text (notes), bag (shopping), map (travel), fork.knife (food), briefcase (work), face.smiling (meme), heart.text.square (health), square.grid.2x2 (other)

## Code Generation Rules

- Use SwiftUI for all views, MVVM pattern with @Observable ViewModels
- SwiftData @Model for all persistent data
- All SwiftData attributes must be optional or have default values
- All SwiftData relationships must have inverse relationships
- Never duplicate screenshot files - always reference PHAsset
- 100% on-device processing, no network calls for core features
- Use async/await for all Vision and PhotoKit operations
- Follow Apple Human Interface Guidelines for all UI components
- No comments in code unless explicitly requested
- iPad content must use .frame(maxWidth: 720).frame(maxWidth: .infinity)
- Never use .tabViewStyle(.sidebarAdaptable)

## Build & Deployment Checklist

- [ ] Xcode project configured with bundle ID com.zzoutuo.SnapSortAI
- [ ] Deployment target set to iOS 17.0
- [ ] Photo Library usage description in Info.plist
- [ ] Face ID usage description in Info.plist
- [ ] Notification capability enabled
- [ ] In-App Purchase capability enabled
- [ ] App icon generated and configured
- [ ] Build succeeds on iPhone simulator
- [ ] Build succeeds on iPad simulator
- [ ] No memory leaks in screenshot processing
- [ ] OCR accuracy tested with various screenshot types
- [ ] Subscription flow tested with StoreKit Configuration
- [ ] Policy pages deployed to GitHub Pages
- [ ] App Store metadata prepared in keytext.md
