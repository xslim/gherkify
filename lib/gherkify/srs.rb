require 'handlebars'

# TODO: Separate this some day
class Gherkify::SRS

  def initialize(gherkify, options={})
    @gherkify = gherkify
      
    @options = {
      show_gherkin_src: false,
      show_yuml_src: false,
      image_path: ''
    }.merge options
  end


  def img_path(image_name)
    File.join(@options[:image_path], "#{image_name}.png")
  end

  def use_case_image(feature_diagram)
    img_path(feature_diagram.md5)
  end

  def scenario_image(scenario_diagram)
    img_path(scenario_diagram.md5)
  end

  def use_cases
    cases = []

    @gherkify.features.each do |feature|
      # ap feature.data
      scenarios = []
      feature.scenarios.each do |e|
        activity = feature.yuml.activity(e)
        one_scenario = { 
          name: feature.scenario_name(e), 
          image: scenario_image(activity)
        }
        one_scenario[:yuml] = activity.to_s if @options[:show_yuml_src]
        scenarios << one_scenario
      end

      one_case = {
        name: feature.name,
        image: use_case_image(feature.yuml.use_case),
        scenarios: scenarios
      }
      one_case[:gherkin] = File.read(feature.data[:uri]) if @options[:show_gherkin_src]
      one_case[:yuml] = feature.yuml.use_case.to_s if @options[:show_yuml_src]

      cases << one_case
    end

    # check_and_fetch_diagram(yuml_ui_elements, pngs, output_dir) if yuml_ui_elements
    cases
  end

  def ui_elements_diagram
    @gherkify.yuml_ui_elements
  end

  def ui_elements_image
    img_path(ui_elements_diagram.md5)
  end

  def self.generate(gherkify, options={}, template_options={})
  
    template_path = Gherkify.path_to_resource('srs_template.md')

    options = {
      template: template_path,
      image_path: '',
      show_gherkin_src: true,
      show_yuml_src: true
    }.merge options

    srs = Gherkify::SRS.new(gherkify, options)

    template_file = File.read(template_path)

    handlebars = Handlebars::Context.new
    template = handlebars.compile(template_file)

    template_options = {
      app_name: 'Software',
      use_cases: srs.use_cases
    }.merge template_options

    template.call(template_options)
  end
  
end