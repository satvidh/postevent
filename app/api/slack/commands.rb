require 'slack-ruby-client'
require 'json'
require 'securerandom'

module Slack
	class Commands < Grape::API
		resource :hello do
			params do
        		requires :trigger_id, type: String, desc: 'Trigger ID.'
      		end
			post do
				# Check if the user with the user id exists in the database.
				user_id = params[:user_id]
				user = User.find_by_slack_user_id(user_id)
				client = Slack::Web::Client.new(token: ENV['SLACK_API_TOKEN'])
				client.auth_test
				if user
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
				else
					channel_id = params[:channel_id]
					user_name = params[:user_name]
					# Associate the slack user id with a nonce.
					association_nonce = SecureRandom.hex()
					association = Association.new(:user_id => user_id, :nonce => association_nonce, :expired => false)
					association.save
					# Get the URL to return to the user
					# association_link = Commands.link_to("Click Here", controller: 'associations', action: 'slack', nonce: association.nonce)
					# association_link = "https://#{request.host_with_port}/associations/slack?nonce=#{association.nonce}"
					association_link = "https://#{request.host_with_port}/logout?nonce=#{association.nonce}"
					client.chat_postEphemeral(channel: channel_id,
											  text: "You (#{user_name}) are not authorized for this command. link expired=#{association.expired}. Click on #{association_link} to authorize.",
											  user: user_id)
				end
			end
		end
	end
end
