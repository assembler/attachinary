require 'attachinary/engine'

unless defined?(ATTACHINARY_ORM)
  ATTACHINARY_ORM = (ENV["ATTACHINARY_ORM"] || :active_record).to_sym
end

require "attachinary/orm/#{ATTACHINARY_ORM}"

module Attachinary
end
