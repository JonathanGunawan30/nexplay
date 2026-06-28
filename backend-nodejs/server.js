require('dotenv').config();
const express = require('express');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const cloudinary = require('cloudinary').v2;
const { Resend } = require('resend');
const cors = require('cors');
const invoiceTemplate = require('./templates/invoice');
const generateInvoicePdf = require('./templates/pdfInvoice');

// Configure Cloudinary
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET
});

const app = express();
const resend = new Resend(process.env.RESEND_API_KEY);

app.use(express.json());
app.use(cors());

app.post('/create-payment-intent', async (req, res) => {
  try {
    const { amount, currency } = req.body;

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount,
      currency: currency || 'usd',
      automatic_payment_methods: { enabled: true },
    });

    res.status(200).send({ clientSecret: paymentIntent.client_secret });
  } catch (error) {
    console.error('Stripe Error:', error.message);
    res.status(500).send({ error: error.message });
  }
});

app.post('/send-invoice', async (req, res) => {
  try {
    const { email, name, gameName, amount, currency } = req.body;

    const date = new Date().toLocaleDateString('en-US', {
      year: 'numeric', month: 'long', day: 'numeric',
    });

    // ponytail: Generate PDF in memory buffer
    const pdfBuffer = await generateInvoicePdf({ name, gameName, amount, currency, date });

    // ponytail: Upload PDF directly to Cloudinary using base64 URI. 
    // We use resource_type: 'image' and format: 'pdf' so Cloudinary serves it inline (Content-Type: application/pdf) for direct viewing.
    const base64Pdf = `data:application/pdf;base64,${pdfBuffer.toString('base64')}`;
    const uploadResult = await cloudinary.uploader.upload(base64Pdf, {
      resource_type: 'image',
      format: 'pdf',
      folder: 'invoices',
      public_id: `invoice_${gameName.toLowerCase().replace(/\s+/g, '_')}_${Date.now()}`
    });

    const invoiceId = `NP-${Date.now().toString().slice(-6)}`;

    // ponytail: Send email with HTML content and PDF attachment
    await resend.emails.send({
      from: 'NexPlay <onboarding@resend.dev>',
      to: email,
      subject: `Invoice #${invoiceId} - ${gameName}`,
      html: invoiceTemplate({ name, gameName, amount, currency, date, pdfUrl: uploadResult.secure_url }),
      attachments: [
        {
          filename: `invoice_${gameName.toLowerCase().replace(/\s+/g, '_')}.pdf`,
          content: pdfBuffer,
        }
      ]
    });

    res.status(200).send({ 
      success: true, 
      pdfUrl: uploadResult.secure_url 
    });
  } catch (error) {
    console.error('Invoice Delivery Error:', error.message);
    res.status(500).send({ error: error.message });
  }
});

const PORT = process.env.PORT || 3000;
const server = app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully...');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully...');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});