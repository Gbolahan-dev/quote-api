const express = require('express');
const quotes  = require('./quotes.json');

const app  = express();
const PORT = process.env.PORT || 8080;

/* ---------- routes ---------- */

// simple welcome
app.get('/', (_, res) => {
  res.send('Welcome to the Quote API v2 baby 😎');
});

/* crash‑after‑5‑seconds demo  */
app.get('/quote', (_, res) => {
  res.json({ quote: 'Boom! Simulated crash in 5 s' });
  setTimeout(() => {
    console.error('💥  Simulated fatal error — exiting');
    process.exit(1);           // ← kills this container only
  }, 5000);
});

/* list all quotes */
app.get('/quotes', (_, res) => res.json(quotes));

/* ---------- start server ---------- */
app.listen(PORT, () => console.log(`listening on ${PORT}`));

