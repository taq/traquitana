require "minitest/autorun"
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/traquitana.rb"

describe Traquitana::Bar do
   before do
      @bar = Traquitana::Bar.new
      @bar.total = 100
   end

   describe "limits" do
      it "should have a total" do
         @bar.must_respond_to :total
      end
      it "should have a current value" do
         @bar.must_respond_to :current
      end
   end

   describe "updates" do
      it "should have a name" do
         @bar.must_respond_to :name
      end
      it "should have a update method" do
         @bar.must_respond_to :update
      end
      it "should have a indicator method" do
         @bar.must_respond_to :indicator
      end
      it "should return the correct string for 0%" do
         @bar.indicator(0).must_equal "____________________"
      end
      it "should return the correct string for 25%" do
         @bar.indicator(25).must_equal "#####_______________"
      end
      it "should return the correct string for 50%" do
         @bar.indicator(50).must_equal "##########__________"
      end
      it "should return the correct string for 75%" do
         @bar.indicator(75).must_equal "###############_____"
      end
      it "should return the correct string for 100%" do
         @bar.indicator(100).must_equal "####################"
      end
   end
end
