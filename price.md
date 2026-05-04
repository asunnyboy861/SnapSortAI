# Pricing Configuration

## Monetization Model: Subscription (IAP)

## Subscription Group
- **Group Name**: SnapSort AI Premium
- **Group ID**: SnapSortAIPremium

## Subscription Tiers

### 1. Monthly Subscription
- **Reference Name**: Monthly Premium
- **Product ID**: `com.zzoutuo.SnapSortAI.monthly`
- **Price**: $1.99 per month
- **Display Name**: SnapSort AI Monthly
- **Description**: Full AI screenshot management
- **Localization**: English (US)

### 2. Yearly Subscription
- **Reference Name**: Yearly Premium
- **Product ID**: `com.zzoutuo.SnapSortAI.yearly`
- **Price**: $9.99 per year (58% savings vs monthly)
- **Display Name**: SnapSort AI Yearly
- **Description**: Best value for full access
- **Localization**: English (US)

### 3. Lifetime Purchase
- **Reference Name**: Lifetime Access
- **Product ID**: `com.zzoutuo.SnapSortAI.lifetime`
- **Price**: $29.99 one-time
- **Display Name**: SnapSort AI Lifetime
- **Description**: Pay once, use forever
- **Note**: No ongoing server costs, 100% on-device processing

## Free Tier Limits
- Screenshot detection: Unlimited
- Basic categories (3): OTP, QR Code, Delivery
- OCR search: 5 searches per day
- Cleanup reminders: Enabled
- No Face ID protection
- No advanced categories (10 additional)

## Premium Features
- All 13 categories unlocked
- Unlimited OCR search
- Face ID protection for sensitive screenshots
- Duplicate detection
- Batch operations (delete, move, share)
- Storage analytics
- Custom categories
- Export & backup

## Free Trial
- **Duration**: 7 days
- **Type**: Free trial (auto-converts to monthly)

## Policy Pages Required
- Support Page: ✅ (Must include subscription management info)
- Privacy Policy: ✅
- Terms of Use: ✅ (REQUIRED for subscription apps)

## Apple IAP Compliance Checklist
- [ ] Auto-renewal terms included in Terms
- [ ] Cancellation instructions included
- [ ] Pricing clearly stated
- [ ] Free trial terms included
- [ ] Restore purchases functionality implemented

## App Store Connect Pricing
- **Price Tier**: Free with In-App Purchases
