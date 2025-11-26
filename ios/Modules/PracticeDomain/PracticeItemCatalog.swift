import Foundation

enum PracticeItemCatalog {
    static func seedItems(now: Date = Date()) -> [PracticeItem] {
        let baseState = SRSState(stability: 1.5, nextDue: now)

        return [
            // Warm-up items
            PracticeItem(
                catalogID: "warmup_chromatic",
                category: .warmup,
                title: "Chromatic Warm-Up",
                detail: "1-4 frets",
                referenceID: "warmup_chromatic",
                srs: baseState,
                coreInstructions: [
                    "1–2–3–4 pattern, one finger per fret",
                    "Use strict alternate picking"
                ],
                bonusTips: [
                    "Check every note rings clearly",
                    "Keep hand relaxed, no tension",
                    "Add accents every 4th note",
                    "Try starting on different strings"
                ],
                focusCues: [
                    "Super slow, perfect tone",
                    "Tension kills speed"
                ]
            ),
            PracticeItem(
                catalogID: "warmup_spider",
                category: .warmup,
                title: "Spider Exercise",
                detail: "Ascending/descending",
                referenceID: "warmup_spider",
                srs: baseState,
                coreInstructions: [
                    "1-2-4-3, then 1-3-4-2 finger patterns",
                    "Keep fingers close to fretboard"
                ],
                bonusTips: [
                    "Don't lift fingers more than 1cm",
                    "Stay on the beat, no rushing",
                    "Check for buzzing notes",
                    "Gradually increase tempo by 5 BPM"
                ],
                focusCues: [
                    "Efficiency > speed",
                    "Every note identical"
                ]
            ),

            // Fretboard items
            PracticeItem(
                catalogID: "fretboard_note_naming",
                category: .fretboard,
                title: "Note Naming",
                detail: "E & A strings",
                srs: baseState,
                coreInstructions: [
                    "Say note names out loud as you play",
                    "Work up the E and A strings to 12th fret"
                ],
                bonusTips: [
                    "Start slow, speed comes with familiarity",
                    "Use octave shapes to double-check",
                    "Practice going backwards too"
                ],
                focusCues: [
                    "Know your fretboard cold",
                    "Think > memorize"
                ]
            ),
            PracticeItem(
                catalogID: "fretboard_octave_shapes",
                category: .fretboard,
                title: "Octave Shapes",
                detail: "Across neck",
                srs: baseState,
                coreInstructions: [
                    "Find same note on different strings",
                    "Use 2-fret/2-string and 3-fret shapes"
                ],
                bonusTips: [
                    "Visualize the shapes, not just the notes",
                    "Connect shapes across the neck",
                    "Practice with random starting notes"
                ],
                focusCues: [
                    "See patterns, not dots",
                    "Connect the neck"
                ]
            ),

            // Repertoire items
            PracticeItem(
                catalogID: "repertoire_wonderwall",
                category: .repertoire,
                title: "Wonderwall",
                detail: "Full song",
                key: "Em",
                srs: baseState,
                coreInstructions: [
                    "Em7-G-Dsus4-A7sus4 progression",
                    "Down-down-up-up-down-up strum pattern"
                ],
                bonusTips: [
                    "Let chords ring between changes",
                    "Accent the downbeats",
                    "Keep tempo steady, use metronome",
                    "Sing along to lock in timing"
                ],
                focusCues: [
                    "Feel the rhythm, don't count it",
                    "Smooth transitions matter"
                ]
            ),
            PracticeItem(
                catalogID: "repertoire_nothing_else_matters",
                category: .repertoire,
                title: "Nothing Else Matters",
                detail: "Intro",
                key: "Em",
                srs: baseState,
                coreInstructions: [
                    "Fingerpick the intro arpeggios",
                    "Keep open E ringing throughout"
                ],
                bonusTips: [
                    "Use p-i-m-a fingering pattern",
                    "Let notes sustain and overlap",
                    "Practice the picking pattern alone first",
                    "Watch for muted strings"
                ],
                focusCues: [
                    "Let it breathe",
                    "Clarity > speed"
                ]
            ),
            PracticeItem(
                catalogID: "repertoire_hotel_california",
                category: .repertoire,
                title: "Hotel California",
                detail: "Chorus",
                key: "Bm",
                srs: baseState,
                coreInstructions: [
                    "Bm-F#-A-E-G-D-Em-F# progression",
                    "Focus on smooth barre chord transitions"
                ],
                bonusTips: [
                    "Pre-shape next chord before changing",
                    "Keep thumb pressure consistent",
                    "Practice pairs of chord changes",
                    "Use minimal finger movement"
                ],
                focusCues: [
                    "Smooth wins",
                    "No gaps between chords"
                ]
            ),

            // Songwork items
            PracticeItem(
                catalogID: "songwork_blackbird",
                category: .songwork,
                title: "Blackbird",
                detail: "Fingerstyle",
                key: "G",
                srs: baseState,
                coreInstructions: [
                    "Thumb alternates bass notes",
                    "Fingers pluck melody on top"
                ],
                bonusTips: [
                    "Practice bass line alone first",
                    "Then add melody notes slowly",
                    "Keep thumb steady as a metronome",
                    "Let all notes sustain"
                ],
                focusCues: [
                    "Two voices, one guitar",
                    "Independence is key"
                ]
            ),
            PracticeItem(
                catalogID: "songwork_stand_by_me",
                category: .songwork,
                title: "Stand By Me",
                detail: "Verse groove",
                key: "A",
                srs: baseState,
                coreInstructions: [
                    "A-F#m-D-E progression",
                    "Lock into the groove feel"
                ],
                bonusTips: [
                    "Emphasize beats 2 and 4",
                    "Add palm muting for dynamics",
                    "Play along with the recording",
                    "Feel the pocket"
                ],
                focusCues: [
                    "Groove > perfection",
                    "Feel the pocket"
                ]
            ),

            // Soloing items (Am pentatonic all 5 positions)
            PracticeItem(
                catalogID: "soloing_am_pentatonic_pos1",
                category: .soloing,
                title: "Am Pentatonic",
                detail: "Position 1",
                key: "Am",
                referenceID: "scale_am_pentatonic_pos1",
                srs: baseState,
                coreInstructions: [
                    "5th fret anchor, box shape",
                    "Learn the pattern, then improvise"
                ],
                bonusTips: [
                    "Start with just 2-3 notes",
                    "Bend the 3rd scale degree",
                    "Repeat short phrases",
                    "Leave space between notes"
                ],
                focusCues: [
                    "Less is more",
                    "Space creates tension"
                ]
            ),
            PracticeItem(
                catalogID: "soloing_am_pentatonic_pos2",
                category: .soloing,
                title: "Am Pentatonic",
                detail: "Position 2",
                key: "Am",
                referenceID: "scale_am_pentatonic_pos2",
                srs: baseState,
                coreInstructions: [
                    "7th-8th fret region",
                    "Connect to position 1"
                ],
                bonusTips: [
                    "Practice sliding between positions",
                    "Use position 2 for higher notes",
                    "Target chord tones on beat 1",
                    "Try simple call-and-response phrases"
                ],
                focusCues: [
                    "Connect the boxes",
                    "Flow between positions"
                ]
            ),
            PracticeItem(
                catalogID: "soloing_am_pentatonic_pos3",
                category: .soloing,
                title: "Am Pentatonic",
                detail: "Position 3",
                key: "Am",
                referenceID: "scale_am_pentatonic_pos3",
                srs: baseState,
                coreInstructions: [
                    "9th-10th fret area",
                    "Middle register sweet spot"
                ],
                bonusTips: [
                    "Great range for expressive bends",
                    "Practice string skips within the box",
                    "Add vibrato on sustained notes",
                    "Combine with position 2 or 4"
                ],
                focusCues: [
                    "The sweet spot",
                    "Sing through the guitar"
                ]
            ),
            PracticeItem(
                catalogID: "soloing_am_pentatonic_pos4",
                category: .soloing,
                title: "Am Pentatonic",
                detail: "Position 4",
                key: "Am",
                referenceID: "scale_am_pentatonic_pos4",
                srs: baseState,
                coreInstructions: [
                    "12th fret region",
                    "Higher voice, different color"
                ],
                bonusTips: [
                    "Use for brighter, cutting lines",
                    "Easier to play fast up here",
                    "Connect downward to position 3",
                    "Try double-stops"
                ],
                focusCues: [
                    "Brighter tone, more cut",
                    "Explore the upper register"
                ]
            ),
            PracticeItem(
                catalogID: "soloing_am_pentatonic_pos5",
                category: .soloing,
                title: "Am Pentatonic",
                detail: "Position 5",
                key: "Am",
                referenceID: "scale_am_pentatonic_pos5",
                srs: baseState,
                coreInstructions: [
                    "14th-15th fret zone",
                    "Connects back to position 1"
                ],
                bonusTips: [
                    "Complete the loop around the neck",
                    "Practice descending runs to pos 1",
                    "Highest singing notes available",
                    "Great for climactic moments"
                ],
                focusCues: [
                    "Complete the circle",
                    "Soar high"
                ]
            ),
            PracticeItem(
                catalogID: "soloing_em_pentatonic_pos2",
                category: .soloing,
                title: "Em Pentatonic",
                detail: "Position 2",
                key: "Em",
                srs: baseState,
                coreInstructions: [
                    "Same shape as Am pos 2, different root",
                    "Open position friendly"
                ],
                bonusTips: [
                    "Mix in open strings",
                    "Great for rock/blues feel",
                    "Practice hybrid picking",
                    "Add bluesy bends"
                ],
                focusCues: [
                    "Blues is in the bends",
                    "Open strings are your friend"
                ]
            ),
            PracticeItem(
                catalogID: "soloing_blues_licks_box1",
                category: .soloing,
                title: "Blues Licks",
                detail: "Box 1",
                key: "Am",
                referenceID: "licks_blues_box1",
                srs: baseState,
                coreInstructions: [
                    "Short 2-4 note phrases",
                    "Repeat and vary"
                ],
                bonusTips: [
                    "Add vibrato on the last note",
                    "Try different rhythms",
                    "Bend into the target note",
                    "Listen to blues players for phrasing"
                ],
                focusCues: [
                    "Steal like an artist",
                    "Phrasing > notes"
                ]
            ),

            // Technique items
            PracticeItem(
                catalogID: "technique_alt_picking",
                category: .technique,
                title: "Alternate Picking",
                detail: "Eighth notes",
                referenceID: "technique_alt_picking",
                srs: baseState,
                coreInstructions: [
                    "Down-up-down-up, no exceptions",
                    "Start slow at 60 BPM"
                ],
                bonusTips: [
                    "Use a metronome always",
                    "Keep pick angle consistent",
                    "Relax the grip between strokes",
                    "Practice string crossing patterns",
                    "Increase tempo by 5 BPM when clean"
                ],
                focusCues: [
                    "Smooth > fast",
                    "Relaxation unlocks speed"
                ]
            ),
            PracticeItem(
                catalogID: "technique_legato",
                category: .technique,
                title: "Hammer-Ons & Pull-Offs",
                detail: "Two-string",
                referenceID: "technique_legato",
                srs: baseState,
                coreInstructions: [
                    "Fret with force, pluck with fingers",
                    "Even volume on all notes"
                ],
                bonusTips: [
                    "Pull-offs: flick string slightly down",
                    "Hammer-ons: snap finger down",
                    "Practice triplet patterns",
                    "Try combinations (pick-hammer-pull)"
                ],
                focusCues: [
                    "Finger attack matters",
                    "Make it sing without the pick"
                ]
            ),
            PracticeItem(
                catalogID: "technique_bends",
                category: .technique,
                title: "String Bending",
                detail: "Half & whole step",
                referenceID: "tech_bends_basic",
                srs: baseState,
                coreInstructions: [
                    "Bend from the wrist, not fingers",
                    "Match target pitch exactly"
                ],
                bonusTips: [
                    "Use multiple fingers for support",
                    "Bend up, then release down slowly",
                    "Check pitch accuracy constantly",
                    "Practice pre-bends too",
                    "Add vibrato at the peak"
                ],
                focusCues: [
                    "Pitch perfect or don't bend",
                    "Power comes from the wrist"
                ]
            ),
            PracticeItem(
                catalogID: "technique_vibrato",
                category: .technique,
                title: "Vibrato",
                detail: "Wrist control",
                referenceID: "tech_vibrato_basic",
                srs: baseState,
                coreInstructions: [
                    "Small wrist rotations, not finger wiggles",
                    "Start slow, gradually speed up"
                ],
                bonusTips: [
                    "Vibrato width should match the song",
                    "Try narrow vs wide variations",
                    "Sync to a slow metronome click",
                    "Listen to BB King for reference"
                ],
                focusCues: [
                    "Vibrato = voice",
                    "Control the wave"
                ]
            ),

            // Theory items
            PracticeItem(
                catalogID: "theory_major_scale_degrees",
                category: .theory,
                title: "Major Scale Degrees",
                detail: "Key of C",
                srs: baseState,
                coreInstructions: [
                    "Play C major scale, say degree numbers",
                    "1-2-3-4-5-6-7-1"
                ],
                bonusTips: [
                    "Sing each degree as you play",
                    "Identify scale degrees in songs",
                    "Practice different keys"
                ],
                focusCues: [
                    "Numbers unlock harmony",
                    "Hear the function"
                ]
            ),
            PracticeItem(
                catalogID: "theory_triad_inversions",
                category: .theory,
                title: "Triad Inversions",
                detail: "CAGED",
                srs: baseState,
                coreInstructions: [
                    "Root, 1st inversion, 2nd inversion",
                    "Play on adjacent strings"
                ],
                bonusTips: [
                    "Visualize chord tones within scale shapes",
                    "Arpeggiate each inversion",
                    "Connect inversions up the neck"
                ],
                focusCues: [
                    "See the skeleton",
                    "Every chord lives in 3 places"
                ]
            ),

            // Rhythm items
            PracticeItem(
                catalogID: "rhythm_strumming_patterns",
                category: .rhythm,
                title: "Strumming Patterns",
                detail: "1 e & a",
                srs: baseState,
                coreInstructions: [
                    "Down-down-up-up-down-up",
                    "Keep arm moving, even on ghost strums"
                ],
                bonusTips: [
                    "Count out loud: 1 e & a",
                    "Accent the downbeats",
                    "Add palm muting for dynamics",
                    "Try muting upstrokes for variation",
                    "Practice with different chord progressions"
                ],
                focusCues: [
                    "Arm never stops moving",
                    "Feel it, don't count it"
                ]
            ),
            PracticeItem(
                catalogID: "rhythm_syncopation",
                category: .rhythm,
                title: "Syncopation",
                detail: "Backbeat focus",
                srs: baseState,
                coreInstructions: [
                    "Play on the &s (off-beats)",
                    "Mute on the beats"
                ],
                bonusTips: [
                    "Tap foot on beats 1 & 3",
                    "Clap on 2 & 4 first",
                    "Listen to funk for reference",
                    "Start slow, lock it in tight"
                ],
                focusCues: [
                    "The space is the groove",
                    "Funk lives in the pocket"
                ]
            ),

            // Chord items
            PracticeItem(
                catalogID: "chords_barre_transitions",
                category: .chords,
                title: "Barre Chord Transitions",
                detail: "E-shape",
                srs: baseState,
                coreInstructions: [
                    "Practice Bm → D → A changes",
                    "Keep barre finger flat and firm"
                ],
                bonusTips: [
                    "Slide the whole shape when possible",
                    "Pre-shape fingers before landing",
                    "Build finger strength gradually",
                    "Check each string rings clear",
                    "Use minimal thumb pressure"
                ],
                focusCues: [
                    "Shape, then move",
                    "Economy of motion"
                ]
            ),
            PracticeItem(
                catalogID: "chords_open_switches",
                category: .chords,
                title: "Open Chord Switches",
                detail: "G-Em-C-D",
                referenceID: "technique_chord_transitions",
                srs: baseState,
                coreInstructions: [
                    "Common pop/rock progression",
                    "Change on beat 1, strum on beat 2"
                ],
                bonusTips: [
                    "Find common fingers that stay down",
                    "Lift and land together, not one-by-one",
                    "Practice pairs: G-Em, Em-C, C-D",
                    "Use a metronome at 60 BPM"
                ],
                focusCues: [
                    "Anchor what you can",
                    "Think ahead one chord"
                ]
            ),
            PracticeItem(
                catalogID: "chords_am_open",
                category: .chords,
                title: "Am Chord",
                detail: "Open position",
                referenceID: "chord_am_open",
                srs: baseState,
                coreInstructions: [
                    "2-3-1 fingering on B-G-D strings",
                    "Strum strings 5-1 only"
                ],
                bonusTips: [
                    "Curve fingers to avoid muting high E",
                    "Press right behind the fret",
                    "Strum from the A string down"
                ],
                focusCues: [
                    "Every string clear",
                    "Foundation first"
                ]
            ),
            PracticeItem(
                catalogID: "chords_c_major_open",
                category: .chords,
                title: "C Major Chord",
                detail: "Open position",
                referenceID: "chord_c_major_open",
                srs: baseState,
                coreInstructions: [
                    "3-2-1 fingering on A-D-B strings",
                    "Avoid hitting low E string"
                ],
                bonusTips: [
                    "Stretch finger 3 to reach low A",
                    "Keep fingers arched",
                    "Practice switching to Am and G"
                ],
                focusCues: [
                    "Clean and clear",
                    "The people's chord"
                ]
            ),
            PracticeItem(
                catalogID: "chords_g_major_open",
                category: .chords,
                title: "G Major Chord",
                detail: "Open position",
                referenceID: "chord_g_major_open",
                srs: baseState,
                coreInstructions: [
                    "2-1-3 or 3-2-4 fingering",
                    "All 6 strings ring"
                ],
                bonusTips: [
                    "Try both fingering options",
                    "3-2-4 helps with transitions to C",
                    "Let it ring out fully",
                    "Anchor finger 2 when switching"
                ],
                focusCues: [
                    "Big, full sound",
                    "Let it breathe"
                ]
            ),
            PracticeItem(
                catalogID: "chords_e_major_open",
                category: .chords,
                title: "E Major Chord",
                detail: "Open position",
                referenceID: "chord_e_major_open",
                srs: baseState,
                coreInstructions: [
                    "2-3-1 fingering on A-D-G strings",
                    "All 6 strings strum"
                ],
                bonusTips: [
                    "Keep fingers close together",
                    "Common anchor for E shape barre chords",
                    "Practice switching to Am",
                    "Bright, ringing tone"
                ],
                focusCues: [
                    "Foundation for barre chords",
                    "Strong and bright"
                ]
            ),

            // Ear training items
            PracticeItem(
                catalogID: "ear_training_major_minor",
                category: .ear_training,
                title: "Major or Minor?",
                detail: "Key feel check",
                srs: baseState,
                coreInstructions: [
                    "Play a I-IV-V-I progression, then i-iv-v-i",
                    "Feel the emotional difference"
                ],
                bonusTips: [
                    "Sing the root note first",
                    "Major = bright, minor = dark",
                    "Test yourself with songs",
                    "Close your eyes and feel it"
                ],
                focusCues: [
                    "Trust your gut",
                    "Emotion = key quality"
                ]
            ),
            PracticeItem(
                catalogID: "ear_training_hum_root",
                category: .ear_training,
                title: "Hum & Match Root",
                detail: "Find the tonic",
                srs: baseState,
                coreInstructions: [
                    "Play a chord, then hum the root note",
                    "Find it on the guitar"
                ],
                bonusTips: [
                    "Try it with backing tracks",
                    "Root note = home, feels resolved",
                    "Practice with different chord types"
                ],
                focusCues: [
                    "Feel the gravity to home",
                    "Your ear knows"
                ]
            ),
            PracticeItem(
                catalogID: "ear_training_straight_swing",
                category: .ear_training,
                title: "Straight vs Swing",
                detail: "Feel the groove",
                srs: baseState,
                coreInstructions: [
                    "Play eighth notes straight, then swung",
                    "Feel the triplet pulse in swing"
                ],
                bonusTips: [
                    "Tap your foot to the quarter note",
                    "Swing = long-short, not even",
                    "Listen to blues and jazz",
                    "Count 'tri-pl-et' for swing feel"
                ],
                focusCues: [
                    "Groove lives in the timing",
                    "Swing hard or go home"
                ]
            ),
            PracticeItem(
                catalogID: "ear_training_interval_feel",
                category: .ear_training,
                title: "Interval Feel",
                detail: "Recognize intervals",
                srs: baseState,
                coreInstructions: [
                    "Play 2 notes, name the interval",
                    "Start with major/minor 3rds and 5ths"
                ],
                bonusTips: [
                    "Associate intervals with familiar songs",
                    "Sing the interval before playing",
                    "Practice ascending and descending",
                    "Wide intervals = bigger emotional impact"
                ],
                focusCues: [
                    "Intervals have personality",
                    "Hear the color"
                ]
            ),

            // Musicality items
            PracticeItem(
                catalogID: "musicality_dynamics",
                category: .musicality,
                title: "Dynamic Control",
                detail: "Quiet → loud",
                srs: baseState,
                coreInstructions: [
                    "Play a phrase pp, then ff",
                    "Control volume with pick attack"
                ],
                bonusTips: [
                    "Practice crescendo over 4 bars",
                    "Soft doesn't mean slow",
                    "Loud doesn't mean harsh",
                    "Use dynamics to tell a story",
                    "Record yourself to hear the difference"
                ],
                focusCues: [
                    "Whisper, then shout",
                    "Dynamics = emotion"
                ]
            ),
            PracticeItem(
                catalogID: "musicality_slow_vibrato",
                category: .musicality,
                title: "Controlled Vibrato",
                detail: "Slow & expressive",
                srs: baseState,
                coreInstructions: [
                    "Bend a sustained note slowly",
                    "Even waves, wrist-driven"
                ],
                bonusTips: [
                    "Count 1-2-3-4 per vibrato wave",
                    "Vary width: narrow for subtle, wide for intense",
                    "Listen to Gilmour and Clapton",
                    "Match vibrato to the song mood"
                ],
                focusCues: [
                    "Slow = control",
                    "Sing through the bend"
                ]
            ),
            PracticeItem(
                catalogID: "musicality_bend_accuracy",
                category: .musicality,
                title: "Bend Accuracy",
                detail: "Half-step precision",
                srs: baseState,
                coreInstructions: [
                    "Bend to target pitch, check with fretted note",
                    "Half-step = 1 fret, whole-step = 2 frets"
                ],
                bonusTips: [
                    "Play target note first to hear it",
                    "Bend slowly to develop muscle memory",
                    "Use 3 fingers for support",
                    "Sharp bends sound amateurish",
                    "Flat bends kill the vibe"
                ],
                focusCues: [
                    "Pitch perfect or nothing",
                    "Your ear is the tuner"
                ]
            ),
            PracticeItem(
                catalogID: "musicality_tone_touch",
                category: .musicality,
                title: "Tone & Touch",
                detail: "Pick attack variation",
                srs: baseState,
                coreInstructions: [
                    "Play same phrase with different pick angles",
                    "Experiment: soft/hard, near bridge/neck"
                ],
                bonusTips: [
                    "Bridge = bright and cutting",
                    "Neck = warm and mellow",
                    "Softer touch = rounder tone",
                    "Harder attack = more aggression",
                    "Mix positions within a phrase"
                ],
                focusCues: [
                    "Tone is in the hands",
                    "Paint with your pick"
                ]
            )
        ]
    }
}
