$:.unshift(File.dirname(__FILE__)+"/../../")
require 'spec_helper'
describe "Statsample::Bivariate polychoric extension" do
    it "should respond to polychoric method" do
      Statsample::Bivariate.should respond_to(:polychoric)
    end
    it "should respond to method polychoric_correlation_matrix" do
      a=([1,1,2,2,2,3,3,3,2,2,3,3,3]*4).to_scale
      b=([1,2,2,2,1,3,2,3,2,2,3,3,2]*4).to_scale
      c=([1,1,1,2,2,2,2,3,2,3,2,2,3]*4).to_scale
      ds={'a'=>a,'b'=>b,'c'=>c}.to_dataset
      Statsample::Bivariate.polychoric_correlation_matrix(ds).should be_instance_of(::Matrix)
    end
  end

describe Statsample::Bivariate::Polychoric do
  
  before do
    matrix=Matrix[[58,52,1],[26,58,3],[8,12,9]]
    @poly=Statsample::Bivariate::Polychoric.new(matrix)
  end
  it "should have summary.size > 0" do
    @poly.method=:two_step
    @poly.summary.size.should>0
  end
  def check_joint
    @poly.r.should be_close(0.4192, 0.0001)
    @poly.threshold_x[0].should be_close(-0.0297, 0.0001)
    @poly.threshold_x[1].should be_close(1.1331, 0.0001)

    @poly.threshold_y[0].should be_close(-0.2421, 0.0001)
    @poly.threshold_y[1].should be_close(1.5938 ,0.0001)
  end
  it "compute joint estimation (without derivative) using gsl" do
    pending("hh")
    @poly.compute_one_step_mle_without_derivatives
    check_joint

  end
  it "compute joint estimation (with derivative) using gsl" do
    @poly.compute_one_step_mle_with_derivatives
    check_joint
  end
  
  def check_two_step
    @poly.r.should be_close(0.420, 0.001)
    @poly.threshold_y[0].should be_close(-0.240 ,0.001)
    @poly.threshold_x[0].should be_close(-0.027 ,0.001)
    @poly.threshold_y[1].should be_close(1.578  ,0.001)
    @poly.threshold_x[1].should be_close(1.137  ,0.001)
  end
  it "should compute two step mle with ruby" do
      @poly.compute_two_step_mle_drasgow_ruby
      check_two_step
  end

  it "compute two-step with gsl" do
    pending("requires rb-gsl") unless Statsample.has_gsl?
    @poly.compute_two_step_mle_drasgow_gsl
    check_two_step
  end
 
  it "compute polychoric series using gsl" do      
    pending("requires rb-gsl") unless Statsample.has_gsl?

    @poly.method=:polychoric_series
    @poly.compute
    
    @poly.r.should be_close(0.556, 0.001)
    @poly.threshold_y[0].should be_close(-0.240 ,0.001)
    @poly.threshold_x[0].should be_close(-0.027 ,0.001)
    @poly.threshold_y[1].should be_close(1.578  ,0.001)
    @poly.threshold_x[1].should be_close(1.137  ,0.001)
  end
  
end
