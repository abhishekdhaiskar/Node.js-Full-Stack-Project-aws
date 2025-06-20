
require('dotenv').config();
const express = require('express');
const { Pool } = require('pg');
const app = express();
const pool = new Pool({
  host: process.env.DB_HOST,
  port: +process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
});
app.get('/api/hello', async (req, res) => {
  try {
    const r = await pool.query("SELECT 'Hello from Postgres!' as msg");
    res.json({ message: r.rows[0].msg });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: 'db error' });
  }
});
const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Listening on ${port}`));
