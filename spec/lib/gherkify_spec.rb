require 'spec_helper'

describe Gherkify do

  it "should parse file" do
    file = fixture_path('download_files.feature')
    ret = Gherkify.parse_file(file)
    ap ret
    pending
  end

  it "should say Hello" do
    Gherkify.hello.should == "Hello"
  end

end
