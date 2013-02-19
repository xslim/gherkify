require 'spec_helper'

describe Gherkify::Feature do


  it "should ignore scenarios with @gherkify-ignore tag" do
    file = fixture_path('download_files.feature')
    features = Gherkify.parse_file(file).features
    feature = features[0]

    feature.scenarios.count.should == 4
  end
  
end