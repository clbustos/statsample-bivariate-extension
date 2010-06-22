$:.unshift(File.dirname(__FILE__)+"/../../")
require 'spec_helper'
describe Statsample::Bivariate::Polychoric::Processor do
  before do
     @matrix=Matrix[[58,52,1],[26,58,3],[8,12,9]]
     @alpha=[-0.027, 1.137]
     @beta=[-0.240, 1.1578]
     @rho=0.420
     @processor=Statsample::Bivariate::Polychoric::Processor.new(@alpha,@beta,@rho,@matrix)
  end
  it "im_function  method should return correct values according to index" do
    @processor.im_function(0,0,0).should==@processor.fd_loglike_cell_rho(0,0)
    @processor.im_function(1,0,0).should==@processor.fd_loglike_cell_a(0,0,0)
    @processor.im_function(2,0,0).should==@processor.fd_loglike_cell_a(0,0,1)
    @processor.im_function(3,1,0).should==@processor.fd_loglike_cell_b(1,0,0)
    @processor.im_function(4,0,1).should==@processor.fd_loglike_cell_b(0,1,1)
    lambda {@processor.im_function(5)}.should raise_error
    
  end
  it "should return informacion matrix" do
    p @processor.information_matrix.inverse
  end
  it "fd a loglike should be equal usign eq.6 and eq.13" do
    2.times {|k|
      @processor.fd_loglike_a_eq6(k).should be_close @processor.fd_loglike_a_eq13(k), 1e-10
    }
  end
  it "fd b loglike should be equal usign eq.6 and eq.14" do
    2.times {|m|
      @processor.fd_loglike_b_eq6(m).should be_close @processor.fd_loglike_b_eq14(m), 1e-10
    }
  end  
  it "fd rho should be equal usign fd_loglike_cell_rho and fd_loglike_rho" do
    total=0
    
    nr=@alpha.size+1
    nc=@beta.size+1
    nr.times do |i|
      nc.times do |j|
        pi=@processor.pd[i][j] + 1e-10
        total+= (@matrix[i,j].quo(pi))  * @processor.fd_loglike_cell_rho(i,j)  
      end
    end
    total.should==@processor.fd_loglike_rho
  end
  
end
