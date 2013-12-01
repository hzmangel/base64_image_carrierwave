## Save base64 image with carrierwave and bootstrap-wysiwyg

Note: This is copied from [my blog][4]

### tl;dr
The pasted image will be converted to base64 encoded format, which will hit response size limitation of server. This article is talking about save image to file with carrierwave.

The source code is available at [github repo][5]


Next is the full version.

### The problem

Recently I have faced a task to upload a image by a rich format text editor. The web server is Rails, so I selected [carrierwave][1] as the upload gem, and [bootstrap-wysiwyg][2] as rich format text editor.

`bootstrap-wysiwyg` supports inserting image into edit area, and uploaded image via base64. Every thing is okay in development enviromnent, but I have met problem while deploying to production server.

The root cause of the problem is response size exceed the max limitation. The uploaded base64 encoded image are saved as string, and will be returned in response body. I have tried increasing response body size limitation but take no effect, so I switched to method that saving image to file.


### Solution

This section only shows how to get image and save via carrierwave, please refer to the source of the other contents.

The sample project is a simple post manage system, each post contains `title` and `content` field, and the `content` field is rich format text.

The passed in base64 encoded image is started with this string:

    data:image/jpeg;base64,

Then following the image data.

The image uploaded is surrounded by `<img>` tag, so I added a pre processing to the content uploaded. The logic is simple: save found `<img>` tag to a file with carrierwave, and replace the base64 data to file path. The primary code is here:

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

`PostImage` is a model used for saving image. `CarrierStringIO` is also a user defined class to provide functions `original_filename` and `content_type`, which are required by `carrierwave`. Here is the definition of this class:

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

The last thing is the carrierwave uploader: `PostImageUploader`. This is a simple uploader that only save the image to file.

    # encoding: utf-8

    class PostImageUploader < CarrierWave::Uploader::Base

      storage :file

      def store_dir
        "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
      end

    end

In the sample project, the file type and file name are hard coded in `CarrierStringIO`, please feel free to modify code as needed.

Note: There is an bug of the code: The image can't be extracted out if inserted into a text paragraph. I will fix this once I have time.

[1]: https://github.com/carrierwaveuploader/carrierwave
[2]: http://mindmup.github.io/bootstrap-wysiwyg/
[3]: http://en.wikipedia.org/wiki/Base64
[4]: http://blog.hzmangel.info/
[5]: https://github.com/hzmangel/base64_image_carrierwave

