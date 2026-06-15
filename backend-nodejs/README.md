# NexPlay Backend

Simple Node.js server for handling Stripe payments and Resend invoice emails.

## Requirements

- Node.js 18+
- Stripe account
- Resend account

## Setup

1. Install dependencies

```bash
   npm install
```

2. Create `.env` file

```bash
   STRIPE_SECRET_KEY=sk_test_xxx
   RESEND_API_KEY=re_xxx
   PORT=3000
```

3. Run server

```bash
   make run
```

## Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/create-payment-intent` | Create Stripe payment intent |
| POST | `/send-invoice` | Send invoice email via Resend |

___
