const User = require("../models/UserModel");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

exports.register = async (req, res) => {
  try {
    const { full_name, email, phone_number, password, confirm_password } =
      req.body;

    // 1. FORMAT VALIDATION: Check if it's a valid Kenyan Phone Number (10 digits)
    const kenyanPhoneRegex = /^(07|01)\d{8}$/;
    if (!kenyanPhoneRegex.test(phone_number)) {
      return res.status(400).json({
        error:
          "Invalid phone number. Must be a 10-digit Kenyan number starting with 07 or 01.",
      });
    }

    // 2. EMAIL VALIDATION
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res
        .status(400)
        .json({ error: "Please provide a valid email address." });
    }

    // 3. PASSWORD VALIDATION: Ensure passwords match
    if (password !== confirm_password) {
      return res.status(400).json({ error: "Passwords do not match" });
    }

    // 4. CHECK EXISTENCE: Prevent duplicate accounts
    const existingUser = await User.findByPhone(phone_number);
    if (existingUser) {
      return res
        .status(400)
        .json({ error: "This phone number is already registered" });
    }

    // 5. SECURITY: Hash the password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // 6. SAVE: Create the user in the database
    const newUser = await User.create({
      fullName: full_name,
      email: email,
      phone: phone_number,
      hashedPassword: hashedPassword,
    });

    res.status(201).json({
      message: "User registered successfully",
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

    // 1. Find user by their Phone number
    const user = await User.findByPhone(phone_number);
    if (!user) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    // 2. Compare passwords
    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    // 3. Generate a JWT Token (Valid for 7 days)
    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, {
      expiresIn: "7d",
    });

    res.status(200).json({
      message: "Login successful",
      token,
      user: {
        id: user.id,
        full_name: user.full_name,
        phone_number: user.phone_number,
      },
    });
  } catch (error) {
    console.error("Login Error:", error);
    res.status(500).json({ error: "Login failed" });
  }
};
