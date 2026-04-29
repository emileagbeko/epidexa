-- Initialize clinical knowledge and cases tables

-- 1. Table for clinical knowledge (RAG / AI Reference)
CREATE TABLE IF NOT EXISTS clinical_knowledge (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    topic TEXT NOT NULL UNIQUE,
    definition TEXT,
    clinical_features JSONB,
    distribution JSONB,
    investigations TEXT,
    management JSONB,
    complications JSONB,
    differential_diagnosis JSONB,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Table for clinical cases
CREATE TABLE IF NOT EXISTS clinical_cases (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    difficulty TEXT NOT NULL,
    category TEXT NOT NULL,
    patient_presentation TEXT NOT NULL,
    additional_history TEXT,
    image_path TEXT,
    observation_options JSONB NOT NULL,
    diagnosis_options JSONB NOT NULL,
    next_step_options JSONB NOT NULL,
    feedback JSONB NOT NULL,
    concept_tags TEXT[] NOT NULL,
    specialty_note TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Insert Atopic Dermatitis Knowledge
INSERT INTO clinical_knowledge (
    topic, 
    definition, 
    clinical_features, 
    distribution, 
    investigations, 
    management, 
    complications, 
    differential_diagnosis
) VALUES (
    'Atopic Dermatitis (Eczema)',
    'Chronic, relapsing inflammatory skin condition associated with impaired skin barrier function and atopy (asthma, hay fever, food allergy common).',
    '[
        "Pruritus (itching) - key symptom",
        "Dry skin (xerosis)",
        "Erythematous / inflamed patches",
        "Papules",
        "Excoriations from scratching",
        "Oozing / crusting in acute flares",
        "Lichenification / thickened skin in chronic disease",
        "Fissuring / cracking"
    ]',
    '{
        "Infants": "Face, scalp, extensor surfaces",
        "Children/Adults": "Flexures (antecubital/popliteal fossae), wrists, neck, hands, eyelids"
    }',
    'Usually clinical diagnosis. No routine tests needed. Consider skin swab if infection suspected.',
    '[
        "Regular emollients (mainstay)",
        "Soap substitutes / avoid irritants",
        "Topical corticosteroids for flares",
        "Topical calcineurin inhibitors in some cases"
    ]',
    '[
        "Secondary bacterial infection (impetigo)",
        "Eczema herpeticum",
        "Lichenification",
        "Pigment change / scarring"
    ]',
    '["Contact dermatitis", "Seborrhoeic dermatitis", "Psoriasis", "Scabies", "Tinea infection"]'
) ON CONFLICT (topic) DO NOTHING;

INSERT INTO clinical_cases (
    id, title, difficulty, category, patient_presentation, additional_history,
    image_path, observation_options, diagnosis_options, next_step_options,
    feedback, concept_tags
) VALUES (
    'case_001',
    'Itchy rash on forearm',
    'beginner',
    'inflammatory',
    'A 26-year-old nurse presents with a 5-day history of an itchy, erythematous rash on the flexural surface of the right forearm.',
    'No known drug allergies. No personal or family history of atopy.',
    'assets/images/case_001.png',
    '[...]',
    '[...]',
    '[...]',
    '{...}',
    ARRAY['contact-dermatitis', 'inflammatory']
), (
    'case_002',
    'Scaly plaques on elbows',
    'beginner',
    'inflammatory',
    'A 34-year-old accountant presents with a 3-month history of thickened, scaly patches on both elbows and the lower back.',
    'No known drug allergies. Non-smoker. Reports recent work-related stress.',
    'assets/images/case_002.png',
    '[...]',
    '[...]',
    '[...]',
    '{...}',
    ARRAY['psoriasis', 'inflammatory']
), (
    'case_003',
    'Infant with itchy cheeks',
    'beginner',
    'inflammatory',
    'A 9-month-old girl is brought to the GP with an itchy rash that has developed over the past few weeks. Her father reports she is often restless and trying to scratch her face.',
    'Normal growth and development. Father has a history of itchy skin rashes since childhood. No known allergies.',
    'assets/images/case_003.png',
    '[
        {"id": "o3_1", "label": "Erythema on cheeks", "isCorrect": true},
        {"id": "o3_2", "label": "Dry skin", "isCorrect": true},
        {"id": "o3_3", "label": "Extensor surface involvement", "isCorrect": true},
        {"id": "o3_4", "label": "Pearly umbilicated papules", "isCorrect": false}
    ]',
    '[
        {"id": "d3_1", "label": "Atopic eczema", "isCorrect": true},
        {"id": "d3_2", "label": "Seborrhoeic dermatitis", "isCorrect": false},
        {"id": "d3_3", "label": "Contact dermatitis", "isCorrect": false},
        {"id": "d3_4", "label": "Psoriasis", "isCorrect": false}
    ]',
    '[
        {
            "id": "n3_1", 
            "label": "Prescribe regular emollients and soap substitutes", 
            "isCorrect": true,
            "rationale": "Emollients are the mainstay of treatment for atopic eczema to restore the skin barrier."
        },
        {
            "id": "n3_2", 
            "label": "Prescribe oral antifungal", 
            "isCorrect": false,
            "rationale": "Not indicated as there is no evidence of fungal infection."
        }
    ]',
    '{
        "correctDiagnosis": "Atopic Eczema",
        "explanation": "Atopic eczema in infants typically presents with a red, dry, itchy rash on the face (cheeks) and extensor surfaces of the limbs. The positive family history and classic distribution support the diagnosis.",
        "keyVisualCues": ["Facial erythema", "Extensor involvement", "Dry, scaly patches"],
        "differentialNote": "Seborrhoeic dermatitis in infants (cradle cap) usually affects the scalp and flexures, and is typically not as itchy as atopic eczema."
    }',
    ARRAY['eczema', 'pediatrics', 'inflammatory', 'emollients']
), (
    'case_004',
    'Perioral rash in a toddler',
    'intermediate',
    'inflammatory',
    'A 4-year-old boy presents with a persistent rash around his mouth and cheeks. The skin appears thickened and darker than the surrounding areas.',
    'Chronic history of dry skin. Occasional flares of itching. No systemic symptoms.',
    'assets/images/case_004.png',
    '[
        {"id": "o4_1", "label": "Lichenification", "isCorrect": true},
        {"id": "o4_2", "label": "Hyperpigmentation", "isCorrect": true},
        {"id": "o4_3", "label": "Dry, scaly skin", "isCorrect": true},
        {"id": "o4_4", "label": "Punched-out erosions", "isCorrect": false}
    ]',
    '[
        {"id": "d4_1", "label": "Atopic Dermatitis", "isCorrect": true},
        {"id": "d4_2", "label": "Molluscum contagiosum", "isCorrect": false},
        {"id": "d4_3", "label": "Contact Dermatitis", "isCorrect": false},
        {"id": "d4_4", "label": "Eczema herpeticum", "isCorrect": false}
    ]',
    '[
        {
            "id": "n4_1", 
            "label": "Apply topical corticosteroids for flares and maintain emollients", 
            "isCorrect": true,
            "rationale": "Topical steroids help reduce inflammation during flares, while emollients restore the skin barrier."
        },
        {
            "id": "n4_2", 
            "label": "Urgent referral for antiviral treatment", 
            "isCorrect": false,
            "rationale": "Only necessary for eczema herpeticum."
        }
    ]',
    '{
        "correctDiagnosis": "Atopic Dermatitis",
        "explanation": "This case shows chronic-looking inflammation with lichenification and hyperpigmentation around the mouth, which is a classic presentation of atopic dermatitis in children with darker skin tones.",
        "keyVisualCues": ["Lichenification", "Perioral distribution", "Hyperpigmentation"],
        "differentialNote": "Eczema herpeticum would show monomorphic vesicles/punched-out erosions and the child would often be unwell."
    }',
    ARRAY['atopic-dermatitis', 'pediatrics', 'pigment-change', 'chronic']
) ON CONFLICT (id) DO NOTHING;
