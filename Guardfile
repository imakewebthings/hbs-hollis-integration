guard 'spork', rspec_env: { 'RAILS_ENV' => 'test' } do
  watch('config/application.rb')
  watch('config/environment.rb')
  watch('config/environments/test.rb')
  watch('config/routes.rb')
  watch(%r{^config/initializers/.+\.rb$})
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb') { :rspec }
  watch(%r{features/support/}) { :cucumber }
end

guard :rspec, after_all_pass: false, cmd: 'rspec --drb' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb') { "spec" }
  watch(%r{^spec/support/(.+)\.rb$}) { "spec" }

  watch(%r{^app/(.+)\.rb$}) do |m|
    "spec/#{m[1]}_spec.rb"
  end

  watch(%r{^app/controllers/(.+)_(controller)\.rb$}) do |m|
    [
      "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb",
      "spec/features/#{m[1]}_spec.rb"
    ]
  end

  watch('app/controllers/application_controller.rb') do
    [
      "spec/controllers",
      "spec/features"
    ]
  end

  watch(%r{^app/views/(.+)/.*\.(erb|slim|json|rb)$}) do |m|
    "spec/features/#{m[1]}_spec.rb"
  end
end

guard 'livereload' do
  watch(%r{app/views/.+\.(erb|slim)$})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{public/.+\.(css|js|html)})
  watch(%r{config/locales/.+\.yml})
  # Rails Assets Pipeline
  watch(%r{(app|vendor)(/assets/\w+/(.+\.(css|js|html|png|jpg))).*}) { |m| "/assets/#{m[3]}" }
end
