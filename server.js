const express = require('express');
const { Pool } = require('pg');

const app = express();

// Configuración de la conexión a PostgreSQL
const pool = new Pool({
  user: 'tu_usuario_postgres',
  host: 'localhost',
  database: 'tu_base_de_datos',
  password: 'tu_contraseña',
  port: 5432,
});

// Middleware para procesar datos JSON
app.use(express.json());

// Ruta para guardar leads
app.post('/api/prospectos', async (req, res) => {
  const { name, email, phone, message } = req.body;

  try {
    const result = await pool.query(
      'INSERT INTO leads_digitalpro (name, email, phone, message) VALUES ($1, $2, $3, $4) RETURNING id',
      [name, email, phone, message]
    );
    res.status(201).json({
      message: 'Datos guardados correctamente',
      leadId: result.rows[0].id
    });
  } catch (error) {
    console.error('Error al guardar el lead:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Iniciar servidor
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Servidor escuchando en http://localhost:${PORT}`);
});