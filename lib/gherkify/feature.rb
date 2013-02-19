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

  def scenario_tags(scenario)
    return [] if scenario[:tags].nil?
    scenario[:tags].collect { |e| e[:name] }
  end

  def scenarios
    @data[:elements].select do |e| 
      is_scenario = e[:keyword] == 'Scenario'
      ignore = scenario_tags(e).include?('@gherkify-ignore')
      is_scenario && !ignore
    end
  end

  def scenario_name(scenario)
    trim(scenario[:name])
  end

  def scenarios_names
    scenarios.collect { |e| scenario_name(e) }
  end

  def ui_elements
    yuml.collect_ui_elements(scenarios)
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
    s << "Activities:"

    scenarios.each do |e|
      name = scenario_name(e)
      activity = yuml.activity(e)
      s << "#{name} #{activity.md5}:"
      s << "#{activity.to_s}"
    end

    # s << "UI elements:"
    # s << "#{ui_elements.inspect}" 

    s * "\n"
  end

  private
  def trim(text)
    text.strip
  end
  
end