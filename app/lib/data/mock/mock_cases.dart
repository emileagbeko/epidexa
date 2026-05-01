import '../models/clinical_case.dart';

const List<ClinicalCase> mockCases = [
  ClinicalCase(
    id: 'case_001',
    title: 'Itchy rash on forearm',
    difficulty: CaseDifficulty.beginner,
    category: DermatologyCategory.inflammatory,
    patientPresentation:
        'A 26-year-old nurse presents with a 5-day history of an itchy, '
        'erythematous rash on the flexural surface of the right forearm. '
        'No previous skin conditions. Reports increased hand-washing frequency '
        'over the past month due to a new ward placement.',
    additionalHistory:
        'No known drug allergies. No personal or family history of atopy. '
        'First episode. Not on any regular medications.',
    imagePath: 'assets/images/case_001_v2.png',
    observationOptions: [
      ObservationOption(id: 'o1_1', label: 'Erythema (redness)', isCorrect: true),
      ObservationOption(id: 'o1_2', label: 'Vesicles', isCorrect: true),
      ObservationOption(id: 'o1_3', label: 'Silvery scale', isCorrect: false),
      ObservationOption(id: 'o1_4', label: 'Excoriation marks', isCorrect: true),
      ObservationOption(id: 'o1_5', label: 'Well-demarcated border', isCorrect: false),
      ObservationOption(id: 'o1_6', label: 'Ill-defined border', isCorrect: true),
    ],
    diagnosisOptions: [
      DiagnosisOption(id: 'd1_1', label: 'Atopic eczema', isCorrect: false),
      DiagnosisOption(id: 'd1_2', label: 'Irritant contact dermatitis', isCorrect: true),
      DiagnosisOption(id: 'd1_3', label: 'Psoriasis', isCorrect: false),
      DiagnosisOption(id: 'd1_4', label: 'Tinea corporis', isCorrect: false),
    ],
    nextStepOptions: [
      NextStepOption(
        id: 'n1_1',
        label: 'Prescribe topical corticosteroid and identify the irritant trigger',
        isCorrect: true,
        rationale:
            'First-line management for irritant contact dermatitis. Identifying and '
            'removing the trigger is essential — in this case, frequent hand-washing '
            'with soap. Emollients should also be advised.',
      ),
      NextStepOption(
        id: 'n1_2',
        label: 'Prescribe oral antifungal',
        isCorrect: false,
        rationale:
            'No features of fungal infection are present. Tinea would show a '
            'well-demarcated, advancing edge with central clearing — not seen here.',
      ),
      NextStepOption(
        id: 'n1_3',
        label: 'Refer urgently to dermatology',
        isCorrect: false,
        rationale:
            'Appropriate for severe, widespread, or diagnostically uncertain cases. '
            'This is a mild-to-moderate presentation manageable in primary care.',
      ),
    ],
    feedback: FeedbackData(
      correctDiagnosis: 'Irritant Contact Dermatitis',
      explanation:
          'The clinical picture strongly suggests irritant contact dermatitis (ICD). '
          'Key features are the direct correlation with a new occupational irritant '
          '(frequent hand-washing), ill-defined borders, vesicles on an erythematous base, '
          'and excoriation from pruritus. Unlike allergic contact dermatitis, ICD does not '
          'require prior sensitisation — repeated exposure to an irritant disrupts the '
          'skin barrier directly. Management centres on removing the trigger and restoring '
          'the barrier with emollients and a short course of topical steroid.',
      keyVisualCues: [
        'Ill-defined border',
        'Vesicles on erythematous base',
        'Flexural distribution',
        'Excoriation from pruritus',
      ],
      differentialNote:
          'Psoriasis would present with well-demarcated, silvery-scaled plaques '
          'on extensor surfaces — the opposite pattern to this case. Atopic eczema '
          'shares flexural distribution but typically has a personal or family atopy history.',
    ),
    conceptTags: ['contact-dermatitis', 'inflammatory', 'occupational', 'topical-steroids'],
    specialtyNote: 'Common in healthcare workers due to repeated glove use and hand hygiene.',
  ),
  ClinicalCase(
    id: 'case_002',
    title: 'Scaly plaques on elbows',
    difficulty: CaseDifficulty.beginner,
    category: DermatologyCategory.inflammatory,
    patientPresentation:
        'A 34-year-old accountant presents with a 3-month history of thickened, '
        'scaly patches on both elbows and the lower back. The patches are mildly '
        'itchy but not painful. He mentions his father had a similar skin condition.',
    additionalHistory:
        'No known drug allergies. Non-smoker. Reports recent work-related stress. '
        'Joints are not painful or swollen. No eye symptoms.',
    imagePath: 'assets/images/case_002_v2.png',
    observationOptions: [
      ObservationOption(id: 'o2_1', label: 'Silvery-white scale', isCorrect: true),
      ObservationOption(id: 'o2_2', label: 'Well-demarcated border', isCorrect: true),
      ObservationOption(id: 'o2_3', label: 'Erythematous plaque', isCorrect: true),
      ObservationOption(id: 'o2_4', label: 'Vesicles', isCorrect: false),
      ObservationOption(id: 'o2_5', label: 'Extensor surface distribution', isCorrect: true),
      ObservationOption(id: 'o2_6', label: 'Ill-defined border', isCorrect: false),
    ],
    diagnosisOptions: [
      DiagnosisOption(id: 'd2_1', label: 'Plaque psoriasis', isCorrect: true),
      DiagnosisOption(id: 'd2_2', label: 'Atopic eczema', isCorrect: false),
      DiagnosisOption(id: 'd2_3', label: 'Seborrhoeic dermatitis', isCorrect: false),
      DiagnosisOption(id: 'd2_4', label: 'Pityriasis rosea', isCorrect: false),
    ],
    nextStepOptions: [
      NextStepOption(
        id: 'n2_1',
        label: 'Prescribe topical corticosteroid with emollient and refer to dermatology',
        isCorrect: true,
        rationale:
            'Moderate plaque psoriasis on multiple body sites warrants dermatology referral '
            'for phototherapy or systemic therapy assessment. Topical steroids and emollients '
            'are first-line for mild disease and symptom control while awaiting review.',
      ),
      NextStepOption(
        id: 'n2_2',
        label: 'Prescribe antifungal shampoo and topical antifungal',
        isCorrect: false,
        rationale:
            'Antifungals are indicated for seborrhoeic dermatitis, which affects '
            'sebaceous areas (scalp, face, chest). Extensor plaques with silvery scale '
            'are not consistent with fungal infection.',
      ),
      NextStepOption(
        id: 'n2_3',
        label: 'Prescribe oral antihistamine and emollient only',
        isCorrect: false,
        rationale:
            'Antihistamines address itch but do not treat the underlying inflammatory '
            'process in psoriasis. Emollients alone are insufficient for established plaques.',
      ),
    ],
    feedback: FeedbackData(
      correctDiagnosis: 'Plaque Psoriasis',
      explanation:
          'Plaque psoriasis is the most common subtype, characterised by well-demarcated, '
          'erythematous plaques covered with silvery-white scale, classically on extensor '
          'surfaces (elbows, knees, sacrum). A positive family history (father affected) '
          'supports the diagnosis, as psoriasis has strong genetic associations. '
          'Stress is a well-recognised trigger. The absence of joint pain here makes '
          'psoriatic arthritis less likely, but should be screened for at every review '
          'as 30% of psoriasis patients develop it.',
      keyVisualCues: [
        'Silvery-white scale',
        'Well-demarcated plaques',
        'Extensor surface distribution',
        'Erythematous base beneath scale',
      ],
      differentialNote:
          'Atopic eczema favours flexural surfaces (antecubital fossa, popliteal fossa) '
          'and has ill-defined borders — the opposite pattern to psoriasis. '
          'Seborrhoeic dermatitis affects sebaceous areas and has greasy rather than '
          'silvery scale.',
    ),
    conceptTags: ['psoriasis', 'inflammatory', 'chronic', 'topical-steroids', 'dermatology-referral'],
    specialtyNote:
        'Always screen for psoriatic arthritis at every psoriasis review — '
        'early treatment prevents joint damage.',
  ),
  ClinicalCase(
    id: 'case_003',
    title: 'Infant with itchy cheeks',
    difficulty: CaseDifficulty.beginner,
    category: DermatologyCategory.inflammatory,
    patientPresentation:
        'A 9-month-old girl is brought to the GP with an itchy rash that has '
        'developed over the past few weeks. Her father reports she is often '
        'restless and trying to scratch her face.',
    additionalHistory:
        'Normal growth and development. Father has a history of itchy skin '
        'rashes since childhood. No known allergies.',
    imagePath: 'assets/images/case_003.png',
    observationOptions: [
      ObservationOption(id: 'o3_1', label: 'Erythema on cheeks', isCorrect: true),
      ObservationOption(id: 'o3_2', label: 'Dry skin', isCorrect: true),
      ObservationOption(id: 'o3_3', label: 'Extensor surface involvement', isCorrect: true),
      ObservationOption(id: 'o3_4', label: 'Pearly umbilicated papules', isCorrect: false),
    ],
    diagnosisOptions: [
      DiagnosisOption(id: 'd3_1', label: 'Atopic eczema', isCorrect: true),
      DiagnosisOption(id: 'd3_2', label: 'Seborrhoeic dermatitis', isCorrect: false),
      DiagnosisOption(id: 'd3_3', label: 'Contact dermatitis', isCorrect: false),
      DiagnosisOption(id: 'd3_4', label: 'Psoriasis', isCorrect: false),
    ],
    nextStepOptions: [
      NextStepOption(
        id: 'n3_1',
        label: 'Prescribe regular emollients and soap substitutes',
        isCorrect: true,
        rationale:
            'Emollients are the mainstay of treatment for atopic eczema to restore '
            'the skin barrier. Avoiding soap and other irritants is also essential.',
      ),
      NextStepOption(
        id: 'n3_2',
        label: 'Prescribe oral antifungal',
        isCorrect: false,
        rationale: 'Not indicated as there is no evidence of fungal infection.',
      ),
    ],
    feedback: FeedbackData(
      correctDiagnosis: 'Atopic Eczema',
      explanation:
          'Atopic eczema in infants typically presents with a red, dry, itchy rash '
          'on the face (cheeks) and extensor surfaces of the limbs. The positive '
          'family history (father affected) and the classic distribution support the diagnosis.',
      keyVisualCues: [
        'Facial erythema',
        'Extensor involvement',
        'Dry, scaly patches',
      ],
      differentialNote:
          'Seborrhoeic dermatitis in infants (cradle cap) usually affects the scalp '
          'and flexures, and is typically not as itchy as atopic eczema.',
    ),
    conceptTags: ['eczema', 'pediatrics', 'inflammatory', 'emollients'],
  ),
  ClinicalCase(
    id: 'case_004',
    title: 'Perioral rash in a toddler',
    difficulty: CaseDifficulty.intermediate,
    category: DermatologyCategory.inflammatory,
    patientPresentation:
        'A 4-year-old boy presents with a persistent rash around his mouth and cheeks. '
        'The skin appears thickened and darker than the surrounding areas.',
    additionalHistory:
        'Chronic history of dry skin. Occasional flares of itching. '
        'No systemic symptoms.',
    imagePath: 'assets/images/case_004.png',
    observationOptions: [
      ObservationOption(id: 'o4_1', label: 'Lichenification', isCorrect: true),
      ObservationOption(id: 'o4_2', label: 'Hyperpigmentation', isCorrect: true),
      ObservationOption(id: 'o4_3', label: 'Dry, scaly skin', isCorrect: true),
      ObservationOption(id: 'o4_4', label: 'Punched-out erosions', isCorrect: false),
    ],
    diagnosisOptions: [
      DiagnosisOption(id: 'd4_1', label: 'Atopic Dermatitis', isCorrect: true),
      DiagnosisOption(id: 'd4_2', label: 'Molluscum contagiosum', isCorrect: false),
      DiagnosisOption(id: 'd4_3', label: 'Contact Dermatitis', isCorrect: false),
      DiagnosisOption(id: 'd4_4', label: 'Eczema herpeticum', isCorrect: false),
    ],
    nextStepOptions: [
      NextStepOption(
        id: 'n4_1',
        label: 'Apply topical corticosteroids for flares and maintain emollients',
        isCorrect: true,
        rationale:
            'Topical steroids help reduce inflammation during flares, while '
            'emollients restore the skin barrier in chronic atopic dermatitis.',
      ),
      NextStepOption(
        id: 'n4_2',
        label: 'Urgent referral for antiviral treatment',
        isCorrect: false,
        rationale:
            'Only necessary for eczema herpeticum, which would present with '
            'monomorphic vesicles and systemic illness.',
      ),
    ],
    feedback: FeedbackData(
      correctDiagnosis: 'Atopic Dermatitis',
      explanation:
          'This case shows chronic-looking inflammation with lichenification and '
          'hyperpigmentation around the mouth, which is a classic presentation of '
          'atopic dermatitis in children with darker skin tones. Erythema is often '
          'less prominent, replaced by pigment changes.',
      keyVisualCues: [
        'Lichenification',
        'Perioral distribution',
        'Hyperpigmentation',
      ],
      differentialNote:
          'Eczema herpeticum would show monomorphic vesicles/punched-out erosions '
          'and the child would often be unwell.',
    ),
    conceptTags: ['atopic-dermatitis', 'pediatrics', 'pigment-change', 'chronic'],
  ),
  ClinicalCase(
    id: 'case_005',
    title: 'Red-brown net-like rash',
    difficulty: CaseDifficulty.intermediate,
    category: DermatologyCategory.inflammatory,
    patientPresentation:
        'A 52-year-old man presents with a red-brown, net-like rash over his lower back. '
        'He reports using a heated blanket most evenings for the last several months '
        'to manage longstanding back pain.',
    additionalHistory:
        'Longstanding history of lower back pain. No other systemic symptoms. '
        'Non-smoker. No known allergies.',
    imagePath: null, // Text-only case
    observationOptions: [
      ObservationOption(id: 'o5_1', label: 'Reticulated appearance', isCorrect: true),
      ObservationOption(id: 'o5_2', label: 'Red-brown pigmentation', isCorrect: true),
      ObservationOption(id: 'o5_3', label: 'Well-demarcated border', isCorrect: false),
      ObservationOption(id: 'o5_4', label: 'Non-tender to palpation', isCorrect: true),
    ],
    diagnosisOptions: [
      DiagnosisOption(id: 'd5_1', label: 'Erythema ab igne', isCorrect: true),
      DiagnosisOption(id: 'd5_2', label: 'Livedo reticularis', isCorrect: false),
      DiagnosisOption(id: 'd5_3', label: 'Allergic contact dermatitis', isCorrect: false),
      DiagnosisOption(id: 'd5_4', label: 'Tinea corporis', isCorrect: false),
    ],
    nextStepOptions: [
      NextStepOption(
        id: 'n5_1',
        label: 'Advise stopping further heat exposure',
        isCorrect: true,
        rationale:
            'The primary management for Erythema ab igne is removal of the heat source. '
            'This often leads to gradual resolution of the rash.',
      ),
      NextStepOption(
        id: 'n5_2',
        label: 'Arrange patch testing',
        isCorrect: false,
        rationale:
            'Patch testing is used for allergic contact dermatitis, but this '
            'pattern is classic for chronic heat exposure.',
      ),
      NextStepOption(
        id: 'n5_3',
        label: 'Prescribe topical antifungal',
        isCorrect: false,
        rationale:
            'There are no features of fungal infection such as central clearing or scaling edges.',
      ),
    ],
    feedback: FeedbackData(
      correctDiagnosis: 'Erythema ab igne',
      explanation:
          'Erythema ab igne is a reticulated, erythematous, and subsequently hyperpigmented '
          'dermatosis caused by chronic exposure to moderate heat. Common sources include '
          'laptops, space heaters, and heated blankets. The pattern is characteristic '
          'and the history of heat exposure is diagnostic. Management involves '
          'identifying and removing the heat source.',
      keyVisualCues: [
        'Reticulated (net-like) pattern',
        'Red-brown hyperpigmentation',
        'History of chronic heat exposure',
      ],
      differentialNote:
          'Livedo reticularis also has a net-like pattern but is usually related to '
          'vascular issues and lacks the specific history of heat exposure.',
    ),
    conceptTags: ['heat-exposure', 'pigment-change', 'environmental', 'high-yield'],
    specialtyNote: 'Chronic lesions should be monitored as they have a rare risk of malignant transformation.',
  ),
];
