module Statsample
  module Bivariate
    class Polychoric
      # Provides statistics for a given combination of rho, alpha and beta and contingence table.
      class Processor
        attr_reader :alpha, :beta, :rho, :matrix
        EPSILON=1e-10
        def initialize(alpha,beta,rho,matrix=nil)
          @alpha=alpha
          @beta=beta
          @matrix=matrix
          @nr=@alpha.size+1
          @nc=@beta.size+1
          @rho=rho
          @pd=nil
        end
        
        def bipdf(i,j)
           Distribution::NormalBivariate.pdf(a(i), b(j), rho)
        end
        
        def loglike
          rho=@rho
          if rho.abs>0.9999
            rho= (rho>0) ? 0.9999 : -0.9999
          end
          loglike=0
          @nr.times do |i|
            @nc.times do |j|
              res=pd[i][j]+EPSILON
              loglike+= @matrix[i,j]  * Math::log( res )
            end
          end
          -loglike
        end
        
        def a(i)
          raise "Index #{i} should be <= #{@nr-1}" if i>@nr-1
          i < 0 ? -100 : (i==@nr-1 ? 100 : alpha[i])
        end
        def b(j)
          raise "Index #{j} should be <= #{@nc-1}" if j>@nc-1
          j < 0 ? -100 : (j==@nc-1 ? 100 : beta[j])
        end
        
        def eq12(u,v)
          Distribution::Normal.pdf(u)*Distribution::Normal.cdf((v-rho*u).quo( Math::sqrt(1-rho**2)))
        end
        
        def eq12b(u,v)
          Distribution::Normal.pdf(v) * Distribution::Normal.cdf((u-rho*v).quo( Math::sqrt(1-rho**2)))
          
        end
        # Equation(8) from Olsson(1979)
        def fd_loglike_cell_rho(i, j)
          bipdf(i,j) - bipdf(i-1,j) - bipdf(i, j-1) + bipdf(i-1, j-1)
        end
        # Equation(10) from Olsson(1979)
        def fd_loglike_cell_a(i, j, k)
=begin
          if k==i
            Distribution::NormalBivariate.pd_cdf_x(a(k),b(j), rho) - Distribution::NormalBivariate.pd_cdf_x(a(k),b(j-1),rho)
          elsif k==(i-1)
            -Distribution::NormalBivariate.pd_cdf_x(a(k),b(j),rho) + Distribution::NormalBivariate.pd_cdf_x(a(k),b(j-1),rho)
          else
            0
          end
=end          
          if k==i
            eq12(a(k),b(j))-eq12(a(k), b(j-1))
          elsif k==(i-1)
            -eq12(a(k),b(j))+eq12(a(k), b(j-1))
          else
            0
          end          
        end
        
        def fd_loglike_cell_b(i, j, m)
          if m==j
             eq12b(a(i),b(m))-eq12b(a(i-1),b(m))
          elsif m==(j-1)
            -eq12b(a(i),b(m))+eq12b(a(i-1),b(m))
          else
            0
          end
=begin          
          if m==j
            Distribution::NormalBivariate.pd_cdf_x(a(i),b(m), rho) - Distribution::NormalBivariate.pd_cdf_x(a(i-1),b(m),rho)
          elsif m==(j-1)
            -Distribution::NormalBivariate.pd_cdf_x(a(i),b(m),rho) + Distribution::NormalBivariate.pd_cdf_x(a(i-1),b(m),rho)
          else
            0
          end
=end          
          
          
        end
       
        # phi_ij for each i and j
        # Uses equation(4) from Olsson(1979)
        def pd
          if @pd.nil?
            @pd=@nr.times.collect{ [0] * @nc}
            pc=@nr.times.collect{ [0] * @nc}
            @nr.times do |i|
            @nc.times do |j|
             
              if i==@nr-1 and j==@nc-1
                @pd[i][j]=1.0
              else
                a=(i==@nr-1) ? 100: alpha[i]
                b=(j==@nc-1) ? 100: beta[j]
                #puts "a:#{a} b:#{b}"
                @pd[i][j]=Distribution::NormalBivariate.cdf(a, b, rho)
              end
              pc[i][j] = @pd[i][j]
              @pd[i][j] = @pd[i][j] - pc[i-1][j] if i>0
              @pd[i][j] = @pd[i][j] - pc[i][j-1] if j>0
              @pd[i][j] = @pd[i][j] + pc[i-1][j-1] if (i>0 and j>0)
            end
            end
          end
          @pd
        end
        
        # First derivate for rho
        # Uses equation (9) from Olsson(1979)
        
        def fd_loglike_rho
          rho=@rho
          if rho.abs>0.9999
            rho= (rho>0) ? 0.9999 : -0.9999
          end
          total=0
          @nr.times do |i|
            @nc.times do |j|
              pi=pd[i][j] + EPSILON
              total+= (@matrix[i,j].quo(pi))  * (bipdf(i,j)-bipdf(i-1,j)-bipdf(i,j-1)+bipdf(i-1,j-1))  
            end
          end
          total
        end
        
        # First derivative for alpha_k
        # Uses equation (6)
        def fd_loglike_a(k)
          fd_loglike_a_eq6(k)
        end
        
        
        
        # Uses equation (6) from Olsson(1979)
        def fd_loglike_a_eq6(k)
          rho=@rho
          if rho.abs>0.9999
            rho= (rho>0) ? 0.9999 : -0.9999
          end
          total=0
          @nr.times do |i|
            @nc.times  do |j|
              total+=@matrix[i,j].quo(pd[i][j]+EPSILON) * fd_loglike_cell_a(i,j,k)
            end
          end
          total
        end
        
        
        # Uses equation(13) from Olsson(1979)
        def fd_loglike_a_eq13(k)
          rho=@rho
          if rho.abs>0.9999
            rho= (rho>0) ? 0.9999 : -0.9999
          end
          total=0
          a_k=a(k)
          @nc.times do |j|
            #puts "j: #{j}"
            #puts "b #{j} : #{b.call(j)}"
            #puts "b #{j-1} : #{b.call(j-1)}"
          
            e_1=@matrix[k,j].quo(pd[k][j]+EPSILON) - @matrix[k+1,j].quo(pd[k+1][j]+EPSILON)
            e_2=Distribution::Normal.pdf(a_k)
            e_3=Distribution::Normal.cdf((b(j)-rho*a_k).quo(Math::sqrt(1-rho**2))) - Distribution::Normal.cdf((b(j-1)-rho*a_k).quo(Math::sqrt(1-rho**2)))
            #puts "val #{j}: #{e_1} | #{e_2} | #{e_3}"
            total+= e_1*e_2*e_3
          end
          total
        end
        # First derivative for b
        # Uses equation 6 (Olsson, 1979)
        def fd_loglike_b_eq6(m)
          rho=@rho
          if rho.abs>0.9999
            rho= (rho>0) ? 0.9999 : -0.9999
          end
          total=0
          @nr.times do |i|
            @nc.times  do |j|
              total+=@matrix[i,j].quo(pd[i][j]+EPSILON) * fd_loglike_cell_b(i,j,m)
            end
          end
          total
        end
        # First derivative for beta_m.
        # Uses equation 6 (Olsson,1979)
        def fd_loglike_b(m)
          fd_loglike_b_eq14(m)
        end
        # First derivative for beta_m
        # Uses equation(14) from Olsson(1979)
        def fd_loglike_b_eq14(m)
          rho=@rho
          if rho.abs>0.9999
            rho= (rho>0) ? 0.9999 : -0.9999
          end
          total=0
          b_m=b(m)
          @nr.times do |i|
            e_1=@matrix[i,m].quo(pd[i][m]+EPSILON) - @matrix[i,m+1].quo(pd[i][m+1]+EPSILON)
            e_2=Distribution::Normal.pdf(b_m)
            e_3=Distribution::Normal.cdf((a(i)-rho*b_m).quo(Math::sqrt(1-rho**2))) - Distribution::Normal.cdf((a(i-1)-rho*b_m).quo(Math::sqrt(1-rho**2)))
            #puts "val #{j}: #{e_1} | #{e_2} | #{e_3}"
            
            total+= e_1*e_2*e_3
          end
          total
        end
        # Returns the derivative correct according to order
        def im_function(t,i,j)
          if t==0
            fd_loglike_cell_rho(i,j)
          elsif t>=1 and t<=@alpha.size
            fd_loglike_cell_a(i,j,t-1)
          elsif t>=@alpha.size+1 and t<=(@alpha.size+@beta.size)
            fd_loglike_cell_b(i,j,t-@alpha.size-1)
          else
            raise "incorrect #{t}"
          end
        end
        def information_matrix
          total_n=@matrix.total_sum
          vars=@alpha.size+@beta.size+1
          matrix=vars.times.map { vars.times.map {0}}
          vars.times do |m|
            vars.times do |n|
              total=0
              (@nr-1).times do |i|
                (@nc-1).times do |j|
                  total+=(1.quo(pd[i][j]+EPSILON)) * im_function(m,i,j) * im_function(n,i,j)
                end
              end
              matrix[m][n]=total_n*total
            end
          end
          m=::Matrix.rows(matrix)
           
        end
      end # Processor
    end # Polychoric
  end # Bivariate
end # Statsample
