require 'yuml'

class Gherkify::FeatureYuml

  def initialize(feature, options={})
    @feature = feature
    @options = {
      show_notes: false,
      scale: 75
    }.merge options
  end

  def use_case
    note = @feature.note if @options[:show_notes]
    self.class.use_case(@feature.actor, @feature.name, @feature.scenarios_names, note, @options[:scale])
  end

  def activity(scenario)
    self.class.activity(scenario, @options[:scale])
  end

  def self.trim!(*args)
    args.each { |text| text.replace trim(text) }
  end

  def self.trim(text)
    # text.gsub!('-', '‐') # yUML '-' bug
    text.gsub(/[,()\[\]^><-]/, '').strip
  end

  def self.use_case_old(actor, feature, scenarios, note=nil)
    trim!(actor, feature, note)

    t = []
    t << "[#{actor}]-(note: #{note}{bg:beige})" if note
    t << "[#{actor}]-(#{feature})"
    scenarios.each do |scenario| 
      trim!(scenario)
      t << "(#{feature})<(#{scenario})"
    end

    t * ', '
  end

  def self.use_case(actor, feature, scenarios_names, note=nil, scale=75)
    YUML::useCaseDiagram( :scruffy, :scale => scale ) {
      _[actor] - note(note) if note
      _[actor] - _(feature)
      scenarios_names.each do |scenario|
        _(feature) < _(scenario) 
      end
    }
  end

  def self.activity_old(scenario)
    steps = scenario[:steps]
    t = []

    t_steps = []
    t_results = []

    do_results = false

    t << "(start)"

    steps.each do |e|

      if e[:keyword].strip == 'Then'
        do_results = true
      end

      step = trim(e[:name])
      if e[:keyword].strip == 'Given'
        t << "[#{step}]"
      else
        step.sub!(/^I /i, '')
        if do_results
          t_results << "|b|->(#{step})->|c|"
        else
          t_steps << "(#{step})"
        end
        
      end
    end

    t << t_steps * '->'
    t << '|b|'

    t_start_s = t * '->'
    t_results_s = t_results * ','
    t_end_s = "|c|->(end)"

    return t_start_s + ',' + t_results_s + ',' + t_end_s
  end

  def self.activity(scenario, scale=75)
    steps = scenario[:steps]
    yuml = YUML::activityDiagram( :scruffy, :scale => scale ){}

    t_steps = []
    t_results = []

    do_results = false

    t_steps << yuml._(:start).to_s

    steps.each do |e|

      if e[:keyword].strip == 'Then'
        do_results = true
      end

      step = trim(e[:name])
      if e[:keyword].strip == 'Given'
        t_steps << yuml._[step].to_s
      else
        step.sub!(/^I /i, '')
        if do_results
          t_results << "|b|->" + yuml._(step).to_s + "->|c|"
        else
          t_steps << yuml._(step).to_s
        end
        
      end
    end

    t_steps << '|b|'
    yuml.link_s t_steps * '->'

    t_results.each { |e| yuml.link_s e }

    yuml.link_s ((do_results) ? "|c|" : "|b|") + "->(end)"

    yuml

  end

end