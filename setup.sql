-- ══════════════════════════════════════════════════════════
-- PAQARINKAMA — Setup Supabase
-- Pega este SQL en: Supabase → SQL Editor → New query → Run
-- ══════════════════════════════════════════════════════════

-- 1. TABLA DE TEXTOS (clave-valor)
CREATE TABLE IF NOT EXISTS content (
  key   TEXT PRIMARY KEY,
  value TEXT
);

-- 2. TABLA DE ACTIVIDADES
CREATE TABLE IF NOT EXISTS activities (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title       TEXT NOT NULL,
  cat         TEXT DEFAULT 'taller',
  date        TEXT,
  author      TEXT,
  description TEXT,
  is_orig     BOOLEAN DEFAULT false,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 3. TABLA DE GALERÍA
CREATE TABLE IF NOT EXISTS gallery (
  slot_index  INTEGER PRIMARY KEY,
  image_url   TEXT,
  label       TEXT DEFAULT ''
);

-- Inicializar los 6 slots de la galería
INSERT INTO gallery (slot_index, label) VALUES
  (0, '📢 Lectura en voz alta'),
  (1, '📚 Biblioteca Ttío'),
  (2, '👩‍🏫 Taller docentes'),
  (3, '📖 Feria del libro'),
  (4, '🌳 Lectura al aire libre'),
  (5, '🧒 Niños lectores')
ON CONFLICT (slot_index) DO NOTHING;

-- Insertar actividades originales
INSERT INTO activities (title, cat, date, author, description, is_orig) VALUES
  ('Primera sesión de lectura en voz alta en el colegio San Martín','taller','Mayo 2025','Lucía Quispe, voluntaria','Comenzamos el año con mucha emoción. Los niños de 2.° grado escucharon por primera vez "El pequeño príncipe" leído en voz alta. Las preguntas que surgieron nos dejaron sin palabras.',true),
  ('Inauguramos nuestra primera biblioteca de barrio','biblioteca','Abril 2025','Rodrigo Mamani','Con 80 libros donados por familias del distrito, abrimos un pequeño rincón lector en el comedor comunitario de Ttío.',true),
  ('Taller de mediación lectora para maestros de inicial','docentes','Marzo 2025','Sofía Arredondo','Doce docentes compartieron estrategias para leer con niños pequeños. Fue un encuentro cargado de experiencias y muchas risas.',true),
  ('Feria del libro usado: intercambio entre vecinos','evento','Feb 2025','María Ccoa','Más de 40 personas trajeron libros que ya no usaban y se llevaron otros. Un sábado de puro intercambio y conversación.',true),
  ('Cuentos de verano: lectura bajo los árboles','taller','Enero 2025','Javier Huanca','Aprovechamos el buen clima para hacer nuestra primera sesión al aire libre en el parque de Wanchaq. Vinieron familias enteras.',true)
ON CONFLICT DO NOTHING;

-- ──────────────────────────────────────────
-- 4. SEGURIDAD (Row Level Security)
-- ──────────────────────────────────────────
ALTER TABLE content    ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE gallery    ENABLE ROW LEVEL SECURITY;

-- Cualquiera puede LEER (sitio público)
CREATE POLICY "Public read content"    ON content    FOR SELECT TO anon USING (true);
CREATE POLICY "Public read activities" ON activities FOR SELECT TO anon USING (true);
CREATE POLICY "Public read gallery"    ON gallery    FOR SELECT TO anon USING (true);

-- Solo el equipo autenticado puede ESCRIBIR
CREATE POLICY "Admin write content"    ON content    FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Admin write activities" ON activities FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Admin write gallery"    ON gallery    FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ──────────────────────────────────────────
-- 5. STORAGE BUCKET para imágenes
-- ──────────────────────────────────────────
-- Hazlo desde el dashboard: Storage → New bucket → nombre: "gallery" → Public: ON
-- Luego crea estas políticas en Storage → gallery → Policies:
--
--   SELECT (lectura pública):
--     Nombre: "Public gallery read"
--     Roles: anon, authenticated
--     Policy: true
--
--   INSERT/UPDATE/DELETE (solo admin):
--     Nombre: "Admin gallery write"
--     Roles: authenticated
--     Policy: true
