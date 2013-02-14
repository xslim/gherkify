require 'gherkify/version'
require 'gherkify/feature'

require 'gherkin/parser/parser'
require 'gherkin/formatter/json_formatter'
require 'stringio'
require 'json'
require 'digest/md5'


module Gherkify

  # Parses feature files
  #
  # @param files [Array] the array of feature files to be parsed
  # @return [Array] the array of parsed features
  def self.parse_files(files)
    
  end

  # Parses feature file
  #
  # @param file [String] the path to feature file to be parsed
  # @return [Array] the array of parsed features
  def self.parse_file(file)
    # self.parse_files([file])
  end

  def self.hello
    "Hello"
  end

end
