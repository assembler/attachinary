module Attachinary
  module Utils

    def self.parse_json(json, scope=nil)
      [JSON.parse(json)].flatten.map do |data|
        file = Attachinary::File.new data.slice(*Attachinary::File.attr_accessible[:default].to_a)
        file.scope = scope.to_s if scope
        file
      end
    end

    def self.process_input(input, scope=nil)
      case input
      when :blank?.to_proc
        nil
      when String
        parse_json(input, scope)
      when Array
        input.map { |el| process_input(el) }
      else
        input
      end
    end

    def self.process_options(options)
      options = options.reverse_merge({
        accessible: true
      })
      options[:maximum] = 1 if options[:single]

      if options[:single]
        options[:singular] = options[:scope].to_s
        options[:plural] = options[:scope].to_s.pluralize
      else
        options[:plural] = options[:scope].to_s
        options[:singular] = options[:scope].to_s.singularize
      end

      options
    end

  end
end
