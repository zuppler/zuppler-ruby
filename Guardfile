# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :rspec do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch('lib/zuppler/model.rb')  { "spec" }
  watch('lib/zuppler.rb')  { "spec" }
  watch('spec/spec_helper.rb')  { "spec" }
end


guard 'cucumber' do
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$})          { 'features' }
  watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'features' }
  watch(%r{^lib/(.+)\.rb$})     { |m| "features/#{m[1]}.feature" }
  watch('lib/zuppler.rb')  { 'features' }
end
