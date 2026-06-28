const invoiceTemplate = ({ name, gameName, amount, currency, date, pdfUrl }) => `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin:0;padding:0;background:#F3F4F6;font-family:'Segoe UI',Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#F3F4F6;padding:40px 0;">
    <tr>
      <td align="center">
        <table width="600" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08);">

          <tr>
            <td style="background:linear-gradient(135deg,#4F46E5,#7C3AED);padding:40px;text-align:center;">
              <h1 style="margin:0;color:#ffffff;font-size:28px;font-weight:700;letter-spacing:1px;">NexPlay</h1>
              <p style="margin:8px 0 0;color:#C4B5FD;font-size:14px;">Your Premium Gaming Hub</p>
            </td>
          </tr>

          <tr>
            <td align="center" style="padding:32px 40px 0;">
              <div style="display:inline-block;background:#ECFDF5;border:1px solid #6EE7B7;border-radius:20px;padding:8px 20px;">
                <span style="color:#065F46;font-size:14px;font-weight:600;">Payment Successful</span>
              </div>
            </td>
          </tr>

          <tr>
            <td style="padding:24px 40px 0;">
              <p style="margin:0;color:#111827;font-size:16px;">Hi <strong>${name}</strong>,</p>
              <p style="margin:12px 0 0;color:#6B7280;font-size:15px;line-height:1.6;">
                Thank you for your purchase! Your game is now unlocked and ready to play.
                Here's your invoice for the transaction.
              </p>
            </td>
          </tr>

          <tr>
            <td style="padding:24px 40px;">
              <table width="100%" cellpadding="0" cellspacing="0" style="background:#F9FAFB;border:1px solid #E5E7EB;border-radius:8px;overflow:hidden;">
                <tr style="background:#F3F4F6;">
                  <td style="padding:12px 20px;color:#6B7280;font-size:12px;font-weight:600;text-transform:uppercase;letter-spacing:0.5px;">Description</td>
                  <td style="padding:12px 20px;color:#6B7280;font-size:12px;font-weight:600;text-transform:uppercase;letter-spacing:0.5px;text-align:right;">Amount</td>
                </tr>
                <tr>
                  <td style="padding:16px 20px;border-top:1px solid #E5E7EB;">
                    <p style="margin:0;color:#111827;font-size:15px;font-weight:600;">${gameName}</p>
                    <p style="margin:4px 0 0;color:#9CA3AF;font-size:13px;">One-time purchase</p>
                  </td>
                  <td style="padding:16px 20px;border-top:1px solid #E5E7EB;text-align:right;">
                    <p style="margin:0;color:#111827;font-size:15px;font-weight:600;">${currency.toUpperCase()} ${(amount / 100).toFixed(2)}</p>
                  </td>
                </tr>
                <tr style="background:#F3F4F6;">
                  <td style="padding:12px 20px;border-top:1px solid #E5E7EB;">
                    <p style="margin:0;color:#111827;font-size:14px;font-weight:700;">Total</p>
                  </td>
                  <td style="padding:12px 20px;border-top:1px solid #E5E7EB;text-align:right;">
                    <p style="margin:0;color:#4F46E5;font-size:16px;font-weight:700;">${currency.toUpperCase()} ${(amount / 100).toFixed(2)}</p>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          ${pdfUrl ? `
          <!-- ponytail: Button to view/download PDF from Cloudinary -->
          <tr>
            <td align="center" style="padding:8px 40px 24px;">
              <a href="${pdfUrl}" target="_blank" style="display:inline-block;background:#4F46E5;color:#ffffff;font-size:14px;font-weight:600;text-decoration:none;padding:12px 28px;border-radius:8px;box-shadow:0 2px 4px rgba(79,70,229,0.2);">
                Download PDF Invoice
              </a>
            </td>
          </tr>
          ` : ''}

          <tr>
            <td style="padding:0 40px 16px; ">
              <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td style="color:#6B7280;font-size:13px;">Date</td>
                  <td style="color:#111827;font-size:13px;text-align:right;">${date}</td>
                </tr>
              </table>
            </td>
          </tr>

          <tr>
            <td style="background:#F9FAFB;border-top:1px solid #E5E7EB;padding:24px 40px;text-align:center;">
              <p style="margin:0;color:#9CA3AF;font-size:12px;">© 2026 NexPlay. All rights reserved.</p>
              <p style="margin:8px 0 0;color:#9CA3AF;font-size:12px;">This is an automated invoice. Please do not reply to this email.</p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
`;

module.exports = invoiceTemplate;