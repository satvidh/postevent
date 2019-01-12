require 'slack-ruby-client'
require 'json'

module Slack
	class Actions < Grape::API
		resource :interaction do
			params do
        		requires :payload, type: String, desc: 'Encoded JSON payload.'
      		end
			post do
				@body = {}
				# client = Slack::Web::Client.new(token: ENV['SLACK_API_TOKEN'])
				# client.auth_test
				# payload = params[:payload]
				# client.chat_postMessage(channel: '#random', text: payload, as_user: true)
			end
		end
	end
end
