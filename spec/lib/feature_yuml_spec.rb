require 'spec_helper'

describe Gherkify::FeatureYuml do

  subject { Gherkify::FeatureYuml }

  def sample_scenario
    {steps: [
      { keyword: 'Given', name: 'I have house' },
      { keyword: 'When',  name: 'I plant a tree' },
      { keyword: 'And',   name: 'I plant a second tree' },
      { keyword: 'Then',  name: 'I have two trees' },
      { keyword: 'And',   name: 'a house' }
      ]
    }
  end

  it "builds yUML UseCase Diagram" do
    actor = "User"
    feature = "Be super-cool"
    scenarios = ["Have Muscle", "Be Smart", "Have Money"]
    note = "Yep!"

    expected = "[User]-(note: Yep!),[User]-(Be supercool),(Be supercool)<(Have Muscle),(Be supercool)<(Be Smart),(Be supercool)<(Have Money)"

    yuml = subject.use_case(actor, feature, scenarios, note)
    yuml.to_line.should == expected
  end

  it "builds yUML Activity Diagram" do
    expected = "(start)->[have house]->(plant a tree)->(plant a second tree)->|a|,|a|->(have two trees)->|b|,|a|->(a house)->|b|,|b|->(end)"

    yuml = subject.activity(sample_scenario)
    yuml.to_line.should == expected
  end

  it "calculates MD5 for diagram" do
    yuml = subject.activity(sample_scenario)
    expected = "1bf8e91967ec177d335720a062644545"
    yuml.md5.should == expected
  end
  
end