class ArticlesController < ApplicationController
  before_action :set_article, only: %i[show edit update destroy]
  before_action :current_visitor

  def current_visitor
    @current_visitor ||= User.find_by(id: session[:visitor_id]) || create_current_visitor
  end

  def create_current_visitor
    last_user = User.last
    last_user_id = if last_user.nil?
                     0
                   else
                     last_user.id
                   end
    new_user = User.create(ref: last_user_id + 1)
    session[:visitor_id] = new_user.id

    new_user
  end

  # GET /articles or /articles.json
  def index
    store_search_history(params[:query]) if params[:query].present?
    @articles = if params[:query].present?
                  Article.where('lower(title) LIKE ?', "%#{params[:query].downcase}%")
                else
                  Article.all
                end

    if turbo_frame_request?
      render partial: 'articles', locals: { articles: @articles }
    else
      render :index
    end
  end

  def store_search_history(search_data)
    search_history = SearchHistory.where(user: @current_visitor)
    p search_history
    single_search = search_related(search_history, search_data)
    if single_search 
      single_search.update(search_string: search_data)
    else
      SearchHistory.create(search_string: search_data, user: @current_visitor)
    end
  end

  def search_related(search_history, search_data)
    search_history.each do |history|
      return history if search_data.include? history.search_string
    end
    nil
  end

  # GET /articles/1 or /articles/1.json
  def show; end

  # GET /articles/new
  def new
    @article = Article.new
  end

  # GET /articles/1/edit
  def edit; end

  # POST /articles or /articles.json
  def create
    @article = Article.new(article_params)

    respond_to do |format|
      if @article.save
        format.html { redirect_to article_url(@article), notice: 'Article was successfully created.' }
        format.json { render :show, status: :created, location: @article }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /articles/1 or /articles/1.json
  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to article_url(@article), notice: 'Article was successfully updated.' }
        format.json { render :show, status: :ok, location: @article }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1 or /articles/1.json
  def destroy
    @article.destroy

    respond_to do |format|
      format.html { redirect_to articles_url, notice: 'Article was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_article
    @article = Article.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def article_params
    params.require(:article).permit(:title, :publisher, :pbulished_year)
  end
end
