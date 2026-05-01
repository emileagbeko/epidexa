-- Image bank: clinical reference images tagged with Fitzpatrick skin type

CREATE TABLE IF NOT EXISTS clinical_images (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  image_url   TEXT NOT NULL,
  condition   TEXT NOT NULL,
  fitzpatrick TEXT NOT NULL CHECK (fitzpatrick IN ('I','II','III','IV','V','VI')),
  description TEXT,
  tags        TEXT[] NOT NULL DEFAULT '{}',
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- Link clinical_cases to the image bank
ALTER TABLE clinical_cases
  ADD COLUMN IF NOT EXISTS fitzpatrick_type TEXT,
  ADD COLUMN IF NOT EXISTS image_bank_id UUID REFERENCES clinical_images(id);
