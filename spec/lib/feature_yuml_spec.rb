require 'spec_helper'

describe Gherkify::FeatureYuml do

  subject { Gherkify::FeatureYuml }
  
  it "trims special characters" do
    text = "Minus-character"
    subject.trim(text).should == "Minuscharacter"

    subject.trim!(text)
    text.should == "Minuscharacter"
  end

  it "trims multiple arguments" do
    a, b, c, d = 'a-a', 'b-b', 'c-c', 'd-d'
    subject.trim!(a, b, c, d)
    a.should == 'aa'
    b.should == 'bb'
    c.should == 'cc'
    d.should == 'dd'
  end
  
end