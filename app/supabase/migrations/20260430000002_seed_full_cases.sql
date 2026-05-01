-- Upsert all 5 clinical cases with full JSONB data
-- Safe to re-run: ON CONFLICT DO UPDATE

INSERT INTO clinical_cases (
  id, title, difficulty, category, patient_presentation, additional_history,
  image_path, observation_options, diagnosis_options, next_step_options,
  feedback, concept_tags, specialty_note, status
) VALUES

-- case_001: Irritant Contact Dermatitis
(
  'case_001',
  'Itchy rash on forearm',
  'beginner',
  'inflammatory',
  'A 26-year-old nurse presents with a 5-day history of an itchy, erythematous rash on the flexural surface of the right forearm. No previous skin conditions. Reports increased hand-washing frequency over the past month due to a new ward placement.',
  'No known drug allergies. No personal or family history of atopy. First episode. Not on any regular medications.',
  'assets/images/case_001_v2.png',
  '[
    {"id": "o1_1", "label": "Erythema (redness)", "isCorrect": true},
    {"id": "o1_2", "label": "Vesicles", "isCorrect": true},
    {"id": "o1_3", "label": "Silvery scale", "isCorrect": false},
    {"id": "o1_4", "label": "Excoriation marks", "isCorrect": true},
    {"id": "o1_5", "label": "Well-demarcated border", "isCorrect": false},
    {"id": "o1_6", "label": "Ill-defined border", "isCorrect": true}
  ]',
  '[
    {"id": "d1_1", "label": "Atopic eczema", "isCorrect": false},
    {"id": "d1_2", "label": "Irritant contact dermatitis", "isCorrect": true},
    {"id": "d1_3", "label": "Psoriasis", "isCorrect": false},
    {"id": "d1_4", "label": "Tinea corporis", "isCorrect": false}
  ]',
  '[
    {
      "id": "n1_1",
      "label": "Prescribe topical corticosteroid and identify the irritant trigger",
      "isCorrect": true,
      "rationale": "First-line management for irritant contact dermatitis. Identifying and removing the trigger is essential — in this case, frequent hand-washing with soap. Emollients should also be advised."
    },
    {
      "id": "n1_2",
      "label": "Prescribe oral antifungal",
      "isCorrect": false,
      "rationale": "No features of fungal infection are present. Tinea would show a well-demarcated, advancing edge with central clearing — not seen here."
    },
    {
      "id": "n1_3",
      "label": "Refer urgently to dermatology",
      "isCorrect": false,
      "rationale": "Appropriate for severe, widespread, or diagnostically uncertain cases. This is a mild-to-moderate presentation manageable in primary care."
    }
  ]',
  '{
    "correctDiagnosis": "Irritant Contact Dermatitis",
    "explanation": "The clinical picture strongly suggests irritant contact dermatitis (ICD). Key features are the direct correlation with a new occupational irritant (frequent hand-washing), ill-defined borders, vesicles on an erythematous base, and excoriation from pruritus. Unlike allergic contact dermatitis, ICD does not require prior sensitisation — repeated exposure to an irritant disrupts the skin barrier directly. Management centres on removing the trigger and restoring the barrier with emollients and a short course of topical steroid.",
    "keyVisualCues": ["Ill-defined border", "Vesicles on erythematous base", "Flexural distribution", "Excoriation from pruritus"],
    "differentialNote": "Psoriasis would present with well-demarcated, silvery-scaled plaques on extensor surfaces — the opposite pattern to this case. Atopic eczema shares flexural distribution but typically has a personal or family atopy history."
  }',
  ARRAY['contact-dermatitis', 'inflammatory', 'occupational', 'topical-steroids'],
  'Common in healthcare workers due to repeated glove use and hand hygiene.',
  'Published'
),

-- case_002: Plaque Psoriasis
(
  'case_002',
  'Scaly plaques on elbows',
  'beginner',
  'inflammatory',
  'A 34-year-old accountant presents with a 3-month history of thickened, scaly patches on both elbows and the lower back. The patches are mildly itchy but not painful. He mentions his father had a similar skin condition.',
  'No known drug allergies. Non-smoker. Reports recent work-related stress. Joints are not painful or swollen. No eye symptoms.',
  'assets/images/case_002_v2.png',
  '[
    {"id": "o2_1", "label": "Silvery-white scale", "isCorrect": true},
    {"id": "o2_2", "label": "Well-demarcated border", "isCorrect": true},
    {"id": "o2_3", "label": "Erythematous plaque", "isCorrect": true},
    {"id": "o2_4", "label": "Vesicles", "isCorrect": false},
    {"id": "o2_5", "label": "Extensor surface distribution", "isCorrect": true},
    {"id": "o2_6", "label": "Ill-defined border", "isCorrect": false}
  ]',
  '[
    {"id": "d2_1", "label": "Plaque psoriasis", "isCorrect": true},
    {"id": "d2_2", "label": "Atopic eczema", "isCorrect": false},
    {"id": "d2_3", "label": "Seborrhoeic dermatitis", "isCorrect": false},
    {"id": "d2_4", "label": "Pityriasis rosea", "isCorrect": false}
  ]',
  '[
    {
      "id": "n2_1",
      "label": "Prescribe topical corticosteroid with emollient and refer to dermatology",
      "isCorrect": true,
      "rationale": "Moderate plaque psoriasis on multiple body sites warrants dermatology referral for phototherapy or systemic therapy assessment. Topical steroids and emollients are first-line for mild disease and symptom control while awaiting review."
    },
    {
      "id": "n2_2",
      "label": "Prescribe antifungal shampoo and topical antifungal",
      "isCorrect": false,
      "rationale": "Antifungals are indicated for seborrhoeic dermatitis, which affects sebaceous areas (scalp, face, chest). Extensor plaques with silvery scale are not consistent with fungal infection."
    },
    {
      "id": "n2_3",
      "label": "Prescribe oral antihistamine and emollient only",
      "isCorrect": false,
      "rationale": "Antihistamines address itch but do not treat the underlying inflammatory process in psoriasis. Emollients alone are insufficient for established plaques."
    }
  ]',
  '{
    "correctDiagnosis": "Plaque Psoriasis",
    "explanation": "Plaque psoriasis is the most common subtype, characterised by well-demarcated, erythematous plaques covered with silvery-white scale, classically on extensor surfaces (elbows, knees, sacrum). A positive family history (father affected) supports the diagnosis, as psoriasis has strong genetic associations. Stress is a well-recognised trigger. The absence of joint pain here makes psoriatic arthritis less likely, but should be screened for at every review as 30% of psoriasis patients develop it.",
    "keyVisualCues": ["Silvery-white scale", "Well-demarcated plaques", "Extensor surface distribution", "Erythematous base beneath scale"],
    "differentialNote": "Atopic eczema favours flexural surfaces (antecubital fossa, popliteal fossa) and has ill-defined borders — the opposite pattern to psoriasis. Seborrhoeic dermatitis affects sebaceous areas and has greasy rather than silvery scale."
  }',
  ARRAY['psoriasis', 'inflammatory', 'chronic', 'topical-steroids', 'dermatology-referral'],
  'Always screen for psoriatic arthritis at every psoriasis review — early treatment prevents joint damage.',
  'Published'
),

-- case_005: Erythema ab igne (text-only, no image)
(
  'case_005',
  'Red-brown net-like rash',
  'intermediate',
  'inflammatory',
  'A 52-year-old man presents with a red-brown, net-like rash over his lower back. He reports using a heated blanket most evenings for the last several months to manage longstanding back pain.',
  'Longstanding history of lower back pain. No other systemic symptoms. Non-smoker. No known allergies.',
  NULL,
  '[
    {"id": "o5_1", "label": "Reticulated appearance", "isCorrect": true},
    {"id": "o5_2", "label": "Red-brown pigmentation", "isCorrect": true},
    {"id": "o5_3", "label": "Well-demarcated border", "isCorrect": false},
    {"id": "o5_4", "label": "Non-tender to palpation", "isCorrect": true}
  ]',
  '[
    {"id": "d5_1", "label": "Erythema ab igne", "isCorrect": true},
    {"id": "d5_2", "label": "Livedo reticularis", "isCorrect": false},
    {"id": "d5_3", "label": "Allergic contact dermatitis", "isCorrect": false},
    {"id": "d5_4", "label": "Tinea corporis", "isCorrect": false}
  ]',
  '[
    {
      "id": "n5_1",
      "label": "Advise stopping further heat exposure",
      "isCorrect": true,
      "rationale": "The primary management for Erythema ab igne is removal of the heat source. This often leads to gradual resolution of the rash."
    },
    {
      "id": "n5_2",
      "label": "Arrange patch testing",
      "isCorrect": false,
      "rationale": "Patch testing is used for allergic contact dermatitis, but this pattern is classic for chronic heat exposure."
    },
    {
      "id": "n5_3",
      "label": "Prescribe topical antifungal",
      "isCorrect": false,
      "rationale": "There are no features of fungal infection such as central clearing or scaling edges."
    }
  ]',
  '{
    "correctDiagnosis": "Erythema ab igne",
    "explanation": "Erythema ab igne is a reticulated, erythematous, and subsequently hyperpigmented dermatosis caused by chronic exposure to moderate heat. Common sources include laptops, space heaters, and heated blankets. The pattern is characteristic and the history of heat exposure is diagnostic. Management involves identifying and removing the heat source.",
    "keyVisualCues": ["Reticulated (net-like) pattern", "Red-brown hyperpigmentation", "History of chronic heat exposure"],
    "differentialNote": "Livedo reticularis also has a net-like pattern but is usually related to vascular issues and lacks the specific history of heat exposure."
  }',
  ARRAY['heat-exposure', 'pigment-change', 'environmental', 'high-yield'],
  'Chronic lesions should be monitored as they have a rare risk of malignant transformation.',
  'Published'
)

ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  difficulty = EXCLUDED.difficulty,
  category = EXCLUDED.category,
  patient_presentation = EXCLUDED.patient_presentation,
  additional_history = EXCLUDED.additional_history,
  image_path = EXCLUDED.image_path,
  observation_options = EXCLUDED.observation_options,
  diagnosis_options = EXCLUDED.diagnosis_options,
  next_step_options = EXCLUDED.next_step_options,
  feedback = EXCLUDED.feedback,
  concept_tags = EXCLUDED.concept_tags,
  specialty_note = EXCLUDED.specialty_note,
  status = EXCLUDED.status;
