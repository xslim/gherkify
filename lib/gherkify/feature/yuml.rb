require 'yuml'

class Gherkify::FeatureYuml

  # TODO: reconsider 'list'
  MATCH_SCREEN_REGEXP = /(on|at|enter|open|view) (a |the )?(any |first )?(?<name>.+) (screen|page|view|list)/
  MATCH_SCREEN_NAME_REGEXP = /(['"](?<name>.+)['"]) (?<type>.+)/
  MATCH_BUTTON_REGEXP = /(touch|click|press|press) (on |at |a |the )?(any |first |last )?(?<name>.+) (?<type>on|button|control|tab|tabbar|row)$/

  def initialize(feature, options={})
    @feature = feature
    @options = {
      show_notes: false,
      scale: 75
    }.merge options
    @ui_screens = {}
    @ui_last_screen = nil
  end

  def use_case
    note = @feature.note if @options[:show_notes]
    self.class.use_case(@feature.actor, @feature.name, @feature.scenarios_names, note, @options[:scale])
  end

  def activity(scenario)
    self.class.activity(scenario, @options[:scale])
  end

  def collect_ui_elements(scenarios)
    scenarios.each do |scenario|
      ui_connection = nil
      ssteps = scenario[:steps]
      ssteps.each do |e|
        step = e[:name].strip
        step_keyword = e[:keyword].strip 

        match_data = MATCH_SCREEN_REGEXP.match(step)
        if match_data
          screen_name = match_data[:name]
          match_data_double_name = MATCH_SCREEN_NAME_REGEXP.match(screen_name)
          if match_data_double_name
            screen_name = match_data_double_name[:type]
          end
          ui_connection = @ui_last_screen if @ui_last_screen
          # TODO: lowercase?
          screen_name.sub!(/^['"](?<name>.+)['"]$/, '\k<name>')
          @ui_screens[screen_name] = { buttons: [], connections: [] } if @ui_screens[screen_name].nil?
          @ui_last_screen = screen_name

          if ui_connection && ui_connection != @ui_last_screen && !@ui_screens[@ui_last_screen][:connections].include?(ui_connection)
            @ui_screens[@ui_last_screen][:connections] << ui_connection
          end
          next
        end

        next if @ui_last_screen.nil?
        screen_name = @ui_last_screen

        # Found elements, but no screen? Put them to trash
        # screen_name = @ui_last_screen || 'trash'
        # @ui_screens[screen_name] = { buttons: [], connections: [] } if @ui_screens[screen_name].nil?

        match_data = MATCH_BUTTON_REGEXP.match(step)
        if match_data
          button_name = match_data[:name]
          button_type = match_data[:type]

          button_name.sub!(/ segmented$/, '')
          button_name.sub!(/ table$/, '')

          if button_type == 'row'
            match_data = /(?<name>.+) (on |at )(?<title>.+)?$/.match(button_name)
            if match_data
              button_name = match_data[:name] + " (#{button_type})"
              # TODO: elements << button_type
            end
          end
          
          button_name.sub!(/^['"](?<name>.+)['"]$/, '\k<name>')
          if button_name && !@ui_screens[screen_name][:buttons].include?(button_name)
            @ui_screens[screen_name][:buttons] << button_name
          end
        end
      end
    end
    @ui_screens
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
    prev_step = nil if use_connector

    prev_step_n = final_steps.count - 1
    prev_step_line = final_steps[prev_step_n]

    case type 
    when :given
      if steps.count > 1
        use_connector = true
        final_steps[prev_step_n] = prev_step_line + "->|#{c1}|" if prev_step
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
      final_steps[prev_step_n] = prev_step_line + "->|#{c1}|" if prev_step
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

    num_steps = ssteps.count

    # start with start
    last_step = yuml._(:start).to_s
    steps[:ok] << last_step

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
      when 'But'
        curr_step = prev_step
      end

      if curr_step != prev_step && prev_step != :trash
        # dump previous steps
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

      # Clean up step a bit
      step.sub!(/^I am /i, '') if strip_i
      step.sub!(/^I /i, '') if strip_i

      # collect next data
      steps[curr_step] << step

      # dump the last one
      if i == num_steps-1
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

    # End
    if !prev_connector.nil?
      steps[:ok] << "|#{prev_connector}|->(end)"
    else 
      steps[:ok][-1] = steps[:ok].last + "->(end)"
    end

    steps[:ok].each do |e|
      yuml.link_s e
    end

    yuml
  end

  def self.yuml_ui_actions(actions)
    return '' if actions.count == 0
    '|' + actions.collect {|e| e = e.gsub(/['"']/, '').strip; "- #{e}"} * ';'
  end

  def self.ui_elements_interconnect(e1, e2, pool)
    return false if !pool[e1].nil? && pool[e1].include?(e2)
    return false if !pool[e2].nil? && pool[e2].include?(e1)
    pool[e1] = [] if pool[e1].nil?
    pool[e1] << e2
    true
  end

  def self.ui_elements(screens={}, scale=75)

    return nil if screens.count == 0

    screens_dumped = []
    screens_connected = {}
    yuml = YUML::classDiagram( :scruffy, :scale => scale ){}
    
    screens.each do |name, data|
      next if screens_dumped.include?(name)

      buttons = yuml_ui_actions(data[:buttons])
      connections = data[:connections]

      if connections.count == 0
        screens_dumped << name
        yuml.link_s yuml._["#{name}#{buttons}"].to_s + '-' + yuml.note('Not connected').to_s
      else
        connections.each_with_index do |conn_name, i|
          next if !ui_elements_interconnect(name, conn_name, screens_connected)

          conn_element = screens[conn_name]
          conn_buttons = yuml_ui_actions(conn_element[:buttons])

          # check who's first
          e1i = screens_dumped.index name
          e2i = screens_dumped.index conn_name

          buttons = '' if e1i
          conn_buttons = '' if e2i
          es1 = e1_s = "#{name}#{buttons}"
          es2 = e2_s = "#{conn_name}#{conn_buttons}"

          if e1i.nil? && e2i.nil?
            screens_dumped << name
            screens_dumped << conn_name
          elsif e1i.nil?
            screens_dumped << name
            es1 = e2_s
            es2 = e1_s
          elsif e2i.nil?
            screens_dumped << conn_name
          elsif e1i > e2i
            es1 = e2_s
            es2 = e1_s
          elsif e2i > e1i
          end

          yuml.link_s yuml._[es1].to_s + '->' + yuml._[es2].to_s
        end
      end

    end
    yuml
  end

end