-- Add status and visual_description to clinical_cases

ALTER TABLE clinical_cases
  ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'Draft',
  ADD COLUMN IF NOT EXISTS visual_description TEXT;

-- Update existing cases to Published
UPDATE clinical_cases SET status = 'Published'
WHERE id IN ('case_001', 'case_002', 'case_003', 'case_004', 'case_005');

-- Update visual descriptions for existing cases
UPDATE clinical_cases SET visual_description = 'Flexural erythema with small vesicles and excoriation marks on an ill-defined erythematous base.' WHERE id = 'case_001';
UPDATE clinical_cases SET visual_description = 'Well-demarcated erythematous plaques with thick silvery-white scale on extensor surfaces of the elbows.' WHERE id = 'case_002';
UPDATE clinical_cases SET visual_description = 'Bright red, dry and scaly patches on the cheeks of an infant with extensor surface involvement.' WHERE id = 'case_003';
UPDATE clinical_cases SET visual_description = 'Lichenified, hyperpigmented perioral skin with dry scaly patches and thickened texture around the mouth.' WHERE id = 'case_004';
