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

  def self.use_case(actor, feature, scenarios_names, note=nil, scale=75)
    YUML::useCaseDiagram( :scruffy, :scale => scale ) {
      _[actor] - note(note) if note
      _[actor] - _(feature)
      scenarios_names.each do |scenario|
        _(feature) < _(scenario) 
      end
    }
  end

  def self.dump_activity_steps(yuml, steps, type, connector=nil, prev_step=nil, final_steps)
    ok = []
    c1 = connector || 'a'
    c2 = (c1..'zz').to_a[1]
    last_step = nil
    # puts "connector: #{connector}, #{c1} -> #{c2}"
    use_connector = !connector.nil? || false
    prev_step = nil if !connector.nil?

    prev_step_n = final_steps.count - 1
    prev_step_line = final_steps[prev_step_n]

    case type 
    when :given
      if steps.count > 1
        use_connector = true
        final_steps[prev_step_n] = prev_step_line + "->|#{c1}|" if !prev_step.nil?
        ok += steps.collect { |e| "|#{c1}|->#{yuml._[e].to_s}->|#{c2}|" }
      else
        text = yuml._[steps.first].to_s
        last_step = text
        ok << "|#{c1}|->#{text}->|#{c2}|" if use_connector
        if use_connector
          last_step = nil
          final_steps[prev_step_n] = prev_step_line + "->|#{c1}|"
        else
          final_steps[prev_step_n] = prev_step_line + "->#{text}"  
        end
      end
    when :when
      text_steps = steps.collect { |e| yuml._(e).to_s }
      last_step = text_steps.last
      text = text_steps * '->'
      ok << "|#{c1}|->#{text}->|#{c2}|" if use_connector

      if !prev_step.nil?
        if use_connector
          last_step = nil
          final_steps[prev_step_n] = prev_step_line + "->|#{c1}|"
        else
          final_steps[prev_step_n] = prev_step_line + "->#{text}"
        end
      end
    when :then
      use_connector = true
      final_steps[prev_step_n] = prev_step_line + "->|#{c1}|" if !prev_step.nil?
      ok += steps.collect { |e| "|#{c1}|->#{yuml._(e).to_s}->|#{c2}|" }
    end

    {
      steps: ok,
      last_step: last_step,
      connector: (use_connector ? c2 : nil),
      c1: c1,
      c2: c2
    }
  end

  def optimize_activity_steps(steps)
    steps.each_with_index do |e, i|

    end
    steps
  end

  def self.activity(scenario, scale=75)
    ssteps = scenario[:steps]
    yuml = YUML::activityDiagram( :scruffy, :scale => scale ){}

    t_steps = []
    t_results = []

    steps = {}
    steps[:ok]    = []
    steps[:given] = [] # >1 huh?
    steps[:when]  = []
    steps[:then]  = []

    curr_step = :trash
    prev_step = :trash
    strip_i = true

    do_results = false
    prev_connector = nil
    first_step = true
    last_step = nil

    num_steps = ssteps.count

    # start with start
    steps[:ok] << yuml._(:start).to_s

    ssteps.each_with_index do |e, i|
      step = trim(e[:name])

      # puts "key: #{e[:keyword]}"
      case e[:keyword].strip 
      when 'Given'
        curr_step = :given
      when 'When'
        curr_step = :when
      when 'Then'
        curr_step = :then
      when 'And'
        curr_step = prev_step
      end

      if curr_step != prev_step && prev_step != :trash
        # dump previous steps
        last_step = nil if prev_connector
        
        dumped = dump_activity_steps(yuml, steps[prev_step], prev_step, prev_connector, last_step, steps[:ok])
        curr_connector  = dumped[:connector]
        dumped_steps    = dumped[:steps]
        last_step       = dumped[:last_step]
        steps[:ok]     += dumped_steps

        # Clean steps
        steps[prev_step] = []
        prev_connector = curr_connector

        first_step = false
      end

      # collect next data
      step.sub!(/^I /i, '') if strip_i
      steps[curr_step] << step

      # dump the last one
      if i == num_steps-1
        last_step = nil if prev_connector
        dumped = dump_activity_steps(yuml, steps[curr_step], prev_step, prev_connector, last_step, steps[:ok])
        curr_connector  = dumped[:connector]
        dumped_steps    = dumped[:steps]
        last_step       = dumped[:last_step]
        steps[:ok]     += dumped_steps
        
        # Clean steps
        steps[prev_step] = []
        prev_connector = curr_connector
      end

      prev_step = curr_step
    end

    steps[:ok] << ((prev_connector.nil?) ? last_step : "|#{prev_connector}|") + "->(end)"

    # final_steps = optimize_activity_steps(steps[:ok])

    steps[:ok].each do |e|
      yuml.link_s e
    end

    yuml
  end

end