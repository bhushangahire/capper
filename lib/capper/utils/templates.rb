require "erubis"

module Capper
  module Utils
    module Templates

      # render an erb template from config/deploy/templates to the current
      # server list. this will render and upload templates serially using a
      # server-specific @variables binding. see get_binding for details.
      def upload_template_file(name, path, options={})
        template = "config/deploy/templates/#{name}.erb"

        unless File.exist?(template)
          template = File.expand_path("../../templates/#{name}.erb", __FILE__)
        end

        str = File.open(template).read
        upload_template_string(str, path, options)
      end

      def upload_template_string(str, path, options={})
        upload_template(path, options) do |server|
          str
        end
      end

      def upload_template(path, options={})
        if task = current_task
          servers = find_servers_for_task(task, options)
        else
          servers = find_servers(options)
        end

        if servers.empty?
          raise Capistrano::NoMatchingServersError, "no servers matching #{task.options.inspect}"
        end

        servers.each do |server|
          erb = Erubis::Eruby.new(yield server)
          result = erb.result(binding())
          put(result, path, options.merge!(:hosts => server))
        end
      end

    end
  end
end
