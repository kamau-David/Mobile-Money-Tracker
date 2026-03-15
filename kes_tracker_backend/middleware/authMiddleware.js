const jwt = require("jsonwebtoken");
const User = require("../models/UserModel");

const protect = async (req, res, next) => {
  let token;

  // 1. Check if the token exists in the Headers
  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith("Bearer")
  ) {
    try {
      // Get token from string "Bearer <token>"
      token = req.headers.authorization.split(" ")[1];

      // 2. Verify token
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      // 3. Find user and attach to the request object
      // This ensures we have the latest subscription_status and free_pdf_count
      const user = await User.findById(decoded.userId);

      if (!user) {
        return res
          .status(401)
          .json({ error: "Not authorized, user not found" });
      }

      // Attach userId for general use
      req.user = decoded.userId;

      // Attach full user data for subscription checks
      req.user_data = user;

      next(); // Move to the controller
    } catch (error) {
      console.error("Auth Middleware Error:", error);
      return res.status(401).json({ error: "Not authorized, token failed" });
    }
  }

  // 4. If no token was found at all
  if (!token) {
    return res.status(401).json({ error: "Not authorized, no token" });
  }
};

module.exports = { protect };
