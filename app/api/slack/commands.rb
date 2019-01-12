require 'slack-ruby-client'
require 'json'

module Slack
	class Commands < Grape::API
		resource :hello do
			params do
        		requires :trigger_id, type: String, desc: 'Trigger ID.'
      		end
			post do
				client = Slack::Web::Client.new(token: ENV['SLACK_API_TOKEN'])
				client.auth_test
				# client.chat_postMessage(channel: '#random', text: params[:trigger_id], as_user: true)
				dialog_definition = {
					callback_id: "ryde-46e2b0",
					title: "Request a Ride",
					submit_label: "Request",
					notify_on_cancel: true,
					state: "Limo",
					elements: [
						{
							type: "text",
							label: "Pickup Location",
							name: "loc_origin"
						},
						{
							type: "text",
							label: "Dropoff Location",
							name: "loc_destination"
						}
					]
  			    }
				dialog = JSON.generate(dialog_definition)
				client.dialog_open(trigger_id: params[:trigger_id], dialog: dialog)
			end
		end
	end
end
