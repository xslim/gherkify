require 'spec_helper'

describe Gherkify do

  it "should parse file" do    
    file = fixture_path('download_files.feature')
    gherkify = Gherkify.parse_file(file)
    features = gherkify.features
    features.count.should == 1
  end

  it "should parse complex feature" do
    file = fixture_path('calabash.feature')

    expected = <<-EXPECTED
    Feature: Rating a stand
    Use Case: 79dbe67d5954b3ebc49259fb26ed2e11
    [Actor]-(Rating a stand)
    (Rating a stand)<(Find and rate a stand from the list)

    Activities: 
    Find and rate a stand from the list ca99d5d3362fbdf93a829c642346a332:
    (start)->[on the foodstand list]->|a|
    |a|->(should see a "rating" button)->|b|
    |a|->(should not see "Dixie Burger & Gumbo Soup")->|b|
    |b|->(touch the "rating" button)->|c|
    |c|->(should see "Dixie Burger & Gumbo Soup")->|d|
    |d|->(touch "Dixie Burger & Gumbo Soup")->|e|
    |e|->(should see details for "Dixie Burger & Gumbo Soup")->|f|
    |f|->(touch the "rate_it" button)->|g|
    |g|->(should see the rating panel)->|h|
    |h|->(touch "star5")->(touch "rate")->|i|
    |i|->("Dixie Burger & Gumbo Soup" should be rated 5 stars)->|j|
    |j|->(end)

    UI elements:
    [foodstand|- rating;- rate_it]-(note: Not connected)
    
    EXPECTED
    trim_text_lines!(expected)

    ret = Gherkify.parse_file(file).to_s
    # puts ret
    ret.should eq(expected)
  end

end
