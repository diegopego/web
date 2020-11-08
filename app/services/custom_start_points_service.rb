# frozen_string_literal: true
require_relative 'http_json/requester'
require_relative 'http_json/responder'

class CustomStartPointsService

  class Error < RuntimeError
    def initialize(message)
      super
    end
  end

  def initialize(externals)
    hostname = 'custom-start-points'
    port = ENV['CYBER_DOJO_CUSTOM_START_POINTS_PORT'].to_i
    requester = HttpJson::Requester.new(externals.http, hostname, port)
    @http = HttpJson::Responder.new(requester, Error, {keyed:true})
  end

  def ready?
    @http.get(__method__, {})
  end

  def names
    @http.get(__method__, {})
  end

  def manifests
    @http.get(__method__, {})
  end

  def manifest(name)
    @http.get(__method__, { name:name })
  end

end
