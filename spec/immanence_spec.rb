# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "Immanence" do
  before do
    class Application < Immanence::Control
      route :get, "/resource/:id" do; end
    end

    @immanence  = Immanence::Control
    @Δ          = @immanence::LEVENSHTEIN
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

  it "should conjugate a verb and path into a method name" do
    @immanence.send(:conjugate, :get, "/resource/:id").should eq "immanent_get_/resource/:id"
  end

  it "should extract parameters out of the request path" do
    @immanence.send(:ascertain, "immanent_get_/resource/:id", "/resource/1000").should eq({ id: "1000" })
  end

  it "should be able to extract multiple parameters out of the request path" do
    @immanence.send(:ascertain, "immanent_get_/resource/:resource_id/child/:id", "/resource/1000/child/10").should eq({ resource_id: "1000", id: "10" })
  end

  it "should provide a DSL for defining routes" do
    Application.methods.include?(:"immanent_get_/resource/:id").should be_true
  end

  it "should have a default response" do
    Application.>>.should eq([200, {"Content-Type"=>"text/json", "Content-Length"=>"4"}, ["\"ok\""]])
  end

  it "should be able to respond with a JSON object" do
    Application.>>({ id: "1000" }).should eq([200, {"Content-Type"=>"text/json", "Content-Length"=>"13"}, ["{\"id\":\"1000\"}"]])
  end
end
