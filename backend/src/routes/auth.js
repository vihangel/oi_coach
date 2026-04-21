const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

const router = express.Router();

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function generateTokens(user) {
  const payload = { userId: user._id, email: user.email };

  const accessToken = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '15m' });
  const refreshToken = jwt.sign(payload, process.env.JWT_REFRESH_SECRET, { expiresIn: '7d' });

  return { accessToken, refreshToken };
}

// POST /api/auth/register
router.post('/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;

    // Validation
    if (!name || !name.trim()) {
      return res.status(400).json({ message: 'Nome é obrigatório' });
    }

    if (!email || !EMAIL_REGEX.test(email)) {
      return res.status(400).json({ message: 'Email inválido' });
    }

    if (!password || password.length < 8) {
      return res.status(400).json({ message: 'A senha deve ter no mínimo 8 caracteres' });
    }

    // Check duplicate email
    const existingUser = await User.findOne({ email: email.toLowerCase().trim() });
    if (existingUser) {
      return res.status(409).json({ message: 'Email já cadastrado' });
    }

    // Create user (password hashed by pre-save hook)
    const user = await User.create({ name: name.trim(), email, password });

    const tokens = generateTokens(user);
    res.status(201).json(tokens);
  } catch (err) {
    res.status(500).json({ message: 'Erro interno do servidor' });
  }
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email: email?.toLowerCase().trim() });
    if (!user) {
      return res.status(401).json({ message: 'Credenciais inválidas' });
    }

    const isMatch = await user.comparePassword(password || '');
    if (!isMatch) {
      return res.status(401).json({ message: 'Credenciais inválidas' });
    }

    const tokens = generateTokens(user);
    res.json(tokens);
  } catch (err) {
    res.status(500).json({ message: 'Erro interno do servidor' });
  }
});

// POST /api/auth/refresh
router.post('/refresh', async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(401).json({ message: 'Token inválido' });
    }

    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
    const user = await User.findById(decoded.userId);

    if (!user) {
      return res.status(401).json({ message: 'Token inválido' });
    }

    const tokens = generateTokens(user);
    res.json(tokens);
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ message: 'Sessão expirada, faça login novamente' });
    }
    return res.status(401).json({ message: 'Token inválido' });
  }
});

module.exports = router;
