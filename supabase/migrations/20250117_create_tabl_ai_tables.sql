-- TabL Database Migration Script
-- Creates simple, workable schemas for the AI modules.

-- 1. LocalBook: Finance Management Table
CREATE TABLE IF NOT EXISTS public.localbook_transactions (
    id SERIAL PRIMARY KEY,
    user_id UUID,
    amount NUMERIC NOT NULL,
    type TEXT CHECK (type IN ('income', 'expense')) NOT NULL,
    category TEXT NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- RLS for LocalBook (allowing all for simple testing, or restricted to user_id if authenticated)
ALTER TABLE public.localbook_transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow anonymous operations on localbook_transactions" ON public.localbook_transactions FOR ALL USING (true) WITH CHECK (true);


-- 2. KrishiBot: Agricultural Advisory Table
CREATE TABLE IF NOT EXISTS public.krishibot_advice (
    id SERIAL PRIMARY KEY,
    crop_name TEXT NOT NULL,
    topic TEXT NOT NULL, -- e.g., 'fertilizer', 'pest', 'soil', 'season'
    content TEXT NOT NULL,
    recommended_season TEXT
);

ALTER TABLE public.krishibot_advice ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow anonymous select on krishibot_advice" ON public.krishibot_advice FOR SELECT USING (true);


-- 3. MedGuide: Healthcare Assistance Table
CREATE TABLE IF NOT EXISTS public.medguide_conditions (
    id SERIAL PRIMARY KEY,
    symptoms TEXT NOT NULL,
    title TEXT NOT NULL,
    first_aid TEXT NOT NULL,
    description TEXT
);

ALTER TABLE public.medguide_conditions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow anonymous select on medguide_conditions" ON public.medguide_conditions FOR SELECT USING (true);


-- 4. TutorBot: Educational Support Table
CREATE TABLE IF NOT EXISTS public.tutorbot_qa (
    id SERIAL PRIMARY KEY,
    subject TEXT NOT NULL,
    topic TEXT NOT NULL,
    question TEXT NOT NULL,
    answer TEXT NOT NULL
);

ALTER TABLE public.tutorbot_qa ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow anonymous select on tutorbot_qa" ON public.tutorbot_qa FOR SELECT USING (true);


-- 5. SalesBuddy: Business Inventory Table
CREATE TABLE IF NOT EXISTS public.salesbuddy_inventory (
    id SERIAL PRIMARY KEY,
    user_id UUID,
    item_name TEXT UNIQUE NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    price_per_unit NUMERIC NOT NULL DEFAULT 0
);

ALTER TABLE public.salesbuddy_inventory ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow anonymous operations on salesbuddy_inventory" ON public.salesbuddy_inventory FOR ALL USING (true) WITH CHECK (true);


-- 6. SalesBuddy: Business Sales Table
CREATE TABLE IF NOT EXISTS public.salesbuddy_sales (
    id SERIAL PRIMARY KEY,
    user_id UUID,
    item_name TEXT NOT NULL,
    quantity_sold INT NOT NULL,
    total_amount NUMERIC NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.salesbuddy_sales ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow anonymous operations on salesbuddy_sales" ON public.salesbuddy_sales FOR ALL USING (true) WITH CHECK (true);


-- ==========================================
-- Insert Seed Data for Working Demonstrations
-- ==========================================

-- Seed KrishiBot Advice
INSERT INTO public.krishibot_advice (crop_name, topic, content, recommended_season) VALUES
('wheat', 'fertilizer', 'Apply Urea (120kg/ha) and Single Super Phosphate (SSP) (50kg/ha). First application at sowing, second at crown root initiation (21 days).', 'rabi'),
('wheat', 'pest', 'For Leaf Rust or Stripe Rust, spray Propiconazole 25 EC @ 0.1% or Tebucanozole 250 EC @ 0.05% immediately upon seeing symptoms.', 'rabi'),
('wheat', 'irrigation', 'Wheat requires 5-6 critical irrigations. Critical stages: Crown Root Initiation (21 DAS), Tillering (40 DAS), Late Jointing (60 DAS), Flowering (80 DAS), Milking (100 DAS).', 'rabi'),
('rice', 'soil', 'Requires clay or clayey-loam soils which can retain water for long durations. Optimum soil pH is 5.5 to 6.5.', 'kharif'),
('rice', 'pest', 'For Stem Borer, use Cartap Hydrochloride 4G @ 25 kg/ha or spray Chlorantraniliprole 18.5 SC @ 150 ml/ha.', 'kharif'),
('maize', 'fertilizer', 'Apply Nitrogen, Phosphorus, and Potassium in 120:60:40 ratio. Apply full P & K at planting, and Nitrogen in three equal splits.', 'kharif'),
('cotton', 'pest', 'For Pink Bollworm, install pheromone traps @ 5 per hectare and spray Neem oil (1% EC) or Emamectin Benzoate 5 SG @ 250 g/ha.', 'kharif');

-- Seed MedGuide Medical Information
INSERT INTO public.medguide_conditions (symptoms, title, first_aid, description) VALUES
('burn, heat, red skin', 'Minor Heat Burns', '1. Cool the burn immediately with cool running tap water for 10-20 minutes. Do NOT use ice.\n2. Remove any tight jewelry or clothing before swelling begins.\n3. Cover with a sterile, non-stick bandage.\n4. Apply aloe vera gel. Do NOT break blisters.', 'First and second-degree burns affecting only the outer layers of the skin, causing redness, minor swelling, and pain.'),
('cut, bleeding, wound', 'Cuts and Minor Wounds', '1. Clean the wound by gently rinsing it with clean water.\n2. Apply direct pressure using a clean cloth or sterile dressing to stop bleeding.\n3. Elevate the injured area if possible.\n4. Apply an antibacterial ointment once bleeding stops, and cover with a sterile bandage.', 'Surface breaks in the skin that cause light to moderate external bleeding. Major cuts may require stitches.'),
('fracture, bone break, swelling', 'Sprains and Fractures', '1. Keep the injured limb completely still and supported. Do NOT attempt to realign a bone.\n2. Apply the R.I.C.E method: Rest, Ice (wrapped in a cloth), Compression bandage, and Elevation.\n3. Keep the patient comfortable and seek immediate professional medical attention.', 'Injuries to ligaments (sprains) or complete/partial breaks in a bone (fractures), causing severe pain, swelling, and inability to bear weight.'),
('dehydration, dizziness, heat stroke', 'Heat Exhaustion and Dehydration', '1. Move the person to a cool, shaded, or air-conditioned area immediately.\n2. Have them lie down and elevate their legs slightly.\n3. Loosen tight clothing.\n4. Give cool water, oral rehydration solutions (ORS), or sports drinks. Do NOT give caffeine or alcohol.', 'A condition caused by excessive exposure to high temperatures and dehydration, resulting in dizziness, heavy sweating, a rapid pulse, and muscle cramps.');

-- Seed TutorBot Q&A
INSERT INTO public.tutorbot_qa (subject, topic, question, answer) VALUES
('science', 'photosynthesis', 'What is photosynthesis?', 'Photosynthesis is the biological process by which green plants, algae, and some bacteria convert light energy (usually from the Sun) into chemical energy in the form of glucose. The overall chemical equation is:\n\n6CO₂ + 6H₂O + light energy ➔ C₆H₁₂O₆ + 6O₂\n\nIt takes place inside specialized cell organelles called chloroplasts, which contain chlorophyll—a green pigment that absorbs light energy.'),
('science', 'water cycle', 'Explain the water cycle.', 'The water cycle (or hydrological cycle) is the continuous movement of water within the Earth and atmosphere. It consists of four main stages:\n\n1. **Evaporation**: Heat from the Sun warms water bodies, turning liquid water into water vapor that rises.\n2. **Condensation**: The vapor cools as it rises and turns back into liquid droplets, forming clouds.\n3. **Precipitation**: Water falls from clouds as rain, snow, sleet, or hail.\n4. **Collection**: Precipitated water collects in oceans, lakes, and ground aquifers, starting the process over.'),
('mathematics', 'quadratics', 'What is the quadratic formula?', 'The quadratic formula is used to find the roots (solutions) of any quadratic equation of the form: ax² + bx + c = 0.\n\nThe formula is:\n\nx = (-b ± √(b² - 4ac)) / (2a)\n\nHere:\n- `a`, `b`, and `c` are real number coefficients.\n- The term `b² - 4ac` is called the **discriminant**. If it is positive, there are 2 real roots. If zero, there is 1 real root. If negative, there are 2 complex roots.'),
('history', 'indus valley', 'What was the Indus Valley Civilization?', 'The Indus Valley Civilization (IVC) was a Bronze Age civilization in the northwestern regions of South Asia, lasting from 3300 BCE to 1300 BCE. Key features include:\n- **Advanced Urban Planning**: Highly engineered grid systems, drainage systems, and multi-story brick homes (e.g., Harappa and Mohenjo-daro).\n- **Economy**: Heavily reliant on agriculture, metal crafts, and long-distance trade with Mesopotamia.\n- **Peaceful Society**: Very few weapons have been discovered, suggesting an exceptionally peaceful, trade-oriented societal structure.');

-- Seed SalesBuddy Inventory
INSERT INTO public.salesbuddy_inventory (item_name, stock_quantity, price_per_unit) VALUES
('rice bag', 150, 850.00),
('wheat bag', 120, 720.00),
('organic fertilizer', 45, 350.00),
('pesticide spray', 30, 220.00),
('hybrid seeds packet', 80, 180.00);

-- Seed SalesBuddy Sales
INSERT INTO public.salesbuddy_sales (item_name, quantity_sold, total_amount) VALUES
('rice bag', 12, 10200.00),
('wheat bag', 8, 5760.00),
('organic fertilizer', 10, 3500.00);

-- Seed LocalBook Transactions
INSERT INTO public.localbook_transactions (amount, type, category, notes) VALUES
(25000.00, 'income', 'crop sale', 'Sold 30 bags of wheat harvest at the local market.'),
(4500.00, 'expense', 'seeds purchase', 'Bought high-yield hybrid cotton seeds.'),
(12000.00, 'income', 'milk sales', 'Weekly earnings from dairy milk distribution.'),
(3200.00, 'expense', 'diesel fertilizer', 'Purchased tractor fuel and organic fertilizer.');
