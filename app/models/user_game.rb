class UserGame < ActiveRecord::Base
  attr_accessible :balance, :game_id, :is_active, :points, :total_value_in_stocks, :user_id, :get_rank

  # Relationships
  # -----------------------------
  has_many :purchased_stocks
  belongs_to :user
  belongs_to :game

  #Scopes
  # -----------------------------
  scope :by_balance, order('balance DESC')
  scope :for_game, lambda { |x| where("game_id = ?", x) }
  scope :for_user, lambda { |x| where("user_id = ?", x) }
  scope :current, joins(:game).where('start_date <= ?', Time.now).where('end_date > ?', Time.now).where('is_terminated = ?', false)
  scope :upcoming, joins(:game).where('start_date > ?', Time.now).where('is_terminated = ?', false)
  scope :past, joins(:game).where('end_date <= ?', Time.now)
  scope :ending_soonest, joins(:game).order('end_date, start_date')
  scope :starting_soonest, joins(:game).order('start_date, end_date')
  scope :most_recent, joins(:game).order('end_date DESC, start_date DESC')

  # Methods
  # -----------------------------
  def get_rank
    hash = Hash[UserGame.for_game(self.game.id).by_balance.map.with_index.to_a]
    return hash[self] + 1
  end

  def get_ROI
    require 'yahoo_stock'

    stocks = []
    qtys = []
    for purchase in PurchasedStock.for_user_game(self.id)
      stocks += [purchase.stock_code]
      qtys += [purchase.total_qty]
    end

    values = [0] * stocks.length
    for i in (0..stocks.length-1)
      yesterday_price = (YahooStock::History.new(:stock_symbol => stocks[i], :start_date => Date.today-1, :end_date => Date.today-1)).results(:to_array).output[0][4].to_f
      values[i] = yesterday_price
    end

    qtys_and_values = [0] * stocks.length
    for i in (0..stocks.length-1)
      qtys_and_values[i] = [qtys[i] * values[i]]
    end
    total_value = 0
    for price in qtys_and_values
      total_value += price[0]
    end
    return (self.total_value_in_stocks-(total_value * 100))/(total_value * 100)
  end
  
end
