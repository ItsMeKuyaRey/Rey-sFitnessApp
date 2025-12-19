/**
 * Firebase Functions Setup
 */

const {setGlobalOptions} = require("firebase-functions");
const functions = require("firebase-functions");
const nodemailer = require("nodemailer");

// Gmail SMTP (use App Password if 2FA is active)
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "your.email@gmail.com", // your email
    pass: "your-app-password", // app password, NOT your main password
  },
});

exports.sendTrainerInvite = functions.https.onCall(async (data) => {
  const {name, email} = data;

  const mailOptions = {
    from: "\"Fitness App\" <your.email@gmail.com>",
    to: email,
    subject: "Trainer Invitation",
    text:
      `Hello ${name},\n\n` +
      "You have been invited as a trainer on our Fitness App!\n" +
      "Please sign up to get started.",
  };

  try {
    await transporter.sendMail(mailOptions);
    return {success: true};
  } catch (error) {
    console.error("Error sending email:", error);
    return {success: false, error: error.message};
  }
});

setGlobalOptions({maxInstances: 10});
