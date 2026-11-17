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
- `Note.new` takes `"E5"` or `("E", 5)`. rcoremidi (`../rcoremidi/lib/rcoremidi/note.rb`) uses the two-argument form.
- `transpose(semitones)` returns an **array** of `Note`s, one per enharmonic spelling. The octave is dropped (each result uses the default octave). Callers pick the spelling they need.

### Interval (`lib/musicalism/interval.rb`)

Instance methods that return semitone counts (`major_third` gives 4). Enharmonic names are aliases. Use as `Interval.new.perfect_fifth`.

### Scale (`lib/musicalism/scale.rb`, `scale/*.rb`)

- Each subclass defines a private `scale_structure`: the six semitone distances from the root. `HarmonicMinorScale` and `MelodicMinorScale` (ascending form) subclass `MinorScale` and replace the last intervals. `Scale` itself has no structure, so do not instantiate it directly.
- `notes` gives each degree the next letter name, picked from the enharmonic options `transpose` returns. That is why `MajorScale.new("E#")` spells with `C##`. The octave goes up when the letter reaches C, so notes always rise from the root (`G4 .. F#5`).
- `alterations` lists the altered pitches of the scale in key-signature order: flats B E A D G C F, then sharps F C G D A E B. For harmonic and melodic minor it includes the raised degrees, so it is not a key signature for those.
- Degree chords (`tonic_chord` .. `subtonic_chord`) stack thirds over the scale laid out across two octaves, so every triad rises from its root. Some method names use the French spelling (`subdominante_chord`, `dominante_chord`).

### Chord (`lib/musicalism/chord.rb`)

Wraps an ordered array of `Note`s. Each inversion step moves the lowest note up an octave. `==` compares the note arrays.

## Specs

- `spec/musicalism/note_spec.rb` uses `expect` syntax and `rspec-its`. Follow it for new specs.
- `spec/scale_spec.rb` drives its cases from tables of scale, root and expected notes. Add a row rather than a new example.
