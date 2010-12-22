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
    @poly.r.should be_within( 0.0001).of(0.4192)
    @poly.threshold_x[0].should be_within( 0.0001).of(-0.0297)
    @poly.threshold_x[1].should be_within( 0.0001).of(1.1331)

    @poly.threshold_y[0].should be_within( 0.0001).of(-0.2421)
    @poly.threshold_y[1].should be_within(0.0001).of(1.5938 )
    @poly.chi_square.should be_within(0.01).of(11.54)
  end
  it "compute joint estimation (without derivative) using gsl" do
    pending("requires rb-gsl") unless Statsample.has_gsl?
    
    @poly.compute_one_step_mle_without_derivatives
    check_joint
  end
  it "compute joint estimation (with derivative) using gsl" do
    pending("requires rb-gsl") unless Statsample.has_gsl?
    
    @poly.compute_one_step_mle_with_derivatives
    check_joint
  end
  
  def check_two_step
    @poly.r.should be_within( 0.001).of(0.420)
    @poly.threshold_y[0].should be_within(0.001).of(-0.240 )
    @poly.threshold_x[0].should be_within(0.001).of(-0.027 )
    @poly.threshold_y[1].should be_within(0.001).of(1.578  )
    @poly.threshold_x[1].should be_within(0.001).of(1.137  )
  end
  it "should compute two step mle with ruby" do
      @poly.compute_two_step_mle_ruby
      check_two_step
  end

  it "compute two-step with gsl" do
    pending("requires rb-gsl") unless Statsample.has_gsl?
    @poly.compute_two_step_mle_gsl
    check_two_step
  end
 
  it "compute polychoric series using gsl" do      
    pending("requires rb-gsl") unless Statsample.has_gsl?

    @poly.method=:polychoric_series
    @poly.compute
    
    @poly.r.should be_within( 0.001).of(0.556)
    @poly.threshold_y[0].should be_within(0.001).of(-0.240 )
    @poly.threshold_x[0].should be_within(0.001).of(-0.027 )
    @poly.threshold_y[1].should be_within(0.001).of(1.578  )
    @poly.threshold_x[1].should be_within(0.001).of(1.137  )
  end
  
end
