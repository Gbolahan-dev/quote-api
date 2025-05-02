// index.js
const express = require('express');
const quotes  = require('./quotes.json');

const app  = express();
const PORT = process.env.PORT || 8080;

// Normal welcome route
app.get('/', (req, res) => {
  res.send('Welcome to the Quote API v2 baby 😎');
});

// CRASH‑TEST route
app.get('/quote', (req, res) => {
  // Pick a random quote (or hard‑code “Boom!”)
  const randomQuote = quotes[Math.floor(Math.random() * quotes.length)];
  res.json({ quote: randomQuote });

  // Log and crash 5 s later
  console.error('💥 Simulated fatal error — container will exit in 5 s');
  setTimeout(() => process.exit(1), 5000);
});

app.listen(PORT, () => console.log(`✅ listening on ${PORT}`));

