require ('dotenv').config();
const db = require('./config/db'); 
const express = require('express');

const authRoutes = require('./routes/authRoutes');

const app = express();

app.use(express.json());
app.use('/api/auth', authRoutes);


const PORT = process.env.PORT || 5000;

app.get('/', (req, res) => {
  res.send('KES Tracker Server is LIVE! 🚀');
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});