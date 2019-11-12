# frozen_string_literal: true

require 'gr'
require 'gr/plot' # will be removed

require 'numo/narray'

x = Numo::DFloat.linspace(0, 4, 401)
y = Numo::NMath.sin(x)
GR.lineplot(x, y)
gets
