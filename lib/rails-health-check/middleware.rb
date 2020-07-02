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
        elsif overall_health_path?(env['PATH_INFO'])
          overall_health_response
        end
      else
        @app.call(env)
      end
    end

    protected

    def health_path?(request_path)
      health_latency_path?(request_path) || health_db_path?(request_path) || overall_health_path?(request_path)
    end

    def health_latency_path?(request_path)
      request_path == '/health/latency'
    end

    def health_db_path?(request_path)
      request_path == '/health/db'
    end

    def overall_health_path?(request_path)
      request_path == '/health'
    end
    
    def health_latency_response
      # [status, headers, body]
      [200, { 'Content-Type' => 'application/json' }, [{ msg: 'ok' }.to_json]]
    end

    def health_db_response
      begin
        raise 'Database does not exists' if !database_exists?
        raise 'Database not migrated' if needs_migration?

        status = 200
        msg = 'ok'
      rescue => e
        status = 500
        msg = e.message
      end

      # [status, headers, body]
      [status, { 'Content-Type' => 'application/json' }, [{ msg: msg }.to_json]]
    end

    def overall_health_response
      begin
        raise 'Database does not exists' if !database_exists?
        raise 'Database not migrated' if needs_migration?

        status = 200
        msg = 'ok'

      rescue => e
        status = 500
        msg = e.message
      end

      # [status, headers, body]
      [status, { 'Content-Type' => 'application/json' }, [{ msg: msg }.to_json]]
    end

    def database_exists?
        ActiveRecord::Base.connection
      rescue ActiveRecord::NoDatabaseError
        false
      else
        true
    end

    def needs_migration?
      return true if !database_exists?
      if ActiveRecord::Base.connection.respond_to?(:migration_context)
        # Rails >= 5.2
        ActiveRecord::Base.connection.migration_context.needs_migration?
      else
        ActiveRecord::Migrator.needs_migration?
      end
    end
  end
end