module RailsHealthCheck
  class Middleware

    def initialize(app, options={})
      @app = app
    end

    def call(env)
      if env['REQUEST_METHOD'] == 'GET' && health_path?(env['PATH_INFO'])
        if health_latency_path?(env['PATH_INFO'])
          health_latency_response
        elsif health_db_path?(env['PATH_INFO'])
          health_db_response
        end
      else
        @app.call(env)
      end
    end

    protected

    def health_path?(request_path)
      health_latency_path?(request_path) || health_db_path?(request_path)
    end

    def health_latency_path?(request_path)
      request_path == '/health/latency'
    end

    def health_db_path?(request_path)
      request_path == '/health/db'
    end

    def health_latency_response
      # [status, headers, body]
      [200, { 'Content-Type' => 'application/json' }, [{ msg: 'ok' }.to_json]]
    end

    def health_db_response
      begin
        validate_migration

        status = 200
        msg = 'ok'
      rescue => e
        status = 500
        msg = e.message
      end

      # [status, headers, body]
      [status, { 'Content-Type' => 'application/json' }, [{ msg: msg }.to_json]]
    end

    def validate_migration
      # Check connection to the DB and needs migration or not
      if ActiveRecord::Migrator.needs_migration?
        raise 'Schema is not latest!'
      end
    end
  end
end
