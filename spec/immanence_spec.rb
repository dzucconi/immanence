# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "Immanence" do
  before do
    @Δ = Immanence::Control::LEVENSHTEIN
  end
  it "should calculate the Levenshtein difference between two strings (0)" do
    @Δ["kitten", "sitten"].should eq 1
  end

  it "should calculate the Levenshtein difference between two strings (1)" do
    @Δ["sitten", "sittin"].should eq 1
  end

  it "should calculate the Levenshtein difference between two strings (2)" do
    @Δ["sittin", "sitting"].should eq 1
  end
end
