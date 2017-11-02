module Attachinary
  module Utils

    def self.process_json(json, scope=nil)
      [JSON.parse(json)].flatten.compact.map do |data|
        process_hash(data, scope)
      end
    end

    def self.process_hash(hash, scope=nil)
      if hash['id']
        Attachinary::File.find hash['id']
      else
        file = if Rails::VERSION::MAJOR == 3
                 Attachinary::File.new hash.slice(*Attachinary::File.attr_accessible[:default].to_a)
               else
                 permitted_params = ActionController::Parameters.new(hash.symbolize_keys.slice(:public_id, :version, :width, :height, :format, :resource_type)).permit!
                 Attachinary::File.new(permitted_params)
               end
        file.scope = scope.to_s if scope && file.respond_to?(:scope=)
        file
      end
    end


    def self.process_input(input, upload_options, scope=nil)
      case input
      when :blank?.to_proc
        nil
      when lambda { |e| e.respond_to?(:read) }
        upload_options.merge! resource_type: 'auto'
        upload_info = Cloudinary::Uploader.upload(input, upload_options)
        process_hash upload_info, scope
      when String
        process_json(input, scope)
      when Hash
        process_hash(input, scope)
      when Array
        input = input.map{ |el| process_input(el, upload_options, scope) }.flatten.compact
        input = nil if input.empty?
        input
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
