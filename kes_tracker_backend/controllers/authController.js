const User = require("../models/UserModel");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

exports.register = async (req, res) => {
  try {
    const { full_name, email, phone_number, password, confirm_password } =
      req.body;

    const kenyanPhoneRegex = /^(07|01)\d{8}$/;
    if (!kenyanPhoneRegex.test(phone_number)) {
      return res.status(400).json({
        error:
          "Invalid phone number. Must be a 10-digit Kenyan number starting with 07 or 01.",
      });
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res
        .status(400)
        .json({ error: "Please provide a valid email address." });
    }

    if (password !== confirm_password) {
      return res.status(400).json({ error: "Passwords do not match" });
    }

    const existingUser = await User.findByPhone(phone_number);
    if (existingUser) {
      return res
        .status(400)
        .json({ error: "This phone number is already registered" });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const membership_id = "KES-" + Math.floor(1000 + Math.random() * 9000);

    const newUser = await User.create({
      fullName: full_name,
      email: email,
      phone: phone_number,
      hashedPassword: hashedPassword,
      membershipId: membership_id,
      subscriptionStatus: "free",
    });

    const token = jwt.sign({ userId: newUser.id }, process.env.JWT_SECRET, {
      expiresIn: "7d",
    });

    res.status(201).json({
      message: "User registered successfully",
      token,
      user: newUser,
    });
  } catch (error) {
    console.error("Registration Error:", error);
    res
      .status(500)
      .json({ error: "Registration failed", details: error.message });
  }
};

exports.login = async (req, res) => {
  try {
    const { phone_number, password } = req.body;

    const user = await User.findByPhone(phone_number);
    if (!user) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, {
      expiresIn: "7d",
    });

    res.status(200).json({
      message: "Login successful",
      token,
      user: {
        id: user.id,
        full_name: user.full_name,
        email: user.email,
        phone_number: user.phone_number,
        membership_id: user.membership_id,
        subscription_status: user.subscription_status,
        free_pdf_count: user.free_pdf_count,
        created_at: user.created_at,
      },
    });
  } catch (error) {
    console.error("Login Error:", error);
    res.status(500).json({ error: "Login failed" });
  }
};

exports.forgotPassword = async (req, res) => {
  try {
    const { phone_number } = req.body;

    const user = await User.findByPhone(phone_number);
    if (!user) {
      return res
        .status(404)
        .json({ error: "Account not found with this number" });
    }

    const resetCode = Math.floor(100000 + Math.random() * 900000).toString();

    await User.saveResetCode(phone_number, resetCode);

    res.status(200).json({ message: "Reset code sent successfully" });
  } catch (error) {
    console.error("Forgot Password Error:", error);
    res.status(500).json({ error: "Error sending reset code" });
  }
};

// --- NEW: RESET PASSWORD LOGIC ---
exports.resetPassword = async (req, res) => {
  try {
    const { phone_number, reset_code, new_password } = req.body;

    // 1. Verify code and check expiry
    const isValid = await User.verifyResetCode(phone_number, reset_code);
    if (!isValid) {
      return res.status(400).json({ error: "Invalid or expired reset code" });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    await User.updatePassword(phone_number, hashedPassword);

    await User.clearResetCode(phone_number);

    res.status(200).json({ message: "Password updated successfully" });
  } catch (error) {
    console.error("Reset Password Error:", error);
    res.status(500).json({ error: "Error updating password" });
  }
};
