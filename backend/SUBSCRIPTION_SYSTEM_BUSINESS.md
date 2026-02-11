# Bhansa Ghar - Subscription System

## Business & Operations Documentation

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [System Overview](#system-overview)
3. [Subscription Plans](#subscription-plans)
4. [Payment Methods](#payment-methods)
5. [Subscription Lifecycle](#subscription-lifecycle)
6. [Admin Dashboard Features](#admin-dashboard-features)
7. [Customer Experience](#customer-experience)
8. [Revenue Management](#revenue-management)
9. [Security & Compliance](#security--compliance)
10. [Support & Maintenance](#support--maintenance)

---

## Executive Summary

The Bhansa Ghar Subscription System is a comprehensive platform designed to manage restaurant subscriptions with multiple payment options, automated billing, and detailed financial tracking. The system enables restaurants to choose from tiered subscription plans based on their operational needs and automatically handles renewal, payments, and customer notifications.

### Key Objectives

- Provide multiple subscription tiers to serve different restaurant sizes
- Enable seamless payment processing through popular Nepal payment gateways
- Automate subscription management and renewal processes
- Provide comprehensive financial tracking and reporting
- Ensure secure and reliable transaction handling
- Maintain detailed audit trails for compliance

### Target Audience

- Restaurant chains and individual establishments
- Quick-service restaurants (QSRs)
- Nepal-based business customers
- Restaurants with varying operational scales

---

## System Overview

### What is the Subscription System?

The Subscription System is an automated billing and management platform that allows restaurants to subscribe to Bhansa Ghar services on a monthly or annual basis. Customers can select a plan that matches their needs, pay through their preferred payment method, and automatically receive access to all features included in their subscription tier.

### Key Features

#### 1. Multiple Subscription Tiers

- **Trial Plan**: Free 14-day access for new customers to experience the platform
- **Basic Plan**: Affordable monthly subscription for small to medium restaurants
- **Professional Plan**: Premium subscription for large restaurants with unlimited features

#### 2. Flexible Payment Options

- Multiple payment gateways available (Khalti, eSewa, IME Pay, Fonepay)
- Monthly or annual billing cycles
- Annual discount for yearly subscriptions (20% savings)
- Bank transfer option for enterprise customers

#### 3. Automated Renewal System

- Automatic subscription renewal on expiry date
- Optional auto-renewal for customer control
- Payment retry mechanism for failed transactions
- Advance notifications before expiry

#### 4. Comprehensive Audit Trail

- Complete record of all subscription actions
- Payment transaction history
- Plan change documentation
- Admin action logging for compliance

#### 5. User Management

- Flexible user seat management per plan
- Scaling from 1 user (trial) to unlimited users (professional)
- User activity tracking

---

## Subscription Plans

### Plan Tiers Overview

The subscription system offers three distinct tiers designed to serve different business sizes and needs.

#### Trial Plan (14 Days - Free)

**Best For**: New restaurants evaluating the platform

**Features**:

- Free 14-day trial period
- Basic platform access
- Limited order processing (100 orders during trial)
- Single user access
- Basic analytics dashboard
- Email support only
- No credit card required to start
- Automatic upgrade prompts starting 2 days before expiry

**Conversion Path**:

- Customers can upgrade to Basic or Professional plan at any time
- Automatic expiry and option to renew with paid plan
- Upgrade typically happens after customers test the platform functionality

#### Basic Plan (Rs 500/month)

**Best For**: Small to medium-sized restaurants

**Features**:

- Monthly subscription at Rs 500
- Annual option at Rs 5,000 (no discount)
- Up to 10 concurrent users
- 1,000 orders per month allowance
- Advanced order management capabilities
- Detailed analytics and reporting
- Email and chat support
- Standard API access
- SMS and email renewal reminders

**Ideal Use Cases**:

- Single branch restaurants
- Restaurants with limited staff
- Start-ups testing multi-location operations
- Restaurants wanting to evaluate professional features

#### Professional Plan (Rs 1,200/month or Rs 11,520/year)

**Best For**: Large restaurants and chains

**Features**:

- Monthly subscription at Rs 1,200
- Annual subscription at Rs 11,520 (20% discount = Rs 2,880 savings annually)
- Unlimited concurrent users
- Unlimited order processing
- Premium analytics with custom reports
- Advanced API features
- Priority phone and email support
- Dedicated account manager
- Quarterly business reviews
- Early access to new features

**Ideal Use Cases**:

- Multi-branch restaurant chains
- High-volume restaurants
- Restaurants requiring custom integrations
- Enterprises needing dedicated support

### Plan Feature Comparison

| Feature              | Trial       | Basic        | Professional        |
| -------------------- | ----------- | ------------ | ------------------- |
| **Duration**         | 14 days     | 30 days      | 30 days             |
| **Price**            | Free        | Rs 500/month | Rs 1,200/month      |
| **Annual Price**     | -           | Rs 5,000     | Rs 11,520 (20% off) |
| **Concurrent Users** | 1           | 10           | Unlimited           |
| **Monthly Orders**   | 100         | 1,000        | Unlimited           |
| **Analytics**        | Basic       | Advanced     | Premium             |
| **Custom Reports**   | No          | No           | Yes                 |
| **Support**          | Email       | Email + Chat | Priority Support    |
| **API Rate Limit**   | 100 req/min | 500 req/min  | 2000 req/min        |
| **Account Manager**  | No          | No           | Yes                 |
| **Business Review**  | No          | No           | Yes                 |

---

## Payment Methods

### Available Payment Gateways

The system supports five different payment methods to accommodate various customer preferences and ensure maximum payment completion rates.

#### 1. Khalti (Primary Gateway)

**Overview**:
Khalti is the most popular digital payment platform in Nepal with the widest customer adoption. It offers multiple payment options including mobile wallet, QR code payments, and bank transfers.

**Why It's Primary**:

- Largest user base in Nepal
- Fastest settlement time (2-4 hours)
- Supports both NPR and USD transactions
- QR code payment feature popular with restaurants
- Highest transaction success rate

**Customer Payment Options via Khalti**:

- Mobile wallet payment
- Bank account linking
- Debit/credit cards
- International cards
- QR code scanning

#### 2. eSewa (Secondary Gateway)

**Overview**:
eSewa is Nepal's second-largest digital payment provider with strong market presence among businesses and individuals.

**Features**:

- Mobile wallet integration
- Bank account direct payments
- Cash pickup options for some users
- Next-day settlement
- Competitive transaction fees

**Customer Base**:
Customers preferring alternative to Khalti or those with existing eSewa wallets

#### 3. IME Pay (Alternative Gateway)

**Overview**:
IME Pay provides diverse payment options including both online and alternative payment methods.

**Features**:

- Multiple payment options (cards, banks, mobile)
- Integration with IME infrastructure
- 24-48 hour settlement
- Competitive pricing for enterprise customers

**Use Case**:
Alternative payment option for customers with existing IME relationships

#### 4. Fonepay (Backup Gateway)

**Overview**:
Fonepay focuses on mobile-first payments with emphasis on accessibility.

**Features**:

- Mobile phone number-based payments
- Bank transfer support
- Card payments
- 24-hour settlement

**Use Case**:
Backup option ensuring payment processing capability even if primary gateways face issues

#### 5. Bank Transfer (Manual - Enterprise)

**Overview**:
For large enterprise customers, direct bank transfer option with manual verification.

**Features**:

- Direct settlement to business bank account
- Same-day verification by admin
- Premium service level
- Custom invoicing

**Process**:

- Customer submits bank transfer request
- Admin receives and verifies payment
- Subscription activated upon verification
- Detailed invoice provided

### Payment Flow Overview

1. **Customer Initiates Payment**: Customer selects payment gateway and subscription plan
2. **Gateway Redirect**: Customer is redirected to chosen payment gateway
3. **Payment Completion**: Customer completes payment on gateway platform
4. **Confirmation**: Gateway sends confirmation back to system
5. **Subscription Activation**: Subscription is immediately activated
6. **Email Confirmation**: Customer receives payment receipt and welcome email
7. **Admin Notification**: Admin dashboard updated with new payment

### Automatic Renewal

- Subscriptions automatically renew on expiry date (if auto-renewal enabled)
- System attempts payment using stored payment method
- If payment fails, automatic retry after 3 days
- Customer notified of payment status via email
- After 3 failed attempts, subscription expires and customer contacted

---

## Subscription Lifecycle

### Customer Journey Overview

The subscription lifecycle describes the complete journey of a restaurant from initial signup through active usage, renewal, potential upgrades, and eventual cancellation.

### Stage 1: Trial Phase (Days 1-14)

**What Happens**:

- Customer creates account automatically on Trial plan
- Full platform access for 14 days
- No payment information required
- Customer can explore all features
- System tracks usage and sends engagement emails

**Milestones**:

- Day 1: Welcome email with platform overview
- Day 7: Feature highlight email
- Day 11: Upgrade reminder email
- Day 13: Final upgrade prompt with plan comparison

**Customer Actions Available**:

- Upgrade to Basic or Professional plan at any time
- Cancel subscription (no penalty)
- Continue using trial until expiry

**System Actions**:

- Monitor usage patterns
- Send educational content
- Track which features customers use
- Prepare upgrade conversion emails

### Stage 2: Active Paid Subscription

**What Happens**:

- Customer completes payment and is upgraded to chosen plan
- Full feature access based on plan tier
- Billing cycle begins
- Subscription remains active until expiry or cancellation

**Subscription Cycle Duration**:

- Monthly: 30 days
- Annual: 365 days

**Customer Features Available**:

- All features included in chosen plan
- User management (add/remove team members)
- Analytics and reporting
- Support access
- API integration capabilities

**Renewal Process**:

- 30 days before expiry: No notification sent yet
- 14 days before expiry: Renewal reminder email sent
- 7 days before expiry: SMS reminder sent
- 3 days before expiry: Final reminder with "Renew Now" button
- 1 day before expiry: Last call reminder
- On expiry date: Automatic payment attempted

**Usage Tracking During Active Cycle**:

- Orders processed counted against monthly allowance
- Number of active users monitored
- API usage tracked against rate limits
- Feature usage logged for analytics

### Stage 3: Renewal

**Automatic Renewal (If Enabled)**:

- System attempts payment on expiry date
- If successful → Subscription continues uninterrupted
- Confirmation email sent to customer
- Next renewal date set
- If failed → Retries after 3 days (max 3 attempts)

**Manual Renewal**:

- Customer initiates renewal manually via dashboard
- Customer selects billing cycle (monthly/annual)
- Payment gateway opens
- Upon completion, subscription extends

**Renewal Incentives**:

- Annual renewal offers 20% discount on Professional plan
- Loyalty email with discount codes for consistent customers
- Auto-upgrade options at renewal time

### Stage 4: Plan Changes (Upgrades/Downgrades)

**Upgrade Scenario** (Basic → Professional):

- Customer selects new plan
- System calculates proration (difference between plans)
- If upgrading mid-cycle, customer receives credit
- Payment for upgrade difference processed
- New plan features immediately available
- Change recorded in audit log for compliance
- Confirmation email sent to customer

**Downgrade Scenario** (Professional → Basic):

- Customer requests downgrade
- System calculates proration credit
- Credit applied to account
- New plan features effective next billing cycle
- Confirmation email sent

**Timing of Changes**:

- Can be done at any point in subscription cycle
- Changes typically effective immediately
- Some restrictions may apply (e.g., downgrading if team size exceeds plan limit)

### Stage 5: Expiry Without Renewal

**What Happens**:

- Subscription end date reached
- Auto-renewal disabled or payment fails
- Subscription moves to "Expired" state
- 30-day grace period begins

**Grace Period Benefits**:

- Limited read-only access to platform
- Can view historical data
- Cannot create new orders
- Cannot add new users
- Support access discontinued

**Grace Period Notifications**:

- Immediate: "Subscription Expired" email
- Day 5: "Renew Now" reminder email
- Day 25: "Last Chance" reminder email
- Day 30: Final expiry notice

**Options During Grace Period**:

- Renew subscription (returns to Active state)
- Upgrade to higher plan with proration credits
- Cancel permanently

### Stage 6: Cancellation

**What Happens**:

- Customer requests cancellation
- Subscription immediately deactivated (or at end of cycle)
- Full access removed
- Data archived but available for export
- No refund issued (non-refundable service)

**Customer Feedback**:

- Cancellation survey sent
- Exit interview email asking for feedback
- Option to provide reason for cancellation

**Reactivation Options**:

- Customer can create new subscription anytime
- Previous data remains archived
- New subscription starts fresh (no trial period for returning customers)

### Stage 7: Suspension (Admin Action)

**When Suspension Occurs**:

- Suspicious activity detected
- Payment fraud suspected
- Multiple payment failures
- Policy violation
- Admin manual suspension

**During Suspension**:

- Complete access revoked
- Platform unavailable
- Data remains archived
- Customer cannot renew or upgrade

**Resolution Process**:

- Customer contacted with suspension reason
- Appeal process available
- Admin review and decision
- Reactivation upon resolution

---

## Admin Dashboard Features

### Dashboard Purpose

The Admin Dashboard is the central management hub for subscription operations, providing visibility into all active subscriptions, payment processing, customer management, and financial performance.

### 1. Subscription Management

**Overview Section**:

- Total active subscriptions count
- Breakdown by plan (Trial/Basic/Professional)
- Subscriptions expiring this week
- Subscriptions expiring this month
- Expiring vs Expired distribution

**Subscription Listing**:

- View all subscriptions with key information
- Filter by status (Active, Expired, Suspended, Cancelled)
- Filter by plan type
- Search by restaurant name
- Sort by expiry date, revenue, or creation date
- Bulk actions: Select multiple and suspend, extend, or notify

**Individual Subscription Details**:

- Restaurant name and contact information
- Current plan details
- Subscription start and end dates
- Auto-renewal status
- Total users on subscription
- Usage metrics (orders processed, API calls)
- Payment history
- Audit trail of all actions

**Admin Actions Available**:

- View full subscription details
- Suspend subscription
- Extend subscription for additional days (goodwill gesture)
- Manually activate/reactivate subscription
- Change subscription plan
- Enable/disable auto-renewal
- Send custom notification to customer

### 2. Payment Management

**Payment Dashboard**:

- Total revenue (this month, this quarter, year-to-date)
- Revenue by payment gateway breakdown
- Failed payment rate and attempts
- Average payment processing time
- Revenue trend chart

**Payment Transaction List**:

- All payment transactions with timestamp
- Payment status (Pending, Completed, Failed, Refunded)
- Payment gateway used
- Amount and currency
- Customer/Restaurant name
- Transaction reference ID
- Retry attempts count

**Payment Filters & Search**:

- Filter by status (Completed, Failed, Pending)
- Filter by payment gateway (Khalti, eSewa, etc.)
- Filter by date range
- Search by transaction ID
- Search by restaurant name

**Payment Admin Actions**:

- View detailed payment information
- Retry failed payments (manually trigger retry)
- Process refunds
- Generate payment report
- View gateway logs for transaction
- Issue payment receipts

### 3. Financial Analytics

**Revenue Metrics**:

- Monthly Recurring Revenue (MRR) - sum of all monthly subscriptions
- Annual Recurring Revenue (ARR) - projected yearly revenue
- Total Revenue (cumulative)
- Revenue by plan type breakdown
- Revenue by payment gateway
- Revenue growth trend

**Customer Metrics**:

- Total customers/restaurants
- New customers this month
- Churn rate (% of subscriptions ending)
- Expansion revenue (from plan upgrades)
- Trial conversion rate (% of trials converted to paid)
- Average customer lifetime value

**Payment Metrics**:

- Payment success rate by gateway
- Failed payment rate
- Retry success rate
- Average payment processing time
- Refund rate

**Reports Available**:

- Monthly revenue report
- Plan distribution report
- Customer churn analysis
- Payment gateway performance report
- Customer growth trend
- Custom date range reports

### 4. Audit & Compliance Logging

**Audit Trail Access**:

- View all subscription actions chronologically
- Filter by action type (Created, Upgraded, Renewed, etc.)
- Filter by actor (which admin made the action)
- Filter by date range
- Filter by affected subscription/restaurant
- Search by action details

**Action Types Logged**:

- Subscription created
- Plan upgraded or downgraded
- Subscription renewed
- Subscription extended
- Subscription suspended
- Subscription cancelled
- Payment initiated
- Payment completed
- Payment failed
- Refund processed
- Admin actions on subscription

**Information Captured**:

- What action occurred
- When it occurred (timestamp)
- Who performed the action (admin user)
- What changed (old values vs new values)
- IP address of the admin
- User agent (browser/device information)
- Additional details and context

**Compliance Reports**:

- Generate audit reports by date
- Export audit logs as CSV
- Generate compliance certificate
- Track admin user activities
- Document all plan changes for billing accuracy

### 5. Customer Support Tools

**Support Features**:

- View customer communication history
- Send custom messages/notifications
- Grant subscription extensions
- Process one-time credits
- Manually upgrade/downgrade plans
- View customer usage details
- Track support tickets/issues

**Support Actions**:

- Send promotional message to specific plan customers
- Send renewal reminder to expiring subscriptions
- Send feature update announcement
- Issue partial refunds for specific amounts
- Document customer support interactions
- Create bulk notification campaigns

### 6. System Monitoring

**Health Checks**:

- Payment gateway status (up/down)
- Email service status
- SMS service status
- System performance metrics
- Database health
- API response times

**Alerts & Notifications**:

- Payment gateway outages
- High payment failure rate
- Email delivery issues
- Unusual activity detected
- Scheduled task failures
- Low system resources

---

## Customer Experience

### Sign-Up Process

**Step 1: Account Creation**

- Customer registers with email and basic restaurant information
- Automatically assigned Trial plan (14 days)
- Welcome email sent
- Account dashboard accessible immediately

**Step 2: Onboarding**

- Welcome tour of platform features
- Feature highlight emails sent during trial
- Support available via email
- Documentation and help articles provided

**Step 3: Trial Usage**

- Full platform access for 14 days
- No credit card required
- Limited to 100 orders during trial
- Can invite up to 1 user

### Upgrade to Paid Plan

**When to Upgrade**:

- At any time during trial (14 days)
- Before trial expires (recommended 2 days before)
- Plan options clearly presented with feature comparison
- Pricing displayed in NPR

**Upgrade Process**:

1. Customer selects desired plan (Basic or Professional)
2. Customer selects billing cycle (Monthly or Annual)
3. Customer chooses payment method (Khalti, eSewa, IME Pay, Fonepay)
4. Payment gateway opens in new window
5. Customer completes payment
6. System verifies payment and activates subscription
7. Confirmation email received with invoice

**After Upgrade**:

- Immediate access to all plan features
- Team members can be added (up to plan limit)
- Increase to higher order processing limit
- Advanced analytics available
- Support upgraded to chat + email

### Renewal Experience

**Reminder Notifications**:

- 14 days before expiry: Email reminder with "Renew Now" button
- 7 days before expiry: SMS reminder
- 3 days before expiry: Final push email
- 1 day before expiry: Last reminder

**Auto-Renewal (If Enabled)**:

- Customer doesn't need to do anything
- System automatically charges on expiry date
- Confirmation email sent
- Subscription continues seamlessly

**Manual Renewal Option**:

- Customer can renew anytime before expiry
- Optional to upgrade plan during renewal
- Can switch between monthly and annual billing
- Remaining balance prorated if applicable

**Post-Renewal**:

- Confirmation email with new end date
- Invoice generated and sent
- New billing cycle begins

### Support Access

**Available Support Channels**:

**Trial Plan**:

- Email support only
- Response time: 24-48 hours
- Help documentation and FAQs
- No dedicated support staff

**Basic Plan**:

- Email support
- Chat support during business hours
- Response time: 12-24 hours
- Help documentation and FAQs
- Ticket-based tracking

**Professional Plan**:

- Priority email support (4-hour response)
- Priority chat support (1-hour response)
- Phone support available
- Dedicated account manager
- Custom training sessions
- Quarterly business reviews

### User Management

**Adding Team Members**:

- Admin can invite users to subscription
- Invite via email
- Users can set their own password
- Team member receives onboarding email
- User count tracked against plan limit

**Role-Based Access** (if applicable):

- Owner/Admin: Full access
- Manager: Operational access
- Staff: Limited operational access
- Viewer: Read-only access

**User Limits**:

- Trial: 1 user maximum
- Basic: 10 users maximum
- Professional: Unlimited users

---

## Revenue Management

### Pricing Strategy

**Plan Pricing**:

- Trial: Free (loss leader to acquire customers)
- Basic: Rs 500/month or Rs 5,000/year (no annual discount)
- Professional: Rs 1,200/month or Rs 11,520/year (20% annual discount)

**Discount Strategy**:

- Annual subscriptions get 20% discount on Professional plan
- Encourages longer commitment and improves retention
- Reduces payment processing costs for annual payments
- Creates predictable revenue

### Revenue Recognition

**Monthly Billing**:

- Charged on same date each month
- If expiry date is month-end, rolls to equivalent day
- Subscription continues indefinitely with auto-renewal

**Annual Billing**:

- Charged once per year
- Next charge date clearly displayed
- Flat rate for entire year regardless of month

**Pro-rating**:

- When upgrading mid-cycle: Customer charged difference
- When downgrading mid-cycle: Customer receives credit
- Credit applied to account, not refunded

### Revenue Expansion

**Upgrade Opportunities**:

- Prompt upgrades during onboarding
- Suggest upgrades when customers approach limits (users/orders)
- Upgrade incentives at renewal time

**Metrics Tracked**:

- Trial to Paid conversion rate (target: 15-20%)
- Basic to Professional expansion rate
- Annual commitment rate
- Average revenue per customer
- Customer lifetime value

### Refund Policy

**Policy**:

- Subscriptions are non-refundable once activated
- Pro-rating credits for downgrades applied to account
- Cancellation results in immediate access revocation
- No refunds for partial month cancellations

**Exceptions**:

- Billing errors automatically credited
- Failed delivery of services may result in credit
- Long-term customers may receive goodwill credit
- Admin discretion in disputed cases

---

## Security & Compliance

### Payment Security

**Data Protection**:

- Payment card data never stored in system
- Only payment gateway tokens stored (safe to store)
- All payment data encrypted in transit (TLS 1.3)
- Payment sensitive endpoints use HTTPS only
- Regular security audits of payment flow

**PCI Compliance**:

- Compliance with Payment Card Industry Data Security Standard
- Third-party payment processors handle card data
- No card data passes through our servers
- Tokens used for recurring payments

**Fraud Prevention**:

- Unusual transaction patterns detected
- Velocity checks (rapid fire payments blocked)
- Geolocation verification for transactions
- Manual review of flagged transactions
- Admin team trained in fraud detection

### Customer Data Security

**Data Encryption**:

- Customer data encrypted at rest (database)
- Data encrypted in transit (all APIs use HTTPS)
- Encryption keys rotated regularly
- Secure key management practices

**Data Access**:

- Minimal staff access to customer data (need-to-know basis)
- Admin actions logged and audited
- Two-factor authentication for admin access
- IP whitelisting for admin access (optional)

**Data Retention**:

- Active subscription data kept indefinitely
- Expired subscription data retained for 7 years (legal requirement)
- Customer request for deletion honored (with restrictions)
- Regular backups maintained (daily)
- Backup retention: 30 days for daily, 1 year for monthly

### Compliance & Regulations

**Nepal Regulations**:

- Compliant with Nepal Payment Gateway regulations
- Proper licensing and approvals obtained
- Tax reporting in compliance with Nepal tax laws
- Data localization requirements met

**International Standards**:

- GDPR compliance for EU customer data
- Data privacy agreements in place
- Cookie consent management
- Privacy policy clearly communicated

---

## Support & Maintenance

### Regular Operations

**Daily Tasks**:

- Monitor payment gateway status
- Check for failed payments
- Review new customer signups
- Monitor system performance
- Check email delivery status

**Weekly Tasks**:

- Review payment failure patterns
- Analyze new customer metrics
- Check subscription expiry notices
- Review support tickets
- Performance optimization review

**Monthly Tasks**:

- Generate financial reports
- Analyze churn rate and reasons
- Review customer feedback
- Payment gateway reconciliation
- Security audit
- Update documentation

**Quarterly Tasks**:

- Comprehensive security audit
- Payment gateway contract review
- Strategic planning and roadmap updates
- Customer satisfaction survey
- Infrastructure optimization
- Disaster recovery testing

### Monitoring & Alerts

**Critical System Alerts** (Immediate Action Required):

- Payment gateway down or unavailable
- Email service failure
- Database issues
- API response time > 5 seconds
- Failed payment rate > 15%
- Webhook processing backlog

**Warning Alerts** (Review Needed):

- Failed payment rate > 10%
- Email delivery rate < 95%
- High customer support ticket volume
- Unusual spike in cancellations
- Performance degradation
- Low system resources

### Emergency Procedures

**Payment Gateway Outage**:

- Automatic failover to backup gateway
- Manual processing capability for critical payments
- Customer notification sent
- Timeline for resolution provided

**Data Loss**:

- Immediate restoration from backup
- Customer notification and timeline
- Backup integrity verification
- Post-incident analysis

**Security Breach**:

- Immediate investigation
- Customer notification if data compromised
- Regulatory notification per requirements
- Enhanced monitoring during recovery
- Post-breach security updates

### Maintenance Windows

**Planned Maintenance**:

- Scheduled during low-traffic periods (typically 2-4 AM Nepal Time)
- 48-hour advance notice provided to customers
- Email notification sent
- Estimated duration: 30-60 minutes
- Automatic renewal paused during maintenance

**Major Updates**:

- Scheduled quarterly
- Full 1-week advance notice
- Detailed change documentation provided
- Rollback plan prepared
- Post-update validation

### Customer Communication

**During Issues**:

- Transparent communication about status
- Regular updates (at least hourly for major issues)
- Impact assessment shared
- Estimated resolution time provided
- Post-issue summary sent

**Proactive Notifications**:

- Planned maintenance announcements
- New feature releases
- System updates
- Security patches
- Payment gateway updates

### Support Team Structure

**Support Channels**:

- Email: general@bhansaghar.com
- Chat: In-platform chat (Business hours)
- Phone: +977-1-XXXXXXX (Enterprise customers)
- Emergency: +977-1-XXXXXXX

**Response Targets**:

- Trial customers: 24-48 hours
- Basic plan: 12-24 hours
- Professional plan: 4 hours (email), 1 hour (chat)

---

## Key Performance Indicators (KPIs)

### Business Metrics

| Metric                      | Target  | Frequency |
| --------------------------- | ------- | --------- |
| Trial Conversion Rate       | 15-20%  | Monthly   |
| Monthly Recurring Revenue   | Growing | Monthly   |
| Customer Churn Rate         | < 5%    | Monthly   |
| Expansion Revenue           | > 10%   | Monthly   |
| Customer Satisfaction Score | > 4.5/5 | Quarterly |

### Operational Metrics

| Metric                  | Target      | Frequency |
| ----------------------- | ----------- | --------- |
| Payment Success Rate    | > 95%       | Daily     |
| System Uptime           | > 99.9%     | Daily     |
| Email Delivery Rate     | > 98%       | Daily     |
| Support Response Time   | < Target    | Real-time |
| Payment Processing Time | < 2 minutes | Hourly    |

### Financial Metrics

| Metric                   | Frequency |
| ------------------------ | --------- |
| Revenue by Plan          | Monthly   |
| Revenue by Gateway       | Monthly   |
| Total Revenue            | Weekly    |
| Average Revenue Per User | Monthly   |
| Customer Lifetime Value  | Quarterly |

---

## Roadmap & Future Enhancements

### Phase 1 (Launch)

- Core subscription functionality
- Three payment gateways (Khalti, eSewa, IME Pay)
- Basic admin dashboard
- Email notifications

### Phase 2 (Q2 2026)

- Additional payment gateway (Fonepay, Bank Transfer)
- Advanced analytics dashboard
- Customer self-service portal
- SMS notifications
- API documentation

### Phase 3 (Q3 2026)

- Mobile app for subscription management
- Dedicated account manager feature
- Custom integrations
- Premium reporting
- Webhook system for partners

### Phase 4 (Q4 2026)

- Multi-currency support
- International payment methods
- Advanced fraud detection
- Machine learning-based churn prediction
- Usage-based billing option

---

## Conclusion

The Bhansa Ghar Subscription System provides a flexible, secure, and user-friendly platform for managing restaurant subscriptions. With multiple payment options, automated renewal, and comprehensive admin controls, it enables restaurants to focus on their business while the system handles billing and subscription management automatically.

The system is designed with scalability in mind, supporting growth from single restaurants to large multi-branch chains. Continuous monitoring and regular updates ensure the system remains secure, reliable, and responsive to customer needs.

---

**Document Version**: 1.0  
**Last Updated**: January 31, 2026  
**Status**: Ready for Review  
**Maintained By**: Product & Operations Team  
**Next Review Date**: April 30, 2026
