# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "Immanent" do
  before do
    class Application < Immanent::Control
      route :get, "/resource/:id" do
        render ({ no: :future })
      end
    end
  end

  it "should calculate the Levenshtein difference between two strings (0)" do
    Immanent::Control::LEVENSHTEIN["kitten", "sitten"].should eq 1
  end

  it "should calculate the Levenshtein difference between two strings (1)" do
    Immanent::Control::LEVENSHTEIN["sitten", "sittin"].should eq 1
  end

  it "should calculate the Levenshtein difference between two strings (2)" do
    Immanent::Control::LEVENSHTEIN["sittin", "sitting"].should eq 1
  end

  it "should conjugate a verb and path into a method name" do
    Immanent::Control.send(:conjugate, :get, "/resource/:id").should eq "immanent_get_/resource/:id"
  end

  it "should extract parameters out of the request path" do
    Immanent::Control.send(:ascertain, "immanent_get_/resource/:id", "/resource/1000").should eq({ id: "1000" })
  end

  it "should be able to extract multiple parameters out of the request path" do
    Immanent::Control.send(:ascertain, "immanent_get_/resource/:resource_id/child/:id", "/resource/1000/child/10").should eq({ resource_id: "1000", id: "10" })
  end

  it "should provide a DSL for defining routes" do
    Application.methods.include?(:"immanent_get_/resource/:id").should be_true
  end

  it "should have a default response" do
    Application.render[0].should eq(Rack::Response.new("\"ok\"").finish[0])
  end

  it "should respond with the route definition, a JSON string" do
    Application.send("immanent_get_/resource/:id").last.body.should eq(["{\"no\":\"future\"}"])
  end
end
