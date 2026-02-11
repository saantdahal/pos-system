# Bhansa Ghar - Subscription System Documentation

## Table of Contents

1. [Overview](#overview)
2. [System Architecture](#system-architecture)
3. [Subscription Tiers](#subscription-tiers)
4. [Payment Gateway Integration](#payment-gateway-integration)
5. [Database Models](#database-models)
6. [API Endpoints](#api-endpoints)
7. [Subscription Lifecycle](#subscription-lifecycle)
8. [Admin Dashboard](#admin-dashboard)
9. [Background Tasks](#background-tasks)
10. [Security Considerations](#security-considerations)
11. [Error Handling](#error-handling)
12. [Testing Strategy](#testing-strategy)

---

## Overview

The Bhansa Ghar Subscription System is a comprehensive management platform for handling restaurant subscriptions with multiple payment gateways, tiered pricing, and admin controls. The system supports automated billing, renewal management, and detailed transaction tracking.

### Key Features

- **Multi-tier Subscription Plans**: Trial, Basic, and Professional tiers with distinct features
- **Multiple Payment Gateways**: Support for Khalti, eSewa, IME Pay, Fonepay, and Bank Transfer
- **Automatic Renewal**: Scheduled subscription renewal with customizable intervals
- **Transaction Logging**: Complete audit trail for all subscription transactions
- **Admin Controls**: Comprehensive admin panel for managing subscriptions and customers
- **Webhook Integration**: Real-time payment confirmation from payment providers
- **Trial Management**: Free trial period with automatic conversion to paid subscription

### Target Market

- Nepal (NPR currency)
- Restaurant chains and individual establishments
- Quick-service restaurants (QSRs)

---

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Frontend Layer                           │
│              (Customer Portal / Admin Dashboard)            │
└─────────────────┬───────────────────────────────────────────┘
                  │
┌─────────────────v───────────────────────────────────────────┐
│                    API Layer (DRF)                          │
│          (REST Endpoints for Subscriptions)                 │
└─────────────────┬───────────────────────────────────────────┘
                  │
┌─────────────────v───────────────────────────────────────────┐
│                  Service Layer                              │
│     (Business Logic, Payment Processing, Validations)       │
└─────────────────┬───────────────────────────────────────────┘
                  │
        ┌─────────┼──────────┬─────────────┐
        │         │          │             │
┌───────v──┐  ┌──v────┐  ┌──v────┐  ┌────v────┐
│Database  │  │Cache  │  │Celery │  │Payment  │
│(Models)  │  │(Redis)│  │Tasks  │  │Gateways │
└──────────┘  └───────┘  └───────┘  └─────────┘
```

### Technology Stack

| Component     | Technology            | Version |
| ------------- | --------------------- | ------- |
| Framework     | Django                | 5.2.9+  |
| API Layer     | Django REST Framework | 3.14+   |
| Database      | PostgreSQL            | 12+     |
| Cache         | Redis                 | 6+      |
| Task Queue    | Celery                | 5.3+    |
| Async Support | Django Channels       | 4.0+    |
| Language      | Python                | 3.11+   |

---

## Subscription Tiers

### Pricing Structure

All prices are in Nepali Rupees (NPR).

| Feature             | Trial   | Basic        | Professional     |
| ------------------- | ------- | ------------ | ---------------- | --- |
| **Monthly Price**   | Free    | रु 500       | रु 1,200         |
| **Annual Price**    | -       | रु 5,000     | रु 11,520        |
| **Annual Discount** | -       | -            | 20%              |
| **Duration**        | 14 days | 30 days      | 30 days          |
| **Users**           | 1       | 10           | Unlimited        |     |
| **Analytics**       | Basic   | Advanced     | Premium          |
| **Support**         | Email   | Email + Chat | Priority Support |
| **Custom Reports**  | ✗       | ✗            | ✓                |

### Feature Details

#### Trial Tier (14 Days)

- Free access to platform
- Limited order processing capacity
- Basic analytics dashboard
- Email support only
- No payment method required at signup
- Automatic conversion prompt 2 days before expiry

#### Basic Tier (Rs 500/month)

- Up to 10 concurrent users
- Advanced order management
- Detailed analytics and reporting
- Email and chat support
- Renewal reminders via email and SMS

#### Professional Tier (Rs 1,200/month or Rs 11,520/year)

- Unlimited concurrent users
- Unlimited order processing
- Premium analytics and custom reports
- Advanced API features
- Priority phone and email support
- Dedicated account manager
- Quarterly business reviews
- 20% discount on annual billing

---

## Payment Gateway Integration

### Supported Payment Methods

#### 1. Khalti (Primary Gateway)

- **Website**: https://khalti.com
- **Market Share**: Highest in Nepal
- **Features**:
  - Mobile wallet integration
  - QR code payments
  - Bank transfer support
  - International cards
- **Settlement Time**: 2-4 hours
- **Supported Currencies**: NPR, USD

#### 2. eSewa (Secondary Gateway)

- **Website**: https://esewa.com.np
- **Market Share**: Second largest
- **Features**:
  - Mobile wallet
  - Bank account integration
  - Cash pickup option
- **Settlement Time**: 24 hours
- **Supported Currencies**: NPR

#### 3. IME Pay (Alternative Gateway)

- **Website**: https://imepay.com.np
- **Features**:
  - Multiple payment options
  - Bank and card support
  - Mobile wallet
- **Settlement Time**: 24-48 hours
- **Supported Currencies**: NPR

#### 4. Fonepay (Backup Gateway)

- **Website**: https://fonepay.com
- **Features**:
  - Mobile-first approach
  - Bank transfer
  - Card payments
- **Settlement Time**: 24 hours
- **Supported Currencies**: NPR

#### 5. Bank Transfer (Manual)

- For enterprise customers
- Manual verification process
- Same-day settlement
- Requires admin approval

### Payment Flow

```
1. Customer Initiates Payment
         ↓
2. System Creates Payment Intent
         ↓
3. Redirect to Payment Gateway
         ↓
4. Customer Completes Payment
         ↓
5. Payment Gateway Returns Webhook
         ↓
6. System Verifies and Activates Subscription
         ↓
7. Send Confirmation Email to Customer
         ↓
8. Update Admin Dashboard
```

### Webhook Security

- **Signature Verification**: All webhooks include HMAC signature
- **IP Whitelisting**: Payment gateway IPs are whitelisted
- **Timestamp Validation**: Requests within 5-minute window only
- **Idempotency**: Duplicate webhook processing prevented via unique event IDs

---

## Database Models

### Core Models

#### 1. SubscriptionPlan

```python
class SubscriptionPlan(models.Model):
    """Base subscription plan definition"""

    name = models.CharField(max_length=50)  # Trial, Basic, Professional
    slug = models.SlugField(unique=True)
    description = models.TextField()

    # Pricing (in NPR)
    monthly_price = models.DecimalField(max_digits=10, decimal_places=2)
    annual_price = models.DecimalField(max_digits=10, decimal_places=2, null=True)

    # Duration
    trial_days = models.PositiveIntegerField(default=0)
    billing_cycle_days = models.PositiveIntegerField(default=30)

    # Features
    max_users = models.PositiveIntegerField(null=True)  # Null = unlimited
    max_orders_per_month = models.PositiveIntegerField(null=True)  # Null = unlimited
    api_rate_limit = models.PositiveIntegerField()  # requests per minute

    # Permissions
    has_analytics = models.BooleanField(default=False)
    has_custom_reports = models.BooleanField(default=False)
    has_priority_support = models.BooleanField(default=False)

    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
```

#### 2. RestaurantSubscription

```python
class RestaurantSubscription(models.Model):
    """Active subscription for a restaurant"""

    STATUS_CHOICES = (
        ('trial', 'Trial'),
        ('active', 'Active'),
        ('expired', 'Expired'),
        ('suspended', 'Suspended'),
        ('cancelled', 'Cancelled'),
    )

    restaurant = models.OneToOneField(
        'restaurants.Restaurant',
        on_delete=models.CASCADE
    )
    plan = models.ForeignKey(
        SubscriptionPlan,
        on_delete=models.PROTECT
    )

    # Subscription status
    status = models.CharField(max_length=20, choices=STATUS_CHOICES)

    # Dates
    start_date = models.DateTimeField(auto_now_add=True)
    end_date = models.DateTimeField()
    trial_ends_at = models.DateTimeField(null=True, blank=True)
    renewal_date = models.DateTimeField(null=True, blank=True)

    # Billing info
    billing_cycle = models.CharField(
        max_length=10,
        choices=[('monthly', 'Monthly'), ('annual', 'Annual')],
        default='monthly'
    )
    auto_renew = models.BooleanField(default=True)

    # Usage tracking
    orders_used_this_month = models.PositiveIntegerField(default=0)
    users_count = models.PositiveIntegerField(default=1)

    # Notifications
    expiry_warning_sent = models.BooleanField(default=False)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
```

#### 3. SubscriptionPayment

```python
class SubscriptionPayment(models.Model):
    """Payment transaction record"""

    STATUS_CHOICES = (
        ('pending', 'Pending'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
        ('cancelled', 'Cancelled'),
        ('refunded', 'Refunded'),
    )

    subscription = models.ForeignKey(
        RestaurantSubscription,
        on_delete=models.CASCADE,
        related_name='payments'
    )

    # Payment details
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    currency = models.CharField(max_length=3, default='NPR')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES)

    # Gateway info
    gateway_name = models.CharField(max_length=50)  # khalti, esewa, etc
    gateway_transaction_id = models.CharField(max_length=255, unique=True)
    gateway_reference = models.CharField(max_length=255, null=True)

    # Dates
    created_at = models.DateTimeField(auto_now_add=True)
    completed_at = models.DateTimeField(null=True, blank=True)

    # Webhook data
    webhook_data = models.JSONField(default=dict)

    # Additional info
    retry_count = models.PositiveIntegerField(default=0)
    error_message = models.TextField(null=True, blank=True)
```

#### 4. SubscriptionAuditLog

```python
class SubscriptionAuditLog(models.Model):
    """Detailed audit trail for all subscription actions"""

    ACTION_CHOICES = (
        ('created', 'Subscription Created'),
        ('upgraded', 'Upgraded Plan'),
        ('downgraded', 'Downgraded Plan'),
        ('renewed', 'Renewed'),
        ('extended', 'Extended'),
        ('cancelled', 'Cancelled'),
        ('expired', 'Expired'),
        ('suspended', 'Suspended'),
        ('payment_initiated', 'Payment Initiated'),
        ('payment_completed', 'Payment Completed'),
        ('payment_failed', 'Payment Failed'),
    )

    subscription = models.ForeignKey(
        RestaurantSubscription,
        on_delete=models.CASCADE,
        related_name='audit_logs'
    )

    action = models.CharField(max_length=50, choices=ACTION_CHOICES)
    actor = models.ForeignKey(
        'core.User',
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )

    # Old and new values
    old_plan = models.ForeignKey(
        SubscriptionPlan,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name='+'
    )
    new_plan = models.ForeignKey(
        SubscriptionPlan,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name='+'
    )

    # Additional data
    details = models.JSONField(default=dict)
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.CharField(max_length=500, null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
```

---

## API Endpoints

### Authentication

All endpoints require authentication via JWT token unless specified.

### Subscription Endpoints

#### 1. Get Current Subscription

```
GET /api/subscriptions/current/
```

**Response (200)**:

```json
{
  "id": 1,
  "restaurant": "Restaurant Name",
  "plan": {
    "id": 1,
    "name": "Professional",
    "monthly_price": 1200,
    "annual_price": 11520
  },
  "status": "active",
  "start_date": "2026-01-31T00:00:00Z",
  "end_date": "2026-02-28T23:59:59Z",
  "billing_cycle": "monthly",
  "auto_renew": true,
  "next_billing_date": "2026-02-28T00:00:00Z"
}
```

#### 2. List Available Plans

```
GET /api/subscriptions/plans/
```

**Response (200)**:

```json
{
  "count": 3,
  "results": [
    {
      "id": 1,
      "name": "Trial",
      "slug": "trial",
      "monthly_price": 0,
      "trial_days": 14,
      "max_users": 1,
      "max_orders_per_month": 100
    },
    {
      "id": 2,
      "name": "Basic",
      "slug": "basic",
      "monthly_price": 500,
      "annual_price": 5000,
      "max_users": 5,
      "max_orders_per_month": 1000
    },
    {
      "id": 3,
      "name": "Professional",
      "slug": "professional",
      "monthly_price": 1200,
      "annual_price": 11520,
      "max_users": null,
      "max_orders_per_month": null
    }
  ]
}
```

#### 3. Upgrade/Downgrade Subscription

```
POST /api/subscriptions/current/upgrade/
Content-Type: application/json

{
  "plan_id": 3,
  "billing_cycle": "annual"
}
```

**Response (200)**:

```json
{
  "id": 1,
  "status": "active",
  "plan": {
    "id": 3,
    "name": "Professional",
    "annual_price": 11520
  },
  "next_billing_date": "2027-01-31T00:00:00Z",
  "proration_credit": 150.0
}
```

#### 4. Renew Subscription

```
POST /api/subscriptions/current/renew/
Content-Type: application/json

{
  "billing_cycle": "monthly"
}
```

**Response (200)**:

```json
{
  "id": 1,
  "status": "active",
  "end_date": "2026-03-31T23:59:59Z",
  "renewal_date": "2026-03-31T00:00:00Z"
}
```

#### 5. Cancel Subscription

```
POST /api/subscriptions/current/cancel/
Content-Type: application/json

{
  "reason": "No longer needed"
}
```

**Response (204)**: No content

#### 6. Initiate Payment

```
POST /api/subscriptions/payments/initiate/
Content-Type: application/json

{
  "gateway": "khalti",
  "return_url": "https://app.example.com/subscription/success"
}
```

**Response (200)**:

```json
{
  "payment_id": 1,
  "gateway_url": "https://khalti.com/checkout/...",
  "gateway_transaction_id": "tx_123456"
}
```

#### 7. Handle Payment Webhook

```
POST /api/subscriptions/webhooks/khalti/
Content-Type: application/json

{
  "event": "charge.completed",
  "data": {
    "transaction_id": "tx_123456",
    "amount": 120000,
    "status": "completed"
  }
}
```

**Response (200)**:

```json
{
  "status": "success",
  "message": "Payment processed successfully"
}
```

#### 8. Get Payment History

```
GET /api/subscriptions/payments/?limit=20&offset=0
```

**Response (200)**:

```json
{
  "count": 15,
  "results": [
    {
      "id": 1,
      "subscription": 1,
      "amount": 1200,
      "currency": "NPR",
      "status": "completed",
      "gateway_name": "khalti",
      "created_at": "2026-01-15T10:30:00Z",
      "completed_at": "2026-01-15T10:35:00Z"
    }
  ]
}
```

### Admin Endpoints

#### 1. List All Subscriptions (Admin)

```
GET /api/admin/subscriptions/?status=active&plan=professional
```

**Response (200)**:

```json
{
  "count": 45,
  "results": [
    {
      "id": 1,
      "restaurant_name": "Pizza Palace",
      "plan": "Professional",
      "status": "active",
      "start_date": "2025-12-01T00:00:00Z",
      "end_date": "2026-12-31T23:59:59Z",
      "monthly_revenue": 1200,
      "user_count": 8
    }
  ]
}
```

#### 2. Suspend Subscription (Admin)

```
POST /api/admin/subscriptions/{id}/suspend/
Content-Type: application/json

{
  "reason": "Payment fraud detected",
  "notify_customer": true
}
```

**Response (200)**:

```json
{
  "id": 1,
  "status": "suspended",
  "suspended_at": "2026-01-31T12:00:00Z"
}
```

#### 3. Manual Subscription Extension (Admin)

```
POST /api/admin/subscriptions/{id}/extend/
Content-Type: application/json

{
  "days": 30,
  "reason": "Goodwill extension",
  "notify_customer": true
}
```

**Response (200)**:

```json
{
  "id": 1,
  "end_date": "2026-03-02T23:59:59Z",
  "extended_by": 30
}
```

#### 4. View Audit Log (Admin)

```
GET /api/admin/subscriptions/{id}/audit-log/
```

**Response (200)**:

```json
{
  "count": 12,
  "results": [
    {
      "id": 1,
      "action": "upgraded",
      "old_plan": "Basic",
      "new_plan": "Professional",
      "actor": "admin@example.com",
      "created_at": "2026-01-15T10:30:00Z"
    }
  ]
}
```

#### 5. Dashboard Statistics (Admin)

```
GET /api/admin/subscriptions/statistics/
```

**Response (200)**:

```json
{
  "total_subscriptions": 250,
  "active_subscriptions": 200,
  "trial_subscriptions": 30,
  "expired_subscriptions": 20,
  "monthly_revenue": 145000,
  "annual_revenue": 1740000,
  "plan_breakdown": {
    "trial": 30,
    "basic": 120,
    "professional": 50
  },
  "expiring_this_week": 5,
  "expiring_this_month": 12
}
```

---

## Subscription Lifecycle

### State Diagram

```
                    ┌────────────┐
                    │   Trial    │
                    └──────┬─────┘
                           │ (14 days)
                           ↓
                    ┌────────────┐
        ┌──────────→│   Active   │←──────────┐
        │           └──────┬─────┘           │
        │                  │                 │
        │        ┌─────────┴────────┐        │
        │        │                  │        │
        │        ↓                  ↓        │
        │   ┌────────┐         ┌────────┐   │
        │   │Expired │         │Suspended│  │
        │   └────────┘         └────────┘   │
        │        │                  │        │
        │        └─────────┬────────┘        │
        │                  │ (Renew)         │
        └──────────────────┘                 │
                                  │          │
                    (Upgrade/Downgrade)      │
                                  │          │
                                  └──────────┘

        ┌─────────────┐
        │  Cancelled  │ (Terminal State)
        └─────────────┘
```

### Lifecycle States

#### 1. Trial (14 days)

- **Entry**: Automatic when customer creates account
- **Duration**: 14 days
- **Features**: Limited access as per Trial plan
- **Exit**:
  - Auto-expiry after 14 days (move to Expired)
  - Manual upgrade by customer (move to Active)
  - Manual suspension by admin (move to Suspended)

#### 2. Active

- **Entry**:
  - Customer completes payment
  - Trial upgrade to paid plan
  - Subscription renewal
  - Admin manual activation
- **Duration**: 30 days (monthly) or 365 days (annual)
- **Features**: Full feature access as per chosen plan
- **Exit**:
  - Natural expiry (move to Expired)
  - Cancellation request (move to Cancelled)
  - Admin suspension (move to Suspended)
  - Payment failure on renewal (move to Expired)

#### 3. Expired

- **Entry**:
  - End date reached without renewal
  - Failed payment on due date
  - Trial period ends without upgrade
- **Duration**: 30 days (grace period)
- **Features**: Read-only access, no new orders
- **Exit**:
  - Customer renews (move to Active)
  - Grace period ends (move to Cancelled)
  - Admin manual extension (move to Active)

#### 4. Suspended

- **Entry**: Admin suspension (fraud, payment issues, policy violation)
- **Duration**: Indefinite
- **Features**: No access to platform
- **Exit**:
  - Admin manual reactivation (move to Active)
  - Customer appeals and resolved (move to Active)

#### 5. Cancelled

- **Entry**:
  - Customer cancellation request
  - Expired grace period end
  - Admin termination
- **Duration**: Permanent
- **Features**: No access
- **Exit**: None (terminal state, can be reactivated as new subscription)

### Transition Events

#### Trial → Active (Upgrade)

```
Event: Payment Completed
Trigger: Webhook from payment gateway
Action:
  1. Update subscription status to "active"
  2. Set end_date to current_date + billing_cycle_days
  3. Create AuditLog entry
  4. Send confirmation email
```

#### Active → Expired

```
Event: End date reached
Trigger: Celery task runs daily
Action:
  1. Check if end_date has passed
  2. Check if auto_renew is enabled
  3. If auto_renew and payment succeeds → Renewal
  4. If payment fails or auto_renew disabled → Expire
  5. Create AuditLog entry
  6. Send expiry notification 3 days before
  7. Send expiry reminder on day 1 after expiry
```

#### Active → Active (Renewal)

```
Event: Auto-renewal triggered
Trigger: Scheduled job or manual request
Action:
  1. Initiate payment for next period
  2. On payment success:
     - Update end_date to current_end_date + billing_cycle_days
     - Create SubscriptionPayment record
     - Create AuditLog entry
     - Send renewal confirmation email
  3. On payment failure:
     - Increment retry_count
     - Schedule retry after 3 days
     - Send payment failure notification after 3 retries
```

#### Active → Active (Upgrade/Downgrade)

```
Event: Plan change requested
Trigger: Customer action or admin action
Action:
  1. Calculate proration amount
  2. If upgrade: charge difference
  3. If downgrade: credit difference
  4. Update subscription plan
  5. Adjust end_date if needed
  6. Create AuditLog with old/new plans
  7. Send change confirmation email
```

---

## Admin Dashboard

### Dashboard Overview

The admin dashboard provides comprehensive subscription management and analytics capabilities.

### 1. Subscription Management

**Features**:

- Filter subscriptions by status, plan, date range
- Search by restaurant name or ID
- Bulk actions (suspend, extend, renew)
- View detailed subscription information
- Edit subscription parameters

**Key Metrics Displayed**:

- Active subscription count
- Monthly recurring revenue (MRR)
- Annual recurring revenue (ARR)
- Churn rate
- Expansion revenue
- Trial conversion rate

### 2. Payment Management

**Features**:

- View all payment transactions
- Filter by status, gateway, date
- Search by transaction ID or restaurant
- Retry failed payments
- Process refunds
- View payment gateway logs

**Displayed Information**:

- Payment amount and currency
- Payment gateway used
- Transaction status and timestamp
- Gateway transaction reference
- Retry attempts and error messages

### 3. Audit Logging

**View All Actions**:

- Subscription creation/modification
- Payment initiation/completion
- Plan upgrades/downgrades
- Suspensions and reactivations
- Admin actions with actor information

**Search and Filter**:

- By subscription or restaurant
- By action type
- By date range
- By admin actor
- By status

**Export Options**:

- Export audit logs as CSV
- Generate compliance reports
- Create trend analysis reports

### 4. Financial Reports

**Available Reports**:

- Revenue by plan
- Revenue by payment gateway
- Monthly revenue trend
- Churn analysis
- Customer lifetime value
- Payment success rate by gateway

**Scheduling**:

- Auto-generated daily/weekly/monthly reports
- Email delivery to designated admin emails
- Archive for audit purposes

### 5. Customer Support Tools

**Features**:

- Manual subscription extension
- Issue partial refunds
- Process manual upgrades/downgrades
- Send custom notifications
- View customer communication history
- Document support interactions

---

## Background Tasks (Celery)

### Task Scheduling

All scheduled tasks run on UTC timezone.

### 1. Daily Subscription Expiry Check

```python
Task: check_subscription_expiry
Schedule: Daily at 02:00 UTC
Actions:
  1. Find subscriptions with end_date == today
  2. For each subscription:
     - Check if auto_renew is enabled
     - If yes: Attempt renewal payment
     - If no: Move to expired state
     - Send expiry notification
  3. Log all actions in audit trail
```

### 2. Expiry Notification (3 Days Before)

```python
Task: send_expiry_warning
Schedule: Daily at 03:00 UTC
Actions:
  1. Find subscriptions expiring in 3 days
  2. Check if warning already sent
  3. Send email notification with:
     - Expiry date
     - Renewal link
     - Upgrade options
  4. Send SMS reminder (if opted in)
  5. Mark warning_sent = True
```

### 3. Payment Retry Handler

```python
Task: retry_failed_payments
Schedule: Every 6 hours
Actions:
  1. Find payments with status = 'failed'
  2. If retry_count < 3:
     - Retry payment processing
     - Increment retry_count
     - Update attempt_at timestamp
  3. If retry_count == 3:
     - Mark as permanent failure
     - Send notification to customer
     - Create support ticket
```

### 4. Subscription Grace Period Cleanup

```python
Task: cleanup_expired_subscriptions
Schedule: Daily at 04:00 UTC
Actions:
  1. Find expired subscriptions with grace_period_end < today
  2. Move to 'cancelled' status
  3. Revoke API access tokens
  4. Archive data
  5. Send final notification
```

### 5. Trial to Free → Paid Conversion

```python
Task: trial_expiry_handler
Schedule: Daily at 01:00 UTC
Actions:
  1. Find trial subscriptions ending in 1 day
  2. Send upgrade reminder email
  3. Send SMS reminder (optional)
  4. Track conversion metrics
```

### 6. Generate Monthly Reports

```python
Task: generate_monthly_reports
Schedule: First day of month at 05:00 UTC
Actions:
  1. Generate revenue reports
  2. Generate churn analysis
  3. Generate plan distribution report
  4. Generate payment gateway performance report
  5. Email reports to superadmins
  6. Archive reports
```

---

## Security Considerations

### 1. Payment Data Security

- **PCI Compliance**: Never store full credit card data
- **Tokenization**: Store only gateway tokens
- **Encryption**: Use TLS 1.3 for all API communications
- **Webhook Signing**: Verify all webhook signatures
- **Rate Limiting**: Implement rate limiting on payment endpoints

### 2. Authentication & Authorization

- **JWT Tokens**: 15-minute expiry for access tokens
- **Refresh Tokens**: 7-day expiry for refresh tokens
- **Role-Based Access**: Separate permissions for admin, superadmin, user
- **IP Whitelisting**: Optional for admin endpoints
- **Multi-Factor Authentication**: Required for admin operations

### 3. Data Protection

- **Encryption at Rest**: Database encryption enabled
- **Encryption in Transit**: TLS for all communications
- **PII Handling**: Minimal PII storage, encrypted where necessary
- **Data Retention**: Define retention policies per data type
- **GDPR Compliance**: Right to be forgotten implementation

### 4. Audit & Monitoring

- **Comprehensive Logging**: All subscription changes logged
- **Activity Monitoring**: Real-time alerting for suspicious activities
- **Intrusion Detection**: Monitor for unauthorized access attempts
- **Regular Backups**: Daily encrypted backups with encryption key rotation

### 5. Fraud Prevention

- **Pattern Detection**: Detect unusual payment patterns
- **Velocity Checks**: Limit payment attempts per time period
- **Geolocation Verification**: Flag payments from unusual locations
- **Device Fingerprinting**: Track device-based patterns
- **Manual Review**: High-value or suspicious transactions reviewed by admin

---

## Error Handling

### HTTP Status Codes

| Code | Meaning              | When Used                         |
| ---- | -------------------- | --------------------------------- |
| 200  | OK                   | Successful request                |
| 201  | Created              | Resource successfully created     |
| 204  | No Content           | Successful deletion               |
| 400  | Bad Request          | Invalid request parameters        |
| 401  | Unauthorized         | Missing or invalid authentication |
| 403  | Forbidden            | Insufficient permissions          |
| 404  | Not Found            | Resource not found                |
| 409  | Conflict             | Invalid state transition          |
| 422  | Unprocessable Entity | Validation failed                 |
| 429  | Too Many Requests    | Rate limit exceeded               |
| 500  | Server Error         | Internal server error             |
| 503  | Service Unavailable  | Maintenance or dependency failure |

### Error Response Format

```json
{
  "error": {
    "code": "INVALID_STATE_TRANSITION",
    "message": "Cannot upgrade from Professional plan",
    "details": {
      "current_plan": "Professional",
      "requested_plan": "Professional",
      "reason": "Already on highest plan"
    },
    "timestamp": "2026-01-31T12:00:00Z",
    "request_id": "req_12345"
  }
}
```

### Common Error Codes

| Code                      | Description                           | Solution                             |
| ------------------------- | ------------------------------------- | ------------------------------------ |
| SUBSCRIPTION_NOT_FOUND    | Subscription doesn't exist            | Verify subscription ID               |
| INVALID_PLAN              | Plan ID is invalid                    | Check available plans                |
| INVALID_STATE_TRANSITION  | Cannot transition to requested state  | Review current state                 |
| PAYMENT_FAILED            | Payment processing failed             | Retry with valid payment method      |
| INSUFFICIENT_PERMISSIONS  | User lacks required permissions       | Contact administrator                |
| RATE_LIMIT_EXCEEDED       | Too many requests                     | Wait before retrying                 |
| WEBHOOK_SIGNATURE_INVALID | Webhook signature verification failed | Verify gateway webhook configuration |
| DUPLICATE_TRANSACTION     | Transaction already processed         | Use different reference ID           |

---

## Testing Strategy

### Unit Tests

```python
# Test Subscription Model
- test_subscription_creation
- test_subscription_status_validation
- test_end_date_calculation
- test_is_expired_property

# Test SubscriptionService
- test_upgrade_plan
- test_downgrade_plan
- test_renew_subscription
- test_calculate_proration

# Test PaymentService
- test_initiate_khalti_payment
- test_verify_khalti_webhook
- test_process_failed_payment
- test_handle_duplicate_webhook
```

### Integration Tests

```python
# Test Complete Workflows
- test_trial_to_basic_upgrade
- test_monthly_to_annual_renewal
- test_subscription_cancellation
- test_payment_retry_on_failure
- test_multiple_plan_changes

# Test Payment Gateways
- test_khalti_integration
- test_esewa_integration
- test_payment_verification
- test_refund_processing
```

### API Tests

```python
# Test Endpoints
- test_get_current_subscription
- test_list_available_plans
- test_upgrade_subscription
- test_renew_subscription
- test_cancel_subscription
- test_webhook_payload_validation
```

### Performance Tests

```python
# Load Testing
- test_high_volume_payments
- test_concurrent_renewals
- test_large_dataset_queries
- test_webhook_processing_latency

# Database Tests
- test_query_optimization
- test_index_efficiency
- test_bulk_operations
```

---

## Deployment Checklist

### Pre-Deployment

- [ ] All tests passing (unit, integration, API)
- [ ] Code review completed
- [ ] Database migrations tested on staging
- [ ] Webhook endpoints tested with actual gateway
- [ ] Email templates tested
- [ ] SMS template tested
- [ ] Admin dashboard functionality verified
- [ ] Error handling for edge cases verified

### Deployment Steps

1. **Database**:
   - Backup production database
   - Run migrations in production
   - Verify all tables created

2. **Application**:
   - Deploy updated code
   - Restart application servers
   - Verify service health

3. **Celery Tasks**:
   - Deploy task definitions
   - Restart Celery workers
   - Verify scheduled tasks are registered

4. **Configuration**:
   - Update payment gateway credentials
   - Configure webhook endpoints
   - Set email/SMS configurations

5. **Testing**:
   - Test complete payment flow
   - Test webhook processing
   - Test admin dashboard
   - Monitor logs for errors

### Post-Deployment

- [ ] Monitor application logs for errors
- [ ] Monitor payment gateway webhooks
- [ ] Check database query performance
- [ ] Verify scheduled tasks executing
- [ ] Monitor customer reports of issues
- [ ] Review analytics for anomalies

---

## Support & Maintenance

### Regular Maintenance

- **Weekly**: Review payment failure patterns
- **Weekly**: Check system performance metrics
- **Monthly**: Generate revenue and churn reports
- **Monthly**: Review and archive old logs
- **Monthly**: Update payment gateway status
- **Quarterly**: Security audit and penetration testing
- **Quarterly**: Database optimization and cleanup

### Monitoring & Alerts

```
Critical Alerts:
- Payment gateway down (set up bypass)
- Database connection pool exhausted
- Email service unavailable
- Webhook processing backlog > 1000
- API response time > 5 seconds

Warning Alerts:
- Failed payment rate > 10%
- Email delivery failure rate > 5%
- Celery task queue backlog > 100
- API response time > 2 seconds
```

### Contact & Support

- **Technical Support**: tech-support@example.com
- **Payment Issues**: payments@example.com
- **Emergency Hotline**: +977-1-XXXXXXX
- **Documentation**: https://docs.example.com/subscriptions
- **API Status**: https://status.example.com

---

## Appendix

### A. Payment Gateway API Credentials

Store in environment variables:

```bash
KHALTI_PUBLIC_KEY=your_public_key
KHALTI_SECRET_KEY=your_secret_key

ESEWA_MERCHANT_CODE=your_merchant_code
ESEWA_PASSWORD=your_password

IMEPAY_API_KEY=your_api_key

FONEPAY_MERCHANT_ID=your_merchant_id
FONEPAY_API_KEY=your_api_key
```

### B. Webhook Configuration

**Khalti**:

```
https://api.example.com/subscriptions/webhooks/khalti/
```

**eSewa**:

```
https://api.example.com/subscriptions/webhooks/esewa/
```

**IME Pay**:

```
https://api.example.com/subscriptions/webhooks/imepay/
```

### C. Email Templates

Required templates:

- Welcome to Trial
- Trial Expiry Warning (3 days before)
- Upgrade Confirmation
- Payment Receipt
- Renewal Confirmation
- Subscription Cancelled
- Payment Failed Notification
- Suspension Notice

### D. Database Indexes

Recommended indexes for performance:

```sql
CREATE INDEX idx_restaurant_subscription_status
  ON core_restaurantsubscription(status);

CREATE INDEX idx_subscription_end_date
  ON core_restaurantsubscription(end_date);

CREATE INDEX idx_payment_gateway_transaction_id
  ON core_subscriptionpayment(gateway_transaction_id);

CREATE INDEX idx_audit_log_subscription
  ON core_subscriptionauditlog(subscription_id);

CREATE INDEX idx_audit_log_created_at
  ON core_subscriptionauditlog(created_at);
```

---

## Version History

| Version | Date       | Changes                       |
| ------- | ---------- | ----------------------------- |
| 1.0     | 2026-01-31 | Initial documentation release |

---

**Document Last Updated**: January 31, 2026  
**Status**: Production Ready  
**Maintained By**: Backend Team  
**Next Review**: April 30, 2026
