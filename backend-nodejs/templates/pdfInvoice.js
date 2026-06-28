const PDFDocument = require('pdfkit');

/**
 * Generates a PDF invoice as a buffer.
 * 
 * ponytail: Pure JS PDF generation without dependencies on browser/chromium engines.
 */
const generateInvoicePdf = ({ name, gameName, amount, currency, date }) => {
  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({ margin: 50, size: 'A4' });
    const chunks = [];

    doc.on('data', (chunk) => chunks.push(chunk));
    doc.on('end', () => resolve(Buffer.concat(chunks)));
    doc.on('error', (err) => reject(err));

    // Header background (purple)
    doc.rect(0, 0, 595.28, 100).fill('#4F46E5');
    
    // Header texts
    doc.fillColor('#ffffff').fontSize(24).font('Helvetica-Bold').text('NexPlay', 50, 30);
    doc.fillColor('#C4B5FD').fontSize(12).font('Helvetica').text('Your Premium Gaming Hub', 50, 60);

    // Invoice Title
    doc.fillColor('#111827').fontSize(18).font('Helvetica-Bold').text('INVOICE', 50, 130);

    // Invoice Date metadata
    doc.fontSize(10).font('Helvetica-Bold').fillColor('#6B7280');
    doc.text('Date:', 50, 160);
    doc.font('Helvetica').fillColor('#111827').text(date, 90, 160);

    // Customer Salutation
    doc.fontSize(12).font('Helvetica').text('Hi ', 50, 200, { continued: true });
    doc.font('Helvetica-Bold').text(name, { continued: true });
    doc.font('Helvetica').text(',');
    doc.fontSize(11).fillColor('#6B7280').text('Thank you for your purchase! Here is your transaction invoice:', 50, 220);

    // Table Header
    doc.rect(50, 260, 495.28, 20).fill('#F3F4F6');
    doc.fillColor('#6B7280').fontSize(9).font('Helvetica-Bold').text('DESCRIPTION', 60, 266);
    doc.text('AMOUNT', 470, 266, { width: 70, align: 'right' });

    // Table Row
    doc.fillColor('#111827').fontSize(11).font('Helvetica-Bold').text(gameName, 60, 295);
    doc.fontSize(9).font('Helvetica').fillColor('#9CA3AF').text('One-time purchase', 60, 310);
    
    const formattedAmount = `${currency.toUpperCase()} ${(amount / 100).toFixed(2)}`;
    doc.fillColor('#111827').fontSize(11).font('Helvetica-Bold').text(formattedAmount, 470, 295, { width: 70, align: 'right' });

    // Divider line
    doc.moveTo(50, 335).lineTo(545.28, 335).strokeColor('#E5E7EB').lineWidth(1).stroke();

    // Total Row
    doc.fillColor('#111827').fontSize(12).font('Helvetica-Bold').text('Total', 60, 355);
    doc.fillColor('#4F46E5').fontSize(14).font('Helvetica-Bold').text(formattedAmount, 470, 355, { width: 70, align: 'right' });

    // Footer background and texts
    doc.rect(0, 742, 595.28, 100).fill('#F9FAFB');
    doc.fillColor('#9CA3AF').fontSize(9).font('Helvetica').text('© 2026 NexPlay. All rights reserved.', 50, 765, { align: 'center', width: 495.28 });
    doc.text('This is an automated invoice. Thank you for gaming with us!', 50, 780, { align: 'center', width: 495.28 });

    doc.end();
  });
};

module.exports = generateInvoicePdf;
