# Same person guesser

## Setup

```
$ asdf install # or install via rbenv etc
$ bundle install
```

## Use

Check below's help command for usage

```
$ ./bin/same_person_guesser.rb help guess_by_matching_type
```

### Examples

```
# minimum example
$ ./bin/same_person_guesser.rb guess_by_matching_type \
    --input-file-destination './examples/inputs/input1.csv'

# specifing matching type
$ ./bin/same_person_guesser.rb guess_by_matching_type \
    --input-file-destination './examples/inputs/input1.csv' \
    --matching-type 'same_phone'

# specifing output file name and destination
$ ./bin/same_person_guesser.rb guess_by_matching_type \
    --input-file-destination './examples/inputs/input1.csv' \
    --matching-type 'same_phone' \
    --output-file-destination './examples/output.csv'
```

## Development

### Test

```
$ bundle exec rspec spec
```
