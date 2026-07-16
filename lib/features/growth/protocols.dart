/// Curated habit protocols with evidence labels, safety notes and sources.
/// Popularity is not proof — labels are honest, and everything is editable.
library;

import 'package:flutter/material.dart';

class ProtocolPreset {
  const ProtocolPreset({
    required this.id,
    required this.name,
    required this.icon,
    required this.purpose,
    required this.explanation,
    required this.protocol,
    required this.minimumVersion,
    required this.evidenceLevel,
    required this.source,
    this.safetyNotes,
    this.durationMin,
    this.suggestedWeeklyTarget,
    this.reviewAfterDays = 28,
  });

  final String id;
  final String name;
  final IconData icon;
  final String purpose;
  final String explanation;
  final String protocol;
  final String minimumVersion;
  final String evidenceLevel; // Strong | Moderate | Limited | Experimental | Personal preference
  final String source;
  final String? safetyNotes;
  final int? durationMin;
  final int? suggestedWeeklyTarget;
  final int reviewAfterDays;
}

const protocolPresets = <ProtocolPreset>[
  ProtocolPreset(
    id: 'sleep',
    name: 'Sleep',
    icon: Icons.bedtime_outlined,
    purpose: 'Better recovery, mood and focus — sleep drives everything else.',
    explanation:
        'Consistent sleep and wake times anchor your circadian rhythm. Morning '
        'light exposure and an earlier, dimmer evening are the highest-leverage levers.',
    protocol: '• Fixed wake time (±30 min), even weekends\n'
        '• 10–20 min outdoor light within an hour of waking\n'
        '• Dim screens/lights 1–2 h before bed; bedroom cool and dark\n'
        '• No caffeine within 8–10 h of bedtime',
    minimumVersion: 'Just keep the fixed wake time today.',
    evidenceLevel: 'Strong evidence',
    source: 'Matthew Walker; Andrew Huberman',
    suggestedWeeklyTarget: 7,
    durationMin: null,
  ),
  ProtocolPreset(
    id: 'breathing',
    name: 'Breathing',
    icon: Icons.air,
    purpose: 'Fast, reliable downshift for stress in the moment.',
    explanation:
        'Slow exhale-emphasised breathing activates the parasympathetic system. '
        'The physiological sigh (double inhale, long exhale) works in under a minute.',
    protocol: '• 5 min daily: inhale 4 s → exhale 6–8 s\n'
        '• Acute stress: 1–3 physiological sighs\n'
        '• Nasal breathing by default',
    minimumVersion: 'Three physiological sighs — 30 seconds.',
    evidenceLevel: 'Strong evidence',
    source: 'Andrew Huberman (Stanford breathwork study)',
    durationMin: 5,
    suggestedWeeklyTarget: 5,
  ),
  ProtocolPreset(
    id: 'sauna',
    name: 'Sauna',
    icon: Icons.hot_tub_outlined,
    purpose: 'Cardiovascular health and deep relaxation.',
    explanation:
        'Regular sauna use is associated with lower cardiovascular risk in large '
        'Finnish cohort studies; it also aids relaxation and sleep.',
    protocol: '• 15–20 min at 80–100 °C, 2–4×/week\n'
        '• Hydrate before and after\n'
        '• Exit early if dizzy or unwell',
    minimumVersion: 'One 10-minute round.',
    evidenceLevel: 'Moderate evidence',
    source: 'Rhonda Patrick; Laukkanen cohort studies',
    safetyNotes:
        'Avoid alcohol before/during. Caution with low blood pressure or heart '
        'conditions — check with a doctor.',
    durationMin: 20,
    suggestedWeeklyTarget: 3,
  ),
  ProtocolPreset(
    id: 'cold',
    name: 'Cold exposure',
    icon: Icons.ac_unit,
    purpose: 'Alertness, mood boost, stress-resilience practice.',
    explanation:
        'Deliberate cold raises catecholamines and gives a strong, immediate '
        'alertness/mood effect. Long-term health claims are less settled.',
    protocol: '• End showers with 30–60 s cold, building to 2–3 min\n'
        '• Or 1–3 min immersion at "uncomfortably cold but safe"\n'
        '• ~11 min total per week across sessions is a common target',
    minimumVersion: '30 seconds cold at the end of a shower.',
    evidenceLevel: 'Moderate evidence',
    source: 'Andrew Huberman; Susanna Søberg',
    safetyNotes:
        'Never alone in open water. Caution with heart conditions — cold shock '
        'is a real stressor.',
    durationMin: 3,
    suggestedWeeklyTarget: 4,
  ),
  ProtocolPreset(
    id: 'redlight',
    name: 'Red-light therapy',
    icon: Icons.light_mode_outlined,
    purpose: 'Possible skin and recovery benefits.',
    explanation:
        'Photobiomodulation has promising but mixed research — effects depend '
        'heavily on dose and device. Treat it as an experiment, not a pillar.',
    protocol: '• 10 min, 3–5×/week at manufacturer-recommended distance\n'
        '• Morning use pairs well with light exposure habits',
    minimumVersion: '5 minutes.',
    evidenceLevel: 'Limited evidence',
    source: 'Mixed literature; device-dependent',
    safetyNotes: 'Do not stare into LEDs.',
    durationMin: 10,
    suggestedWeeklyTarget: 4,
  ),
  ProtocolPreset(
    id: 'reading',
    name: 'Reading',
    icon: Icons.menu_book_outlined,
    purpose: 'Knowledge, focus training, better evenings than scrolling.',
    explanation:
        'A fixed daily reading slot compounds enormously — 15 min/day is '
        '15–20 books a year. Paper or e-ink in the evening also protects sleep.',
    protocol: '• 15–30 min at a fixed trigger (after dinner / before bed)\n'
        '• Keep the book visible; phone in another room',
    minimumVersion: 'One page.',
    evidenceLevel: 'Personal preference',
    source: 'James Clear (habit design)',
    durationMin: 20,
    suggestedWeeklyTarget: 5,
  ),
  ProtocolPreset(
    id: 'focus',
    name: 'Focus',
    icon: Icons.center_focus_strong_outlined,
    purpose: 'Longer stretches of deep, undistracted work.',
    explanation:
        'Focus is trainable: single-task blocks with a visible timer, phone out '
        'of reach, and deliberate boredom tolerance. Ultradian ~90 min cycles help.',
    protocol: '• 1–2 deep-work blocks daily (45–90 min)\n'
        '• Phone in another room; one tab/task\n'
        '• 10–20 min real break between blocks (no feeds)',
    minimumVersion: 'One 25-minute block.',
    evidenceLevel: 'Moderate evidence',
    source: 'Andrew Huberman; Cal Newport',
    durationMin: 60,
    suggestedWeeklyTarget: 5,
  ),
  ProtocolPreset(
    id: 'memory',
    name: 'Memory',
    icon: Icons.psychology_outlined,
    purpose: 'Retain more of what you learn.',
    explanation:
        'Spaced repetition and active recall are the two most robust learning '
        'techniques in cognitive science.',
    protocol: '• 10 min/day spaced-repetition review (e.g. flashcards)\n'
        '• After learning something, close the source and recall it aloud\n'
        '• Sleep consolidates — review before bed works well',
    minimumVersion: 'Review 5 cards.',
    evidenceLevel: 'Strong evidence',
    source: 'Cognitive science literature (testing effect)',
    durationMin: 10,
    suggestedWeeklyTarget: 5,
  ),
  ProtocolPreset(
    id: 'stress',
    name: 'Stress',
    icon: Icons.spa_outlined,
    purpose: 'Lower baseline stress, not just coping in spikes.',
    explanation:
        'Baseline stress responds to daily downshift practices: NSDR/yoga nidra, '
        'walks without input, and honest workload boundaries.',
    protocol: '• 10–20 min NSDR / yoga nidra or quiet walk daily\n'
        '• One screen-free hour before bed\n'
        '• Write tomorrow\'s top 3 tasks tonight (closes loops)',
    minimumVersion: '5 minutes of NSDR or a short walk.',
    evidenceLevel: 'Moderate evidence',
    source: 'Andrew Huberman (NSDR); general stress literature',
    durationMin: 15,
    suggestedWeeklyTarget: 5,
  ),
  ProtocolPreset(
    id: 'mobility',
    name: 'Mobility',
    icon: Icons.accessibility_new_outlined,
    purpose: 'Move well, protect the knees and back, age gracefully.',
    explanation:
        'Short frequent sessions beat rare long ones. Position your work around '
        'hips, ankles and thoracic spine — the usual desk-life victims.',
    protocol: '• 10 min daily: hips + ankles + t-spine\n'
        '• Sit in a deep squat during one break\n'
        '• Pairs well as a warm-up before training',
    minimumVersion: '2 minutes of hip openers.',
    evidenceLevel: 'Moderate evidence',
    source: 'Andy Galpin; Kelly Starrett',
    durationMin: 10,
    suggestedWeeklyTarget: 5,
  ),
  ProtocolPreset(
    id: 'wellbeing',
    name: 'Mental wellbeing',
    icon: Icons.favorite_outline,
    purpose: 'A steadier, more grateful baseline.',
    explanation:
        'Brief gratitude and connection practices have small but consistent '
        'effects on wellbeing; social connection is the strongest predictor.',
    protocol: '• Note 3 things that went well (evening)\n'
        '• One genuine check-in with someone you care about daily\n'
        '• Weekly: something outdoors and unhurried',
    minimumVersion: 'One line of gratitude.',
    evidenceLevel: 'Moderate evidence',
    source: 'Positive psychology literature',
    durationMin: 5,
    suggestedWeeklyTarget: 7,
  ),
];
