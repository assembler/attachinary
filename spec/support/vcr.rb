require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.ignore_localhost = true
  # Rerecord cassettes if requested with env variable
  c.default_cassette_options = {record: :all} if ENV['VCR_REGENERATE']
  # Do not store cloudinary authentication in cassettes
  c.filter_sensitive_data('<CLOUDINARY_CLOUD_NAME>') { Cloudinary.config.cloud_name }
  c.filter_sensitive_data('<CLOUDINARY_API_KEY>') { Cloudinary.config.api_key }
  c.filter_sensitive_data('<CLOUDINARY_API_SECRET>') { Cloudinary.config.api_secret }
  # Ignore signatures passed to cloudinary when matching requests
  c.default_cassette_options = {match_requests_on: [:method, VCR.request_matchers.uri_without_param(:signature)]}
end