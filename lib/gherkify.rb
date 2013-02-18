require 'gherkify/version'
require 'gherkify/feature'
require 'yuml_diagram'

require 'gherkin/parser/parser'
require 'gherkin/formatter/json_formatter'
require 'stringio'
require 'json'


class Gherkify

  def initialize(files, options={})
    @files = files

    @options = {
      show_notes: false,
      output_dir: '.'
    }.merge options
  end

  # Parses feature files
  #
  # @param files [Array] the array of feature files to be parsed
  # @return [Array] the array of parsed features
  def self.parse_files(files, options={})
    Gherkify.new(files, options)
  end

  # Parses feature file
  #
  # @param file [String] the path to feature file to be parsed
  # @return [Array] the array of parsed features
  def self.parse_file(file)
    self.parse_files([file])
  end

  def features
    @features ||= parse
  end

  def parse
    parse_files
  end

  def parse_files(files=nil)
    files = @files if files.nil?

    io = StringIO.new
    formatter = Gherkin::Formatter::JSONFormatter.new(io)
    parser = Gherkin::Parser::Parser.new(formatter)

    files.each do |path|
      parser.parse(IO.read(path), path, 0)
    end

    formatter.done
    # ap JSON.parse(io.string, :symbolize_names => true)
    features_data = JSON.parse(io.string, :symbolize_names => true)
    @features = features_data.collect { |e| Gherkify::Feature.new(e)  }
  end

  def check_and_fetch_diagram(diagram, pngs, output_dir)
    unless pngs.include? "#{diagram.md5}.png"
      puts "Fetching yuml to #{output_dir}/#{diagram.md5}.png"
      diagram.to_png("#{output_dir}/#{diagram.md5}.png")
    end
  end

  def fetch_diagram_images
    output_dir = @options[:output_dir]

    pngs = []
    Dir.chdir(output_dir) do
      pngs = Dir.glob("*.png")
    end

    features.each do |feature|
      use_case = feature.yuml.use_case
      check_and_fetch_diagram(use_case, pngs, output_dir)
      
      feature.scenarios.each do |e|
        activity = feature.yuml.activity(e)
        check_and_fetch_diagram(activity, pngs, output_dir)
      end
    end

  end

  def to_s
    s = []
    features.each { |e| s << e.to_s }
    s * "\n"
  end

  def to_md(file=nil)

    fetch_diagram_images

    output_dir = @options[:output_dir]

    s = []
    s << "## Features"
    features.each do |feature|
      s << "### #{feature.name}"

      use_case = feature.yuml.use_case
      # s << "*TODO: Fetch and store use_case by MD5: #{use_case.md5}*"
      s << ''
      # s << "```\n#{use_case.to_s}```"
      s << "![#{feature.name}](#{use_case.md5}.png)"

      feature.scenarios.each do |e|
        name = feature.scenario_name(e)
        activity = feature.yuml.activity(e)
        s << "- **#{name}**"
        # s << "*TODO: Fetch and store activity by MD5: #{activity.md5}*"
        s << ''
        # s << "```\n#{activity.to_s}```"
        s << "![#{name}](#{activity.md5}.png)"
      end
    end
    s = s * "\n"
    return s if file.nil?

    writer = open(File.join(output_dir, file), "wb")
    writer.write(s)
    writer.close

  end

end
