module RailsHealthCheck
  class Railtie < Rails::Railtie
    initializer 'rails-health-check' do |app|
      app.middleware.insert_after Rails::Rack::Logger, RailsHealthCheck::Middleware
    end
  end
end
