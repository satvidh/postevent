require 'slack-ruby-client'

class AssociationsController < ApplicationController
	before_filter :login_required

	def slack
		nonce = params[:nonce]
		association = Association.find_by_nonce(nonce)
		if association
			current_user.update_attributes({:slack_user_id => association.user_id})
			client = Slack::Web::Client.new(token: ENV['SLACK_API_TOKEN'])
			client.auth_test
			client.chat_postMessage(channel: association.user_id,
									text: "You (#{user_name}) are now authorized to post events from slack.",
									as_user: true)
		else
			client.chat_postMessage(channel: "PostEvent", text: "Could not authorize user.", as_user: false)
		end
	end
end