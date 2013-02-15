require 'gherkify/feature/yuml'

class Gherkify::Feature
  def initialize(feature, options={})
    @data = feature

    @options = {
      show_notes: false
    }.merge options
  end
  
  def actor
    @data[:description].split("\n").each do |e|
      if e =~ /^as a/i
        actor = e.sub(/^as a/i, '').sub(/,$/, '').strip
        return trim(actor)
      end
    end
    return "Actor"
  end

  def note
    t = @data[:description].split("\n").select { |e| true unless e =~ /^As a/i } * "\n"
    trim(t)
  end

  def name
    trim(@data[:name])
  end

  def scenarios
    @data[:elements].select { |e| e[:keyword] == 'Scenario' }
  end

  def scenarios_names
    scenarios.collect { |e| trim(e[:name]) }
  end

  def yuml
    @yuml ||= Gherkify::FeatureYuml.new(self)
  end

  def to_s
    s = []
    s << "Feature: #{name}"

    use_case = yuml.use_case
    s << "Use Case: #{use_case.md5}"
    s << use_case.to_s
    s << "Activities: "

    scenarios.each do |e|
      activity = yuml.activity(e)
      s << "#{activity.md5}:"
      s << "#{activity.to_s}"
    end

    s * "\n"
  end

  private
  def trim(text)
    text.strip
  end
  
end