class GamesController < ApplicationController
  require 'will_paginate'
  # GET /games
  # GET /games.json
  
  authorize_resource
  
  def index
    @games = Game.for_user(current_user)

    if logged_in?
      @current_user_games = UserGame.current.for_user(current_user).ending_soonest.paginate(:page => params[:current_games_page]).per_page(5)
      @upcoming_user_games = UserGame.upcoming.for_user(current_user).starting_soonest.paginate(:page => params[:upcoming_games_page]).per_page(5)
      @past_user_games = UserGame.past.for_user(current_user).most_recent.paginate(:page => params[:past_games_page]).per_page(5)

      @owned_stock = PurchasedStock.for_user(current_user)
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @games }
    end
  end

  # GET /games/1
  # GET /games/1.json
  def show
    
    @game = Game.find(params[:id])

    # all users that haven't already been added to the game
    @users_not_added = User.all - User.in_game(@game.id)

    # new user_game for adding more
    @user_game = UserGame.new
    @current_players = UserGame.for_game(@game.id).by_portfolio_value.alphabetical.paginate(:page => params[:game_players_page]).per_page(5)

    # if statement prevents users from viewing a game that they are not in
    if ! @users_not_added.include?(current_user)
      # current_user's data in this game
    
      @current_user_game = UserGame.find_by_user_id_and_game_id(current_user.id, @game.id)
    
      # @purchased_stocks = PurchasedStock.for_user_game(@current_user_game.id).paginate(:page => params[:game_purchased_stocks_page]).per_page(4) 
      @purchased_stocks = PurchasedStock.for_user_game(@current_user_game.id).paginate(:page => params[:game_purchased_stocks_page]).per_page(4)
      @purchased_stocks_array = []
      for stock in @purchased_stocks
        @purchased_stocks_array += [[stock.stock_code, stock.total_qty, stock.get_price, stock.value_in_stocks]]
      end
    

      # update all users' total_value_in_stocks
      require 'yahoo_stock'
      for ugame in UserGame.for_game(@current_user_game.game_id)
        current_value_in_stocks = 0
        for purchase in PurchasedStock.for_user_game(ugame.id)
          if (purchase.total_qty > 0)
            new_value = ((YahooStock::Quote.new(:stock_symbols => [purchase.stock_code]).results(:to_array).output[0][1].to_f) * 100).to_i
            current_value_in_stocks += purchase.total_qty * new_value
            purchase.value_in_stocks = purchase.total_qty * new_value
            purchase.save!
          end
          ugame.total_value_in_stocks = current_value_in_stocks
          ugame.save!
        end
      end
    end
    @transaction = Transaction.new
    @manager = User.find_by_id(@game.manager_id)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @game }
    end
  end

  # GET /games/new
  # GET /games/new.json
  def new
    @game = Game.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @game }
    end
  end

  # GET /games/1/edit
  def edit
    @game = Game.find(params[:id])
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(params[:game])
    @game.manager_id = current_user.id

    @usergame = UserGame.new
    @usergame.user_id = current_user.id

    respond_to do |format|
      if @game.save
        @usergame.game_id = @game.id
        @usergame.balance = @game.budget
        @usergame.save!
        format.html { redirect_to game_path(@game), notice: 'Game was successfully created.' }
        format.json { render json: @game, status: :created, location: @game }
      else
        format.html { render action: "new" }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /games/1
  # PUT /games/1.json
  def update
    @game = Game.find(params[:id])
    @usergames = UserGame.for_game(@game.id)

    respond_to do |format|
      if @game.update_attributes(params[:game])
        @game.budget *= 100
        for usergame in @usergames
          usergame.balance = @game.budget
          usergame.save!
        end
        @game.save!
        format.html { redirect_to game_path(@game), notice: 'Game was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game = Game.find(params[:id])
    @game.destroy

    respond_to do |format|
      format.html { redirect_to games_url }
      format.json { head :no_content }
    end
  end
  
  # Checks that a user is logged in
  before_filter :require_login

  # Manually checks to see that only game managers can edit and update their own games... Cancan gem was faulty
  before_filter :if_game_manager_and_not_admin, :only => [:edit, :update]
  
  private
  
  def require_login
    unless logged_in?
      flash[:error] = "You must be logged in to access this section"
      redirect_to log_in_url # halts request cycle
    end
  end
  
  # Checks to see that if the user is also the manager of a game
  def if_game_manager_and_not_admin
    unless Game.find(params[:id]).manager_id == current_user.id or current_user.is_admin
      flash[:error] = "Nice Try, Prof. H. -- Qapla'!"
      redirect_to root_url # halts request cycle
    end 
  end
end
