-- ============================================================
-- DIGITALPRO OS — Supabase Database Schema
-- ============================================================
-- Ejecuta este archivo en el SQL Editor de tu proyecto Supabase
-- (https://app.supabase.com → SQL Editor → New Query → Paste → Run)
-- ============================================================

-- ==================== CLIENTS ====================
CREATE TABLE IF NOT EXISTS clients (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  business_name TEXT NOT NULL,
  owner_name TEXT,
  email TEXT,
  whatsapp TEXT,
  sector TEXT,
  region TEXT,
  service_type TEXT CHECK (service_type IN ('subscription','one_time')) DEFAULT 'subscription',
  plan_name TEXT,
  plan_price NUMERIC(10,2) DEFAULT 0,
  currency TEXT DEFAULT 'USD',
  status TEXT CHECK (status IN ('active','paused','suspended','completed')) DEFAULT 'active',
  payment_status TEXT CHECK (payment_status IN ('green','yellow','red')) DEFAULT 'green',
  next_payment_date DATE,
  total_paid NUMERIC(10,2) DEFAULT 0,
  notes TEXT,
  start_date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==================== PAYMENTS ====================
CREATE TABLE IF NOT EXISTS payments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
  amount NUMERIC(10,2) NOT NULL,
  payment_date DATE DEFAULT CURRENT_DATE,
  method TEXT DEFAULT 'transfer',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==================== SITE SETTINGS (key-value) ====================
CREATE TABLE IF NOT EXISTS site_settings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  key TEXT UNIQUE NOT NULL,
  value TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==================== ANALYTICS EVENTS ====================
CREATE TABLE IF NOT EXISTS analytics_events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  event_type TEXT NOT NULL,
  event_data JSONB DEFAULT '{}',
  page TEXT,
  session_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==================== INDEXES ====================
CREATE INDEX IF NOT EXISTS idx_clients_status ON clients(status);
CREATE INDEX IF NOT EXISTS idx_clients_payment_status ON clients(payment_status);
CREATE INDEX IF NOT EXISTS idx_clients_region ON clients(region);
CREATE INDEX IF NOT EXISTS idx_payments_client ON payments(client_id);
CREATE INDEX IF NOT EXISTS idx_payments_date ON payments(payment_date);
CREATE INDEX IF NOT EXISTS idx_analytics_type ON analytics_events(event_type);
CREATE INDEX IF NOT EXISTS idx_analytics_created ON analytics_events(created_at);
CREATE INDEX IF NOT EXISTS idx_analytics_session ON analytics_events(session_id);

-- ==================== ROW LEVEL SECURITY ====================
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE site_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;

-- Permissive policies (admin-only access via anon key)
CREATE POLICY "anon_all_clients" ON clients FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all_payments" ON payments FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all_settings" ON site_settings FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all_analytics" ON analytics_events FOR ALL TO anon USING (true) WITH CHECK (true);

-- ==================== DEFAULT SETTINGS ====================
INSERT INTO site_settings (key, value) VALUES
  ('maintenance_mode', 'false'),
  ('seo_title', 'DigitalPro | Web Design & AI Solutions in Austin, TX'),
  ('seo_description', 'DigitalPro: agencia digital premium en Austin, TX. Diseño web, automatización IA, SaaS y auditoría digital.'),
  ('seo_keywords', 'web design austin, ai solutions texas, digital agency austin tx, saas development')
ON CONFLICT (key) DO NOTHING;

-- ==================== AUTO-UPDATE TRIGGER ====================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER clients_updated_at
  BEFORE UPDATE ON clients
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER site_settings_updated_at
  BEFORE UPDATE ON site_settings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
