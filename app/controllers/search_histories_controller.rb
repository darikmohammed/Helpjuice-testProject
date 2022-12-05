class SearchHistoriesController < ApplicationController
  def index
    @search_histories = SearchHistory.includes(:user)
    p @search_histories[0].user
  end
end
