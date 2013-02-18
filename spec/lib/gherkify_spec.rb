require 'spec_helper'

describe Gherkify do

  it "should parse file" do    
    file = fixture_path('download_files.feature')
    ret = Gherkify.parse_file(file)
    pending
  end

  it "should parse complex feature" do
    file = fixture_path('calabash.feature')

    expected = <<-EXPECTED
    Feature: Rating a stand
    Use Case: 79dbe67d5954b3ebc49259fb26ed2e11
    [Actor]-(Rating a stand)
    (Rating a stand)<(Find and rate a stand from the list)

    Activities: 
    Find and rate a stand from the list eb86d8258530f6aef0c4a2640c2149ba:
    (start)->[am on the foodstand list]->|a|
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
    EXPECTED
    expected.gsub!(/\s/,'')

    ret = Gherkify.parse_file(file).to_s
    # puts ret
    ret.gsub(/\s/,'').should eq(expected)
  end

end
