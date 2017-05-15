require 'rest-client'
require 'active_support/all'
require 'ostruct'

module Clickatell
  module Client extend self

    def configure
      @config ||= OpenStruct.new({ api_base: "https://platform.clickatell.com" })
      yield @config if block_given?
      @config
    end

    def config
      @config || configure
    end

    ALLOWED_OPTIONS = [:binary, :from, :validityPeriod, :userDataHeader, :scheduledDeliveryTime, :clientMessageId]

    def deliver!(to, content, options = {})
      raise "No API token provided" if config.api_token.nil?

      payload = {
        to: to,
        content: content,
        binary: false,
        charset: 'UTF-8'
      }.merge(options.slice(*ALLOWED_OPTIONS))

      response = RestClient.post("#{config.api_base}/messages", payload.to_json, { content_type: :json, accept: :json, 'Authorization' => config.api_token })
      if response.code == 202
        messages = JSON.parse(response.body)
      end
    end
  end
end
