require 'test_helper'

class TransactionTest < ActiveSupport::TestCase
  # relationship macros
  should belong_to(:purchased_stock)
  
   # Presence of...1
   should validate_presence_of(:date)
   should validate_presence_of(:is_buy)
   should validate_presence_of(:purcased__stock_id)
   should validate_presence_of(:qty)
   should validate_presence_of(:value_per_stock)
   should validate_presence_of(:stock_code)
   should validate_presence_of(:game_id)
   
   # Date format
   should allow_value(Time.now.to_date).for(:date)
   should allow_value(10.days.from_now.to_date).for(:date)
   should_not allow_value("asdfasdf").for(:date)
   
   # is_buy
   should allow_value(true).for(:is_buy)
   should allow_value(false).for(:is_buy)
   should_not allow_value("apple").for(:is_buy)
   should_not allow_value(12).for(:is_buy)
   
   # qty
   should allow_value(23).for(:qty)
   should_not allow_value("eight").for(:qty)
   
   # stock code
   
   # value_per stock
   should allow_value(23).for(:value_per_stock)
   should_not allow_value("eight").for(:value_per_stock)
   
   
   context "Creating one game" do
     # create the objects I want with factories
     setup do 
       @alex = FactoryGirl.create(:user, :email => "test@gmail.com", :username => "testuser1")
       @game1 = FactoryGirl.create(:game, :manager_id => @alex, :name => "test gameeee", :start_date => Time.now.to_date, 
       :end_date => 10.days.from_now.to_date, :budget => 10)
       @usergame1 = FactoryGirl.create(:user_game, :user_id => @alex, :game_id => @game1)
       @goog = FactoryGirl.create(:purchased_stock, :user_game => @usergame1, 
        :stock_code => 23, :total_quantity => 40, money_spent => 5000, :money_earned => 509000,
        :value_in_stocks => 80)
       @transaction1 = FactoryGirl.create(:transaction, :purchased_stock => @goog, :date => Time.now.to_date, :qty => 40, :value_per_stock => 45000, :is_buy => true)
     end

     # and provide a teardown method as well
     teardown do
       @alex.destroy
       @usergame1.destroy
       @game1.destroy
       @goog.destroy
       @transaction1.destroy
     end
     
     # now run the tests:
     # test one of each factory (not really required, but not a bad idea)
     should "show that all factories are properly created" do
       assert_equal "test@gmail.com", @alex.email
       assert_equal "testuser1", @alex.username
       assert_equal "test gameeee", @game1.name
       assert_equal 23, @goog.stock_code
       assert_equal 40, @transaction1.qty
     end

   # test the method get_price_and_update_purchased_stock_and_user_game works
  
end
