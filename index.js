const express = require('express');
const quotes = require('./quotes.json');

const app = express();
const PORT = process.env.PORT || 8000;

app.get('/', (req, res) => {
  res.send("Welcome to the Quote API v2 baby 😎");
});

app.get('/quote', (req, res) => {
  const randomQuote = quotes[Math.floor(Math.random() * quotes.length)];
  res.json({ quote: randomQuote });
});

app.get('/quotes', (req, res) =>{
   res.json(quotes)
});

app.listen(PORT, () => {
  console.log('Server running at http://localhost:${PORT}');
});
