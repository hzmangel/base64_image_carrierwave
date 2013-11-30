class PostsController < ApplicationController
  def index
    @rcds = Post.all
  end
end
