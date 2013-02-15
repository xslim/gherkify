require 'spec_helper'

describe Gherkify::FeatureYuml do

  subject { Gherkify::FeatureYuml }

  @scenario = {
    {steps: [
      { keyword: 'Given', name: 'I have house' },
      { keyword: 'When',  name: 'I plant a tree' },
      { keyword: 'And',   name: 'I plant a second tree' },
      { keyword: 'Then',  name: 'I have two trees' },
      { keyword: 'And',   name: 'I a house' }
    ]
    }
  
  it "trims special characters" do
    pending "Move this to YUML spec"
    text = "Minus-character"
    subject.trim(text).should == "Minuscharacter"

    subject.trim!(text)
    text.should == "Minuscharacter"
  end

  it "trims multiple arguments" do
    pending "Move this to YUML spec"
    a, b, c, d = 'a-a', 'b-b', 'c-c', 'd-d'
    subject.trim!(a, b, c, d)
    a.should == 'aa'
    b.should == 'bb'
    c.should == 'cc'
    d.should == 'dd'
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
    

    expected = "(start)->|I have house|->(plant a tree)->(plant a second tree)->|b|,|b|->(have two trees)->|c|,|b|->(a house)->|c|,|c|->(end)"

    yuml = subject.activity(@scenario)
    yuml.to_line.should == expected

    ap yuml.to_url
    ap yuml.md5
  end

  it "calculates MD5 for diagram" do
    yuml = subject.activity(@scenario)
    yuml.md5.should == "4ac9adcf81feb7bc14e2670fb1245be8"
  end
  
end