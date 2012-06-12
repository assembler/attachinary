# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'rspec' do
  # uses the .rspec file
  # --colour --fail-fast --format documentation --tag ~slow
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb$})                           { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^app/views/(.+)/.+\.erb$})                 { |m| "spec/integration/#{m[1]}_spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| "spec/intagration/#{m[1]}_spec.rb" }
end
