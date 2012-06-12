# Attachinary

Handling image and raw file attachments with ease.
It uses [Cloudinary](http://cloudinary.com) as storage.

It is structured as mountable rails engine.


## Installation

Add following line to your `Gemfile`:

    gem 'attachinary'

Then, run following rake command in terminal to create necessary tables:

	rake attachinary:install:migrations
	rake db:migrate

Add following line in your `routes.rb` file to mount the engine:

	mount Attachinary::Engine => "/attachinary"
	
That's it. Oh, and make sure that you have [cloudinary gem](https://github.com/cloudinary/cloudinary_gem) installed and properly configured.


## Usage

Lets say that we want all of our **users** to have single **avatar** and many **photos** in their gallery. We also want *avatar* to be required. We also want to limit the number of photos user can upload to 10. We can declare it like this:

	class User < ActiveRecord::Base
		...
		has_attachment  :avatar, accept: ['jpg', 'png', 'gif']
		has_attachments :photos, maximum: 10

		validates :avatar_id, presence: true
		...
	end

In our `_form.html.erb` template, we need to add only this:

	<%= attachinary_file_field_tag 'user[avatar_id]', user.avatar_id, attachinary: user.avatar_options %>
	<%= attachinary_file_field_tag 'user[photo_ids]', user.photo_ids, attachinary: user.photo_options %>

If you're using [SimpleForm](https://github.com/plataformatec/simple_form), you can even shorten this to:

	<%= f.input :avatar, as: :attachinary %>
	<%= f.input :photos, as: :attachinary %>

Finally, you have to include `attachinary` into your asset pipeline. In your `application.js`, add following line:

	//= require attachinary

And, add this code on document ready:

	$('.attachinary-input').attachinary()

Attachinary jquery plugin is based upon [jQuery File Upload plugin](https://github.com/blueimp/jQuery-File-Upload) but without any fancy UI (it leaves it up to you to decorate it).

Plugin is fully customizable. It uses John Resig's micro templating in the background, but you can override it with whatever you like. Check out the source code for more configuration options you can set.

### Displaying avatar and photos

Here comes the good part. There is no need to transform images on your server. Instead, you can request image transformations directly from Cloudinary. First time you request image, it is created and cached on the Cloudinary server for later use. Here is sample code that you can use in your `_user.html.erb` partial:
	
	<% if @user.avatar? %>
		<%= cl_image_tag(@user.avatar.path, { size: '50x50', crop: :face }) %>
	<% end %>
	
	<% @user.photos.each do |photo| %>
		<%= cl_image_tag(photo.path, { size: '125x125', crop: :fit }) %>
	<% end %>

Avatar will be automatically cropped to 50x50px to show only user face. You read it right: **face detection** :) All other user photos are just cropped to fit within 125x125.

Whenever you feel like changing image sizes, you don't need to set rake task that will take forever to re-process thousands of photos. You just change the dimension in your partial and thats it.


## Conventions

* always use singular name for `has_attachment`
* always use plural name for `has_attachments`


## Requirements and Compatibility

* Cloudinary
* Ruby 1.9
* Rails 3.2+


## Credits and License

Developed by Milovan Zogovic.

This software is released under the Simplified BSD License.
