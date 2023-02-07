# frozen_string_literal: true

require 'sinatra'
require 'http'
require 'pry'

Thread.new do
  pp 'Sitting on table'
  sleep(1)
  HTTP.post('http://localhost:4000/api/players/sit',
            json: { id: ENV.fetch('PLAYER', nil), url: ENV.fetch('URL', nil) })
end

get '/ping' do
  'PONG'
end

# post '/action' do
#   200
# end

post '/action' do
  content_type 'application/json'

  payload = JSON.parse(request.body.read, symbolize_names: true)

  table = Table.new(payload[:table])
  player = Player.new(payload[:player])
  action, bid = Action.new(table, player).action

  { bid:, action: }.to_json
end

class Table
  attr_reader :pot
  attr_reader :big_blind
  attr_reader :stage
  attr_reader :board

  def initialize(attrs)
    @pot = attrs[:pot]
    @big_blind = attrs[:big_blind]
    @stage = attrs[:stage]
    @board = attrs[:board]
  end
end

class Player
  attr_reader :hand
  attr_reader :chips
  attr_reader :to_call
  attr_reader :bids

  def initialize(attrs)
    @hand = attrs[:hand]
    @chips = attrs[:chips]
    @to_call = attrs[:to_call]
    @bids = attrs[:bids]
  end
end

class Action
  attr_reader :table
  attr_reader :player

  def initialize(table, player)
    @table = table
    @player = player
  end

  def action
    case rand(0..100)
    when 0..10
      ['fold', 0]

    when 11..40
      bid =
        if player.to_call < table.big_blind * 2
          rand(player.to_call..table.big_blind * 2)
        else
          player.to_call
        end
      ['bid', bid]

    when 41..100
      ['bid', player.to_call]
    end
  end
end
