class Mosaicc
	def self.image_perform
			# get the login user Profile image
			user = FbGraph::User.new('me', :access_token => User.first.token)
			user = user.fetch(:fields => "picture,cover, photo")
			profile_picture = user.picture unless user.picture.nil?
			
			image = Magick::ImageList.new  
			urlimage = open(profile_picture) 
			source = image.from_blob(urlimage.read)
			
			source_width = 5
			source.resize_to_fit! source_width, (source.rows/source.columns) * source_width
			
			source_pixels = []
			source.each_pixel do |pixel, x, y|
				source_pixels << { 'red' => pixel.red, 'green' => pixel.green, 'blue' => pixel.blue }
			end
			
			mosaic_images = Magick::ImageList.new
			tile = Magick::Rectangle.new("0".to_i, "0".to_i, 0, 0)
			# Here collect the Friends profile images
			
			@photo=(user.friends).map(&:picture).take(10)
				
			# Pass the Friends images and find them mean colors
			mean_color = Photo.fetch_mean_color(@photo)
			i = 0
			source.rows.times do |row|
				source.columns.times do |col|
				  p i
					p photo_path = Photo.match_pixel(source_pixels[i],mean_color)
					image = Magick::ImageList.new  
					begin
						urlimage = open(photo_path+"?width=25&height=25")
						p photo = image.from_blob(urlimage.read)
						mosaic_images << photo.crop_resized!("25".to_i, "25".to_i)
						tile.x = col * mosaic_images.columns
						tile.y = row * mosaic_images.rows
						mosaic_images.page = tile
		      rescue
		      end						
					i += 1
				end
			end
			mosaic = mosaic_images.mosaic
			mosaic.write("mosaic_photo"+rand(1..199).to_s+".jpg")
	end
end	
	