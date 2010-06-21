$:.unshift(File.dirname(__FILE__)+"/../../")
require 'spec_helper'

describe Statsample::Bivariate::Tetrachoric do
  it "should return correct tetrachoric_matrix" do
    ds=Statsample::PlainText.read(File.dirname(__FILE__)+"/../../../data/tetmat_test.txt", %w{a b c d e})
    tcm_obs=Statsample::Bivariate.tetrachoric_correlation_matrix(ds)
    tcm_exp=Statsample::PlainText.read(File.dirname(__FILE__)+"/../../../data/tetmat_matrix.txt", %w{a b c d e}).to_matrix
    tcm_obs.row_size.times do |i|
      tcm_obs.column_size do |j|
        tcm_obs[i,j].should be_close(tcm_exp[i,k], 0.00001)
      end
    end
  end
  
  it "should return similar values for tetrachoric and polychoric 2x2" do
    2.times {
      # Should be the same results as Tetrachoric for 2x2 matrix
      matrix=Matrix[[150+rand(10),1000+rand(20)],[1000+rand(20),200+rand(20)]]
      tetra = Statsample::Bivariate::Tetrachoric.new_with_matrix(matrix)
      poly  = Statsample::Bivariate::Polychoric.new(matrix)
      poly.compute_two_step_mle_drasgow_ruby
      tetra.r.should be_close(poly.r,0.0001)
      if Statsample.has_gsl?
        poly.compute_two_step_mle_drasgow_gsl
        tetra.r.should be_close(poly.r,0.0001)
      else
        skip "compute_two_step_mle_drasgow_gsl not tested (requires GSL)"
      end
    }
  end

  it "should raise error on 0 row/column contingente table" do
    a,b,c,d=0,0,0,0
    
    lambda {Statsample::Bivariate::Tetrachoric.new(a,b,c,d)}.should raise_error(RuntimeError)
    
    a,b,c,d=10,10,0,0
    
    lambda {Statsample::Bivariate::Tetrachoric.new(a,b,c,d)}.should raise_error(RuntimeError)
    
    a,b,c,d=10,0,10,0
    lambda {Statsample::Bivariate::Tetrachoric.new(a,b,c,d)}.should raise_error(RuntimeError)
  end
  it "should return correct value for perfect correlation" do
    a,b,c,d=10,0,0,10
    tc  = Statsample::Bivariate::Tetrachoric.new(a,b,c,d)
    tc.r.should==1
    tc.se.should==0
  end
  it "should return correct value for perfect inverse correlation" do 
    a,b,c,d=0,10,10,0
    tc  = Statsample::Bivariate::Tetrachoric.new(a,b,c,d)
    tc.r.should==-1
    tc.se.should==0
  end
  it "should return correct value for standard contingence table" do 
    a,b,c,d = 30,40,70,20
    tc  = Statsample::Bivariate::Tetrachoric.new(a,b,c,d)
    tc.r.should be_close(-0.53980,0.0001)
    tc.se.should be_close(0.09940,0.0001)
    tc.threshold_x.should be_close(-0.15731, 0.0001)
    tc.threshold_y.should be_close( 0.31864, 0.0001)
  end
  it "should return equal values for dataset and crosstab inputs" do 
    x=%w{a a a a b b b a b b a a b b}.to_vector
    y=%w{0 0 1 1 0 0 1 1 1 1 0 0 1 1}.to_vector
    # crosstab
    #    0    1
    # a  4    3
    # b  2    5
    a,b,c,d=4,3,2,5
    tc1  = Statsample::Bivariate::Tetrachoric.new(a,b,c,d)
    tc2  = Statsample::Bivariate::Tetrachoric.new_with_vectors(x,y)
    tc1.r.should==tc2.r
    tc1.se.should==tc2.se
    tc2.summary.size.should>0
  end

end