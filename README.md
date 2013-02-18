# Gherkify

Generate yUML diagrams and other stuff from Gherkin Cucumber feature files

Sample output: http://kalapun.com/portfolio/tmp/gherkin/

## Installation

You need `ruby-yuml`, which is currently not published on ruby-gems, so to install it use  `specific_install`

    gem install specific_install
    gem specific_install -l https://github.com/xslim/ruby-yuml.git

Add this line to your application's Gemfile:

    gem 'gherkify'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gherkify

## Usage

Usage: `gherkify path_to_features -d output_directory`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
