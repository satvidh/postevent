class API < Grape::API
  prefix 'slack'
  format :json
  mount Slack::Commands
  mount Slack::Actions
end