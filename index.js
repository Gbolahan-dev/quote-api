app.get('/quote', (req, res) => {
  console.error("💥 Simulated fatal error — container will exit");
  process.exit(1);                 // ← kills the container
});

