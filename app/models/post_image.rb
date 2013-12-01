class CarrierStringIO < StringIO
  def original_filename
    # the real name does not matter
    "image.jpeg"
  end

  def content_type
    # this should reflect real content type, but for this example it's ok
    "image/jpeg"
  end
end

class PostImage
  include Mongoid::Document
  include Mongoid::Timestamps

  def image_data=(data)
    sio = CarrierStringIO.new(Base64.decode64(data))
    self.image = sio
  end

  mount_uploader :image, PostImageUploader
end
