# Musicalism

Music theory in plain Ruby: notes, scales, chords, keys, and the paths between keys.

Musicalism answers harmonic questions so that a live-coding engine can play the answers. Ask it for the V chord of A minor, the pivot chord between C major and G major, or the shortest smooth route from C major to F# major. It gives back notes with octaves and MIDI numbers, ready to send as note-ons. It has no runtime dependencies, no clock and no I/O.

It was written for [rcoremidi](https://github.com/StupidCodeFactory/rcoremidi), whose clips and key journeys are built on it.

```ruby
key = Musicalism::Key['C major']
key.modulate_to('G major', via: :vi).map(&:to_s)
# => ["C major", "A minor", "D major", "G major"]
key.modulate_to('G major', via: :vi).map(&:to_midi)
# => [[60, 64, 67], [60, 64, 69], [62, 66, 69], [62, 67, 71]]   voice-led
```

## Installation

Musicalism needs Ruby 4.0 or later. It is not on RubyGems yet, so take it from GitHub:

```ruby
gem 'musicalism', github: 'StupidCodeFactory/musicalism', tag: 'v0.1.0'
```

## Notes

```ruby
note = Musicalism::Note.new('C#4')   # or Note.new('C#', 4)
note.pitch    # => "C#"
note.octave   # => 4
note.to_midi  # => 61
note.next     # => D4

Musicalism::Note.new('B#3') == Musicalism::Note.new('C4')   # => true, enharmonic notes are equal
Musicalism::Note.from_midi(61)                              # => C#4
```

Notes cover the piano range, A0 to C8, in scientific pitch notation (C4 = 60). The octave belongs to the letter, so B#3 and C4 are both MIDI 60. A note outside the range raises `Musicalism::Note::UnkownNoteError`.

## Scales

```ruby
Musicalism::MajorScale.new('D').notes          # => D4 E4 F#4 G4 A4 B4 C#5
Musicalism::MajorScale.new('Bb').alterations   # => ["Bb", "Eb"]
```

`MajorScale`, `MinorScale` (natural), `HarmonicMinorScale` and `MelodicMinorScale` (ascending) spell each degree with the next letter name, so `MajorScale.new('E#')` uses C##.

## Keys

`Key` is the main API. `Scale` is the layer underneath it.

```ruby
key = Musicalism::Key['C major']      # or Key.major('C'), Key.minor('A'), Key['F# minor']

key.relative          # => A minor
key.parallel          # => C minor
key.dominant_key      # => G major
key.subdominant_key   # => F major
key.signature         # => []
key.note(5)           # => G4
key.note(9)           # => D5   (degrees past 7 go up an octave)
```

Two keys are equal when the tonic is spelled the same and the mode matches, so `Key['Db major'] != Key['C# major']`.

### Chords by roman numeral

```ruby
key.chord(:V)                    # => G major, G4 B4 D5
key.chord(:V).to_midi            # => [67, 71, 74]
key.chord(:vi, inversion: 1)     # => C5 E5 A5
Musicalism::Key['A minor'].chord(:V)   # => E major (V and vii come from harmonic minor)

key.numerals                     # => [:I, :ii, :iii, :IV, :V, :vi, :vii]
key.chords(:subdominant)         # => F major, D minor, A minor
```

`chord` accepts numerals in either case. `chords` groups the triads by harmonic function, primary chord first:

| Function    | Degrees     |
|-------------|-------------|
| tonic       | I, vi, iii  |
| subdominant | IV, ii, vi  |
| dominant    | V, vii      |

### Chords

```ruby
chord = Musicalism::Chord.new(%w[E4 G4 C5].map { |name| Musicalism::Note.new(name) })
chord.to_s         # => "C major"   (any inversion)
chord.quality      # => :major
chord.inverse(1)   # => G4 C5 E5, the lowest note moves up an octave
```

`voiced_near(previous)` picks the inversion and octave that moves the fewest semitones from the chord before it. `Chord.voice_lead(chords)` applies that along a progression.

## Modulation

```ruby
key = Musicalism::Key['C major']

key.pivot_chords('G major').map(&:to_s)
# => ["A minor: vi in C major = ii in G major",
#     "E minor: iii in C major = vi in G major",
#     "C major: I in C major = IV in G major",
#     "G major: V in C major = I in G major"]

key.modulate_to('G major')                     # I, a random pivot, V, I of G major
key.modulate_to('G major', via: :vi)           # choose the pivot by its numeral in C major
key.modulate_to('G major', random: Random.new(4))
key.modulate_to('G major', voice_leading: false)
```

The pivot is drawn at random from the shared chords that are tonic in neither key, so repeated modulations vary. Seed `random:` to repeat one. The chords are voice-led unless you pass `voice_leading: false`.

## The key graph

Each step on the graph modulates to the dominant, subdominant or relative key, and each step always has a pivot chord. The graph tells you how far apart two keys are and how to get from one to the other.

```ruby
key.closely_related              # => G major, F major, A minor
key.distance_to('F# major')      # => 6
key.farthest_distance            # => 7
key.keys_at(2)                   # => D major, E minor, Bb major, D minor

key.path_to('F# major', random: Random.new(1))
# => C major, F major, Bb major, Eb major, Ab major, Db major, F# major

key.modulate_through(key.path_to('D major'))
# => C major, E minor, D major, G major, B minor, A major, D major
```

`path_to` picks one of the shortest routes at random. `modulate_through` chains modulations along any list of keys, respelling enharmonic keys so that crossing from F# major to Db major still uses a pivot. `Key.major('C#').simplest_spelling` returns Db major.

Musicalism never decides where to go next. Walking the graph, and choosing the direction and timing, is up to the caller, for example rcoremidi's journeys.

## Micro modulations

These are short tonicizations that borrow from a passing key without leaving the current one:

```ruby
key.tonicize(:ii)              # => D minor, the local key on ii
key.secondary_dominant(:V)     # => D major, which is V/V
key.two_five(:IV)              # => G minor, C major: ii and V leading to F
```

## With rcoremidi

rcoremidi walks the key graph like an arpeggiator whose notes are keys. Clips follow the walk bar by bar:

```ruby
RCoreMidi::Journey.register :voyage, from: 'C major', mode: :up_down, range: 3, rate: 4

RCoreMidi::Clip.register :pads do
  follow :voyage do |key, step|
    chord key.chord(:I), 16, [1] + [0] * 15
    chord key.secondary_dominant(:V), 16, [0] * 12 + [1, 0, 0, 0] if step.farthest? && step.last_bar?
  end
end
```

See rcoremidi's `script/journey_demo` for a full example.

## Development

```bash
bundle install
bundle exec rspec
script/console
```

## Releasing

Versions follow [semantic versioning](https://semver.org). A push to master publishes nothing on its own. The gem is published only when a `vMAJOR.MINOR.PATCH` tag is pushed:

1. Bump `Musicalism::VERSION` in `lib/musicalism/version.rb` and merge to master.
2. Tag the merge commit on master and push the tag:

   ```bash
   git tag -a v0.2.0 -m "musicalism 0.2.0"
   git push origin v0.2.0
   ```

The `Release gem` workflow (`.github/workflows/release.yml`) then checks that the tag matches `Musicalism::VERSION` and points at a commit on master. It runs the specs, builds the gem and pushes it to RubyGems. If any check fails, nothing is published.

It authenticates with RubyGems trusted publishing, so no API key is stored in the repository. Set it up once on rubygems.org: add a trusted publisher (a pending one before the first release) for the repository `StupidCodeFactory/musicalism`, the workflow `release.yml` and the environment `rubygems`.

## License

MIT, see [LICENSE](LICENSE).
