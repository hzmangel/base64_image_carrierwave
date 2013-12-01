class PostsController < ApplicationController
  before_action :set_rcd, only: [:show, :edit, :update, :destroy]

  def index
    @rcds = Post.all
  end

  def new
    @rcd = Post.new
  end

  def edit
  end

  def show
  end

  def create
    @rcd = Post.new(rcd_params)
    if @rcd.save
      redirect_to posts_path
    else
      render :action => :new
    end
  end

  def update
    if @rcd.update(rcd_params)
      redirect_to @rcd
    else
      render :action => :edit
    end
  end

  def destroy
    @rcd.destroy
    redirect_to posts_path
  end

  private

  def set_rcd
    @rcd = Post.find params[:id]
  end

  def rcd_params
    params.require(:post).permit(:title, :content)
  end
end
