#
# Copyright (c) 2006-2019 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Network

      # This class handles the routing of RESTful API requests that interact with network services on the zombie's LAN
      class NetworkRest < BeEF::Core::Router::Router

        # Filters out bad requests before performing any routing
        before do
          config = BeEF::Core::Configuration.instance
          @nh = BeEF::Core::Models::NetworkHost
          @ns = BeEF::Core::Models::NetworkService

          # Require a valid API token from a valid IP address
          halt 401 unless params[:token] == config.get('beef.api_token')
          halt 403 unless BeEF::Core::Rest.permitted_source?(request.ip)

          headers 'Content-Type' => 'application/json; charset=UTF-8',
                  'Pragma' => 'no-cache',
                  'Cache-Control' => 'no-cache',
                  'Expires' => '0'
        end

        # Returns the entire list of network hosts for all zombies
        get '/hosts' do
          hosts = @nh.all(:unique => true, :order => [:id.asc])
          count = hosts.length

          result = {}
          result[:count] = count
          result[:hosts] = []
          hosts.each do |host|
            result[:hosts] << host2hash(host)
          end

          result.to_json
        rescue StandardError => e
          print_error "Internal error while retrieving host list (#{e.message})"
          halt 500
        end

        # Returns the entire list of network services for all zombies
        get '/services' do
          services = @ns.all(:unique => true, :order => [:id.asc])
          count = services.length

          result = {}
          result[:count] = count
          result[:services] = []
          services.each do |service|
            result[:services] << service2hash(service)
          end

          result.to_json
        rescue StandardError => e
          print_error "Internal error while retrieving service list (#{e.message})"
          halt 500
        end

        # Returns all hosts given a specific hooked browser id
        get '/hosts/:id' do
          id = params[:id]

          hosts = @nh.all(:hooked_browser_id => id, :unique => true, :order => [:id.asc])
          count = hosts.length

          result = {}
          result[:count] = count
          result[:hosts] = []
          hosts.each do |host|
            result[:hosts] << host2hash(host)
          end

          result.to_json
        rescue InvalidParamError => e
          print_error e.message
          halt 400
        rescue StandardError => e
          print_error "Internal error while retrieving hosts list for hooked browser with id #{id} (#{e.message})"
          halt 500
        end

        # Returns all services given a specific hooked browser id
        get '/services/:id' do
          id = params[:id]

          services = @ns.all(:hooked_browser_id => id, :unique => true, :order => [:id.asc])
          count = services.length

          result = {}
          result[:count] = count
          result[:services] = []
          services.each do |service|
            result[:services] << service2hash(service)
          end

          result.to_json
        rescue InvalidParamError => e
          print_error e.message
          halt 400
        rescue StandardError => e
          print_error "Internal error while retrieving service list for hooked browser with id #{id} (#{e.message})"
          halt 500
        end

        # Returns a specific host given its id
        get '/host/:id' do
          id = params[:id]

          host = @nh.all(:id => id)
          raise InvalidParamError, 'id' if host.nil?
          halt 404 if host.empty?

          host2hash(host).to_json
        rescue InvalidParamError => e
          print_error e.message
          halt 400
        rescue StandardError => e
          print_error "Internal error while retrieving host with id #{id} (#{e.message})"
          halt 500
        end

        # Deletes a specific host given its id
        delete '/host/:id' do
          id = params[:id]
          raise InvalidParamError, 'id' unless BeEF::Filters::nums_only?(id)

          host = @nh.all(:id => id)
          halt 404 if host.nil?

          result = {}
          result['success'] = @nh.delete(id)
          result.to_json
        rescue InvalidParamError => e
          print_error e.message
          halt 400
        rescue StandardError => e
          print_error "Internal error while removing network host with id #{id} (#{e.message})"
          halt 500
        end

        # Returns a specific service given its id
        get '/service/:id' do
          id = params[:id]

          service = @ns.all(:id => id)
          raise InvalidParamError, 'id' if service.nil?
          halt 404 if service.empty?

          service2hash(service).to_json
        rescue InvalidParamError => e
          print_error e.message
          halt 400
        rescue StandardError => e
          print_error "Internal error while retrieving service with id #{id} (#{e.message})"
          halt 500
        end

        private

        # Convert a Network Host object to JSON
        def host2hash(host)
          {
            :id => host.id,
            :hooked_browser_id => host.hooked_browser_id,
            :ip => host.ip,
            :hostname => host.hostname,
            :type => host.type,
            :os => host.os,
            :mac => host.mac,
            :lastseen => host.lastseen
          }
        end

        # Convert a Network Service object to JSON
        def service2hash(service)
          {
            :id => service.id,
            :hooked_browser_id => service.hooked_browser_id,
            :proto => service.proto,
            :ip => service.ip,
            :port => service.port,
            :type => service.type,
          }
        end

        # Raised when invalid JSON input is passed to an /api/network handler.
        class InvalidJsonError < StandardError
          DEFAULT_MESSAGE = 'Invalid JSON input passed to /api/network handler'

          def initialize(message = nil)
            super(message || DEFAULT_MESSAGE)
          end
        end

        # Raised when an invalid named parameter is passed to an /api/network handler.
        class InvalidParamError < StandardError
          DEFAULT_MESSAGE = 'Invalid parameter passed to /api/network handler'

          def initialize(message = nil)
            str = "Invalid \"%s\" parameter passed to /api/network handler"
            message = sprintf str, message unless message.nil?
            super(message)
          end
        end
      end
    end
  end
end
