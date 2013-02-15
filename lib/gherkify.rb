require 'gherkify/version'
require 'gherkify/feature'
require 'yuml_diagram'

require 'gherkin/parser/parser'
require 'gherkin/formatter/json_formatter'
require 'stringio'
require 'json'


module Gherkify

  # Parses feature files
  #
  # @param files [Array] the array of feature files to be parsed
  # @return [Array] the array of parsed features
  def self.parse_files(files)
    io = StringIO.new
    formatter = Gherkin::Formatter::JSONFormatter.new(io)
    parser = Gherkin::Parser::Parser.new(formatter)

    files.each do |path|
      parser.parse(IO.read(path), path, 0)
    end

    formatter.done
    # ap JSON.parse(io.string, :symbolize_names => true)
    f_data = JSON.parse(io.string, :symbolize_names => true)
    features = []

    f_data.each { |e| features << Gherkify::Feature.new(e)  }

    features
  end

  # Parses feature file
  #
  # @param file [String] the path to feature file to be parsed
  # @return [Array] the array of parsed features
  def self.parse_file(file)
    self.parse_files([file])
  end

  def self.hello
    "Hello"
  end

end
