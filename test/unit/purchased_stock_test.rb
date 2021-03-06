require 'test_helper'

class PurchasedStockTest < ActiveSupport::TestCase
  # relationship macros 
  should have_many(:transactions)
  should belong_to(:user_game)

  # testing validations
  # -----------------------------
  should validate_presence_of :money_earned
  should validate_presence_of :money_spent
  should validate_presence_of :stock_code
  should validate_presence_of :total_qty
  should validate_presence_of :user_game_id
  should validate_presence_of :value_in_stocks

  # stock codes
  # -----------------------------
  should allow_value("asdf").for(:stock_code)
  should allow_value("AAPL2").for(:stock_code)
  should_not allow_value("").for(:stock_code)

  # money_earned
  # -----------------------------
  should validate_numericality_of :money_earned
  should allow_value(1000000).for(:money_earned)
  should allow_value(0).for(:money_earned)
  should_not allow_value("asdfasdf").for(:money_earned)
  should_not allow_value(-10000).for(:money_earned)

  # money_spent
  # -----------------------------
  should validate_numericality_of :money_spent
  should allow_value(1000000).for(:money_spent)
  should allow_value(0).for(:money_spent)
  should_not allow_value("asdfasdf").for(:money_spent)
  should_not allow_value(-10000).for(:money_spent)

  # total_qty
  # -----------------------------
  should validate_numericality_of :total_qty
  should allow_value(1000000).for(:total_qty)
  should allow_value(0).for(:total_qty)
  should_not allow_value("asdfasdf").for(:total_qty)
  should_not allow_value(-10000).for(:total_qty)

  # value_in_stocks
  # -----------------------------
  should validate_numericality_of :value_in_stocks
  should allow_value(1000000).for(:value_in_stocks)
  should allow_value(0).for(:value_in_stocks)
  should_not allow_value("asdfasdf").for(:value_in_stocks)
  should_not allow_value(-10000).for(:value_in_stocks)

   context "Creating one game" do
     # create the objects I want with factories
     setup do 
       @alex = FactoryGirl.create(:user, :email => "test@gmail.com", :username => "testuser1")
       @game1 = FactoryGirl.create(:game, :name => "test gameeee", :start_date => Time.now.to_date, 
       :end_date => 10.days.from_now.to_date, :budget => 10)
       @usergame1 = FactoryGirl.create(:user_game, :user_id => @alex.id, :game_id => @game1.id, :balance => 2000, :is_active => true, :points => 200, :total_value_in_stocks => 3000)
       @goog = FactoryGirl.create(:purchased_stock, :user_game_id => @usergame1.id, 
        :stock_code => "goog", :total_qty => 40, :money_spent => 5000, :money_earned => 0,
        :value_in_stocks => 80)
       @aapl = FactoryGirl.create(:purchased_stock, :user_game_id => @usergame1.id, 
        :stock_code => "aapl", :total_qty => 0, :money_spent => 0, :money_earned => 0,
        :value_in_stocks => 80)
       @transaction1 = FactoryGirl.create(:transaction, :purchased_stock_id => @goog.id, :date => Time.now.to_date, :qty => 40, :value_per_stock => 45000, :is_buy => true)
     end

     # and provide a teardown method as well
     teardown do
       @alex.destroy
       @usergame1.destroy
       @game1.destroy
       @goog.destroy
       @aapl.destroy
       @transaction1.destroy
     end


     # now run the tests:
     # test one of each factory (not really required, but not a bad idea)
     should "show that all factories are properly created" do
       assert_equal "test@gmail.com", @alex.email
       assert_equal "testuser1", @alex.username
       assert_equal "test gameeee", @game1.name
       assert_equal @alex.id, @usergame1.user_id
       assert_equal "GOOG", @goog.stock_code
       assert_equal "AAPL", @aapl.stock_code
       assert_equal 40, @transaction1.qty
     end
 

   # now run tests:
   # test the scope 'for_user_game'
   should "show all purchased_stocks for a particular user_game" do
        assert_equal @goog, PurchasedStock.for_user_game(@usergame1).first
        assert_equal @aapl, PurchasedStock.for_user_game(@usergame1).second
        assert_equal 2, PurchasedStock.for_user_game(@usergame1).size
   end

   # test the scope 'for_game'
   should "show all purchased stocks for a particular game" do
        assert_equal @goog, PurchasedStock.for_game(@game1).first
        assert_equal @aapl, PurchasedStock.for_game(@game1).second
        assert_equal 2, PurchasedStock.for_game(@game1).size
   end

   # test the scope 'for_user'
   should "show all purchased stocks for a particular user" do
        assert_equal @goog, PurchasedStock.for_user(@alex).first
        assert_equal @aapl, PurchasedStock.for_user(@alex).second
        assert_equal 2, PurchasedStock.for_user(@alex).size
   end

   # test the scope 'nonzero_cost_basis'
   should "show all the purchased stocks that have money spent > 0" do
        assert_equal @goog.id, PurchasedStock.nonzero_cost_basis.map{|ps| ps.id}.third
   end

   # test the scope 'nonzero'
   should "show all the purchased_stocks that have total_quantity > 0" do
        assert_equal @goog.id, PurchasedStock.nonzero.map{|ps| ps.id}.third
   end

   # test the method stock_code_upper
   should "show all stock codes in upper case" do
        assert_equal "GOOG", @goog.stock_code
        assert_equal "AAPL", @aapl.stock_code
   end
   
   # test the method get_price 
   should "show the price fora particular purchased_stock " do 
        puts @goog.get_price
        puts @aapl.get_price
   end  
   
  end
end
