const db = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

exports.register = async (req, res) => {
    const { phone_number, password } = req.body;

    try {
        
        const [existingUser] = await db.query('SELECT * FROM users WHERE phone_number = ?', [phone_number]);
        if (existingUser.length > 0) {
            return res.status(400).json({ message: 'Phone number already registered' });
        }

        
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        await db.query(
            'INSERT INTO users (phone_number, password_hash) VALUES (?, ?)',
            [phone_number, hashedPassword]
        );

        res.status(201).json({ message: 'User created successfully! ✅' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error during registration' });
    }
};



exports.login = async (req, res) => {
    const { phone_number, password } = req.body;

    try {
        
        const [users] = await db.query('SELECT * FROM users WHERE phone_number = ?', [phone_number]);
        
        if (users.length === 0) {
            return res.status(401).json({ message: 'Invalid phone number or password' });
        }

        const user = users[0];

        
        const isMatch = await bcrypt.compare(password, user.password_hash);
        if (!isMatch) {
            return res.status(401).json({ message: 'Invalid phone number or password' });
        }

        
        const token = jwt.sign(
            { id: user.id, phone: user.phone_number },
            process.env.JWT_SECRET,
            { expiresIn: '7d' } 
        );

        res.status(200).json({
            message: 'Login successful! 👋',
            token,
            user: { id: user.id, phone: user.phone_number }
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error during login' });
    }
};