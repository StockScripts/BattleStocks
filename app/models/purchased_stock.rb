class PurchasedStock < ActiveRecord::Base
  attr_accessible :money_earned, :money_spent, :stock_code, :total_qty, :user_game_id, :value_in_stocks, :get_price

  # Relationships
  # -----------------------------
  has_many :transactions
  belongs_to :user_game

  # Callbacks
  # -----------------------------
  before_create :stock_code_upper

  # Scope
  # -----------------------------
  scope :for_user_game, lambda { |x| where("user_game_id = ?", x) }
  scope :for_game, lambda { |x| joins(:user_game).where("game_id = ?", x) }
  scope :for_user, lambda { |x| joins(:user_game).where("user_id = ?", x) }

  # Methods
  # -----------------------------
  def stock_code_upper
  	self.stock_code.upcase!
  end

  def get_price
    require 'yahoo_stock'
    return ((YahooStock::Quote.new(:stock_symbols => [self.stock_code]).results(:to_array).output[0][1].to_f) * 100).to_i
  end

end
