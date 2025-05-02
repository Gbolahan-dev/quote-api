const express = require('express');
const quotes = require('./quotes.json');

const app = express();
const PORT = process.env.PORT || 8080;

// Home
app.get('/', (req, res) => {
  res.send('Welcome to the Quote API v2 baby 😎');
});

// 🔥 Crash‑on‑request demo
app.get('/quote', (_, res) => {
  res.json({ quote: 'Boom! Simulated crash in 5 s' });
  setTimeout(() => {
    console.error('💥  Simulated fatal error — exiting');
    process.exit(1);           // kills the container
  }, 5000);
});

// All quotes
app.get('/quotes', (_, res) => res.json(quotes));

// Start server
app.listen(PORT, () => console.log(`listening on ${PORT}`));

