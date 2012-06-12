# Attachinary

Handling image and raw file attachments with ease. It uses [Cloudinary](http://cloudinary.com) as storage. 



## Installation

Make sure that you have [cloudinary gem](https://github.com/cloudinary/cloudinary_gem) installed and properly configured. Then, run following rake command in terminal:

	rake attachinary:install:migrations
	rake db:migrate
	
It will create two tables. One for storing files and other for association with your models.


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

That's it. There is no more to it :)

Attachinary jquery plugin is based upon [jQuery File Upload plugin](https://github.com/blueimp/jQuery-File-Upload) but without any fancy UI (it leaves it up to you to decorate it).

Plugin is fully customizable. It uses John Resig's micro templating in the background, but you can override it with whatever you like. Check out the source code for more configuration options you can set.


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