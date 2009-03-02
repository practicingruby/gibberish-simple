$LOAD_PATH.unshift(File.dirname(File.expand_path(__FILE__)) + "/../../lib")
require "sinatra"
require "gibberish/simple"

Gibberish::Simple.language_paths << File.dirname(File.expand_path(__FILE__))
include Gibberish::Simple

get '/rps' do
  redirect '/rps/en'
end

get '/rps/:lang' do
  erb :rps_start
end

post '/rps/:lang' do
  @player_weapon    = params[:weapon]
  @opponent_weapon  = %w[Rock Paper Scissors].sample
  erb :rps_end
end

helpers do
  def end_game_message
    return T("It's a tie", :tie) if @player_weapon == @opponent_weapon

    winning_combos = [["Paper","Rock"],["Rock","Scissor"],["Scissors","Paper"]]
    if winning_combos.include?([@player_weapon, @opponent_weapon])
      T("You Win", :win)
    else
      T("You Lose", :lose)
    end
  end

  def weapon_name(weapon)
    T(weapon, weapon.downcase.to_sym)
  end

  def translated(&block)
    Gibberish::Simple.use_language(params[:lang], &block)
  end
end
