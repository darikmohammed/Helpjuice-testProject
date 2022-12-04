class ArticlesController < ApplicationController
  before_action :set_article, only: %i[show edit update destroy]
  before_action :current_visitor

  def current_visitor
    @current_visitor ||= User.find_by(id: session[:visitor_id]) || create_current_visitor
    p @current_visitor
    puts 'And'
    p session[:visitor_id]
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
