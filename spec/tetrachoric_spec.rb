$:.unshift(File.dirname(__FILE__)+"/../../")
require 'spec_helper'

describe "Statsample::Bivariate tetrachoric extensions" do
  it "should respond to tetrachoric method" do
    Statsample::Bivariate.should respond_to(:tetrachoric)
  end
  it "should return correct tetrachoric_matrix"do
    ds=Statsample::PlainText.read(File.dirname(__FILE__)+"/../data/tetmat_test.txt", %w{a b c d e})
    tcm_obs=Statsample::Bivariate.tetrachoric_correlation_matrix(ds)
    tcm_exp=Statsample::PlainText.read(File.dirname(__FILE__)+"/../data/tetmat_matrix.txt", %w{a b c d e}).to_matrix
    tcm_obs.row_size.times do |i|
      tcm_obs.column_size do |j|
        tcm_obs[i,j].should be_within( 0.00001).of(tcm_exp[i,k])
      end
    end
  end
  
end

shared_examples_for "tetrachoric implementation" do
  context "Polychoric 2x2 vs tetrachoric" do
    before do
      @matrix=Matrix[[150+rand(10),1000+rand(20)],[1000+rand(20),200+rand(20)]]
      @tetra = Statsample::Bivariate::Tetrachoric.new_with_matrix(@matrix,t_opts)
      @poly  = Statsample::Bivariate::Polychoric.new(@matrix)
    end
    it "should return similar values for two step ruby" do
      @poly.compute_two_step_mle_ruby
      @tetra.r.should be_within(0.0001).of(@poly.r)
    end
    if Statsample.has_gsl?
      it "should return similar values for two step using gsl" do
        @poly.compute_two_step_mle_gsl
        @tetra.r.should be_within(0.0001).of(@poly.r)
      end
    else
      it "shouldn't use two step gsl without rb-gsl"
    end
  end
  
  
  it "should raise error on contingence table without cases" do
    a,b,c,d=0,0,0,0
    lambda {Statsample::Bivariate::Tetrachoric.new(a,b,c,d, t_opts)}.should raise_error(Statsample::Bivariate::Tetrachoric::RequerimentNotMeet)
  end  
  it "should raise error on contingence table without cases on a row" do
  
    a,b,c,d=10,10,0,0
    
    lambda {Statsample::Bivariate::Tetrachoric.new(a,b,c,d, t_opts)}.should raise_error(Statsample::Bivariate::Tetrachoric::RequerimentNotMeet)
  end
  it "should raise error on contingence table without cases on a column" do
    a,b,c,d=10,0,10,0
    lambda {Statsample::Bivariate::Tetrachoric.new(a,b,c,d, t_opts)}.should raise_error(Statsample::Bivariate::Tetrachoric::RequerimentNotMeet)
  end
  it "should return correct values for perfect correlation" do
    a,b,c,d=10,0,0,10
    tc  = Statsample::Bivariate::Tetrachoric.new(a,b,c,d,t_opts)
    tc.r.should==1
    tc.se.should==0
  end
  it "should return correct values for perfect inverse correlation" do 
    a,b,c,d=0,10,10,0
    tc  = Statsample::Bivariate::Tetrachoric.new(a,b,c,d, t_opts)
    tc.r.should==-1
    tc.se.should==0
  end
  
  it "should return correct value for standard contingence table" do 
    a,b,c,d = 30,40,70,20
    tc  = Statsample::Bivariate::Tetrachoric.new(a,b,c,d, t_opts)
    tc.r.should be_within(0.0001).of(-0.53980)
    tc.se.should be_within(0.0001).of(0.09940)
    tc.threshold_x.should be_within( 0.0001).of(-0.15731)
    tc.threshold_y.should be_within( 0.0001).of( 0.31864)
  end
  it "should return equal values for dataset and crosstab inputs" do 
    x=%w{a a a a b b b a b b a a b b}.to_vector
    y=%w{0 0 1 1 0 0 1 1 1 1 0 0 1 1}.to_vector
    # crosstab
    #    0    1
    # a  4    3
    # b  2    5
    a,b,c,d=4,3,2,5
    tc1  = Statsample::Bivariate::Tetrachoric.new(a,b,c,d, t_opts)
    tc2  = Statsample::Bivariate::Tetrachoric.new_with_vectors(x,y, t_opts)
    tc1.r.should==tc2.r
    tc1.se.should==tc2.se
    tc2.summary.size.should>0
  end
end

describe "Statsample::Bivariate::Tetrachoric with ruby engine" do
  it_should_behave_like 'tetrachoric implementation' do
    let(:t_opts) { {:ruby_engine=>true}}
  end
end
describe "Statsample::Bivariate::Tetrachoric with optimized engine" do
  if Statsample::OPTIMIZED and Statsample::STATSAMPLE__.respond_to? :tetrachoric
    it_should_behave_like 'tetrachoric implementation' do
      let(:t_opts) { {:ruby_engine=>false}}
    end    
  else
    pending("not optimized tetrachoric engine available") 
  end
end