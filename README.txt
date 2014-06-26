= statsample-bivariate-extension

* http://ruby-statsample.rubyforge.org/

== DESCRIPTION:

Provides advanced bivariate statistics:
* Tetrachoric correlation
* Polychoric correlation

== FEATURES/PROBLEMS:

* Statsample::Bivariate::Polychoric class provides polychoric correlation
* Statsample::Bivariate::Tetrachoric class provides tetrachoric correlation


== SYNOPSIS:

=== Tetrachoric correlation

    require 'statsample'
    a=40
    b=10
    c=20
    d=30
    tetra=Statsample::Bivariate::Tetrachoric.new(a,b,c,d)
    puts tetra.summary
    
=== Polychoric correlation

    require 'statsample'
    ct=Matrix[[58,52,1],[26,58,3],[8,12,9]]
    
    poly=Statsample::Bivariate::Polychoric.new(ct)
    puts poly.summary


== REQUIREMENTS:

* Statsample

== INSTALL:

This gem is a statsample dependency. If you want to install it separatly

* sudo gem install statsample-bivariate-extension

== LICENSE:

BSD 2-Clause (see LICENSE.txt)
