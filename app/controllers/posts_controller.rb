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
    @rcd.content = process_base64_content @rcd.content
    if @rcd.save
      redirect_to posts_path
    else
      render :action => :new
    end
  end

  def update
    if @rcd.update(rcd_params)
      @rcd.content = process_base64_content @rcd.content
      @rcd.save
      redirect_to posts_path
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

  def process_base64_content content
    return if content.nil?
    return content if not content.match /</
    rslt = ''
    content.split("<").each do |elem_str|
      if elem_str[0..2] == "img"
        if elem_str.match(%r{data:(.*?);(.*?),(.*?)">$})
          img_data = {
            :type =>      $1, # "image/png"
            :encoder =>   $2, # "base64"
            :data_str =>  $3, # data string
            :extension => $1.split('/')[1] # "png"
          }

          other_img = PostImage.new
          img_data_str = img_data[:data_str]
          img_data_sio = CarrierStringIO.new(Base64.decode64(img_data_str))
          other_img.image = img_data_sio
          other_img.save
          rslt += view_context.image_tag(other_img.image.url)
        else
          rslt += "<#{elem_str}" if not elem_str.empty?
        end
      else
        rslt += "<#{elem_str}" if not elem_str.empty?
      end
    end

    rslt
  end

end
