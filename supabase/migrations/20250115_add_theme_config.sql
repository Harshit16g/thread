-- Add theme_preference to profiles table
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS theme_preference text;

-- Create app_config table for global configuration
CREATE TABLE IF NOT EXISTS app_config (
  key text PRIMARY KEY,
  value text NOT NULL,
  is_active boolean DEFAULT true,
  start_at timestamptz,
  end_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable Row Level Security (RLS)
ALTER TABLE app_config ENABLE ROW LEVEL SECURITY;

-- Create policies for app_config
-- Allow read access to everyone (authenticated and anonymous)
CREATE POLICY "Allow public read access" ON app_config
  FOR SELECT USING (true);

-- Allow write access only to service_role (admin) - effectively read-only for clients
-- No insert/update/delete policies for authenticated/anon users

-- Insert default seasonal theme config (inactive by default)
INSERT INTO app_config (key, value, is_active)
VALUES ('seasonal_theme', 'halloween', false)
ON CONFLICT (key) DO NOTHING;
