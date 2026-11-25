# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`musicalism` is a small Ruby gem for music theory: notes, intervals, scales and triads. No runtime dependencies.

## Commands

Ruby 4.0.9 (`.ruby-version`). Non-interactive shells on this machine resolve to system Ruby 2.6, where `bundle install` fails. Prefix commands with `chruby-exec ruby-4.0.9 --`:

- `chruby-exec ruby-4.0.9 -- bundle install`
- `chruby-exec ruby-4.0.9 -- bundle exec rspec` - run all specs
- `chruby-exec ruby-4.0.9 -- bundle exec rspec spec/musicalism/note_spec.rb:LINE` - run one example
- `script/console` - IRB with the gem loaded

No linter is declared in the gemspec.

## Architecture

`lib/musicalism.rb` requires everything except `rythm.rb` (empty placeholder).

### Note (`lib/musicalism/note.rb`)

- `pitch` is a string that includes the alteration (`'C#'`, `'Bbb'`). `alteration` is the suffix only. `octave` is an integer, default `DEFAULT_CENTER_OCTAVE` (4).
- `NOTES` is 12 groups of enharmonic spellings, one per semitone. Index 0 is **A**, not C. All semitone math (`transpose`, `interval_from`, `pitch_index`) works on this index.
- `NOTE_PARSER` limits input to the piano/MIDI range A0..C8. Each regex branch handles one edge of that range. Invalid input raises `Note::UnkownNoteError` (spelling is intentional, specs use it).
- `to_midi` uses scientific pitch notation (C4 = 60, A0 = 21). The octave belongs to the letter, so `B#3` = `C4` = 60 and `Cb4` = `B3` = 59.
- Equality comes from `Comparable` on `to_midi`, so enharmonic notes are equal (`Note.new('C##') == Note.new('D')`). Specs that compare notes check pitch, not spelling.
- `next` returns the note one semitone up, built by `Note.from_midi`, which always spells with a natural or a single sharp. Past C8 it raises `UnkownNoteError`.
- `Note.new` takes `"E5"` or `("E", 5)`. archaeopteryx (`../archaeopteryx/lib/archaeopteryx/note.rb`) uses the two-argument form.
- `transpose(semitones)` returns an **array** of `Note`s, one per enharmonic spelling. The octave is dropped (each result uses the default octave). Callers pick the spelling they need.

### Interval (`lib/musicalism/interval.rb`)

Instance methods that return semitone counts (`major_third` gives 4). Enharmonic names are aliases. Use as `Interval.new.perfect_fifth`.

### Scale (`lib/musicalism/scale.rb`, `scale/*.rb`)

- Each subclass defines a private `scale_structure`: the six semitone distances from the root. `HarmonicMinorScale` and `MelodicMinorScale` (ascending form) subclass `MinorScale` and replace the last intervals. `Scale` itself has no structure, so do not instantiate it directly.
- `notes` gives each degree the next letter name, picked from the enharmonic options `transpose` returns. That is why `MajorScale.new("E#")` spells with `C##`. The octave goes up when the letter reaches C, so notes always rise from the root (`G4 .. F#5`).
- `alterations` lists the altered pitches of the scale in key-signature order: flats B E A D G C F, then sharps F C G D A E B. For harmonic and melodic minor it includes the raised degrees, so it is not a key signature for those.
- `degree_chord(degree, inversion:)` takes a name from `Scale::DEGREES` (`:tonic` .. `:subtonic`) and stacks thirds over the scale laid out across two octaves, so every triad rises from its root.

### Chord (`lib/musicalism/chord.rb`)

Wraps an ordered array of `Note`s. Each inversion step moves the lowest note up an octave. `==` compares the note arrays. `to_midi` returns the MIDI numbers, ready for archaeopteryx note-ons. `quality`, `root` and `to_s` ("A minor") recognise triads in any inversion by trying each rotation. They return `nil` (or the plain pitches) when the notes are not a triad.

`voiced_near(previous)` returns the same chord in the inversion and octave (within two octaves either way) whose notes move the fewest semitones from `previous`. Voicings outside A0..C8 are skipped. `Chord.voice_lead(chords)` applies that along a progression, keeping the first chord as given.

### Key (`lib/musicalism/key.rb`)

This is the API archaeopteryx should use, so keep it readable. `Scale` is the lower layer underneath it.

- Build with `Key.major('C')`, `Key.minor('A')` or `Key['F# minor']`. Equality compares tonic spelling and mode, not octave, so `Db major` is not `C# major`.
- `chord(numeral, inversion:)` takes `:I`..`:VII` in any case. In minor keys, V and vii° come from harmonic minor (E major in A minor). Every other degree comes from natural minor.
- `chords(function)` groups chords by harmonic function, primary chord first: tonic I vi iii, subdominant IV ii vi, dominant V vii°. With no argument it returns all seven triads.
- `dominant_key` / `subdominant_key` are the neighbouring keys on the circle of fifths. They are not chord functions. The tonic keeps its octave number, so walking the circle never leaves the MIDI range.
- `relative` puts the relative minor a minor third below (C4 major gives A3 minor), so `relative.relative` returns the same octave.
- `note(degree)` counts from 1. Degrees past 7 go into the next octaves.
- `numerals` writes each degree in the case that matches its chord quality (`:I, :ii, ... :vii`). `chord` accepts them back in any case.

### Key graph (`Key#closely_related`, `#distance_to`, `#path_to`, `#modulate_through`)

musicalism answers questions about the graph. It never decides where to go: walking it (arpeggiator modes, direction, bars) belongs to archaeopteryx.

- A step is a modulation to the dominant, subdominant or relative key. `closely_related` returns those three, respelled with `simplest_spelling` (fewest accidentals in the signature; a tie keeps the current spelling, so F# stays F#) and with the tonic octave number of the starting key, so long walks never drift out of range.
- The graph compares keys by pitch class and mode (protected `enharmonic_to?`). `Key#==` still compares spelling.
- `distance_to`, `keys_at(distance)` and `farthest_distance` come from a breadth-first search over all 24 keys, recomputed on each call. From C major, F# is at 6 and the farthest minor keys at 7.
- `path_to(destination, random:)` picks one shortest path at random (seed it to repeat). It starts with the key itself and ends with the destination as spelled by the caller.
- `modulate_through(keys)` chains `modulate_to` along the keys, sharing the I chord between two hops, voice-led unless `voice_leading: false`. Each hop respells the next key to share the most chords with the current one, so crossing the enharmonic seam (F# major to Db major) still goes through a pivot. Pass `key.path_to(destination)` to reach a distant key smoothly.

### Micro modulations (`Key#tonicize`, `#secondary_dominant`, `#two_five`)

Short tonicizations that leave the key itself unchanged. `tonicize(:ii)` returns the local key built on that degree's chord (D minor in C major, keeping the chord root's octave). Its mode comes from the chord quality, so in minor keys V tonicizes the harmonic-minor major chord. A diminished or augmented degree raises `ArgumentError`. `secondary_dominant(numeral)` is that local key's V (V/V in C is D major), and `two_five(numeral)` its ii and V (a minor target gets ii°).

### Modulation (`Key#pivot_chords`, `Key#modulate_to`, `lib/musicalism/pivot.rb`)

- Both methods accept a `Key` or a name (`'G major'`) through `Key.coerce`.
- `pivot_chords(destination)` returns `Pivot` values (`chord`, `from_numeral`, `to_numeral`, and `to_s` like `"A minor: vi in C major = ii in G major"`) for the chords both keys spell the same way. Enharmonic matches do not count. Order: chords that are IV, ii or vi in the new key come first, then chords that are tonic in neither key, then chords that are I in either key.
- `modulate_to(destination, via:, random:, voice_leading:)` returns the chords I, pivot, V of the new key, I of the new key.
  - By default the pivot is drawn at random from the shared chords that are tonic in neither key, so repeated calls vary. Pass `random: Random.new(seed)` to repeat a choice.
  - `via:` picks the pivot yourself: either a numeral in the key you leave (`via: :vi`, any case) or a `Pivot` from `pivot_chords`. Only `via:` can use a tonic chord as the pivot.
  - With no usable pivot, the progression goes straight from I to V and I of the new key.
  - The chords are voice-led from the opening I (C4 E4 G4, C4 E4 A4, D4 F#4 A4, D4 G4 B4 for C to G via vi). `voice_leading: false` returns every chord in root position in its own key's octave. archaeopteryx's `Clip#modulate` passes `voice_leading:` through and its specs pin the voice-led chords, so change both repos together.

## Specs

- `spec/musicalism/note_spec.rb` uses `expect` syntax and `rspec-its`. Follow it for new specs.
- `spec/scale_spec.rb` drives its cases from tables of scale, root and expected notes. Add a row rather than a new example.
