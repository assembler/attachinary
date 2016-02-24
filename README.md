# Attachinary

[![Gem Version](https://badge.fury.io/rb/attachinary.png)](http://badge.fury.io/rb/attachinary)

_Note: v1 is not backward compatible. Refer to [wiki](https://github.com/assembler/attachinary/wiki/Upgrading-to-v1.0) on how to upgrade._

Need lightweight attachment (photos and raw files) handler for any of your model, in either has\_one or has\_many relation, without altering your models' schema and with zero effort? Attachinary is the tool for you!

Why is Attachinary different:

* Supports both **ActiveRecord** and **Mongoid** ORMs!
* **No need to alter your model schema** every time you introduce new kind of attachment.
* Handles **both has\_one and has\_many** use cases.
* **No need for ImageMagick** (or similar) - your thumbnails are generated on the fly by Cloudinary.
* Fully customizable, custom **jQuery plugin** for async file uploads with previews.
* **Files are uploaded directly to Cloudinary** completely bypassing your app (without affecting its performance).
* **Very easy to use**. Once set up, 1 line is enough to add attachment support to your model. **No migrations, no Uploaders**.
* **Lightweight form submission**. Attachinary handles file upload asynchronously and the only thing that is passed to your server is metadata. That makes form postbacks fast and reliable.
* Benefits of [jQuery File Upload](https://github.com/blueimp/jQuery-File-Upload/) (**drag'n'drop**, **selecting multiple files**, **progress indicators**.. etc)
* All the [benefits of Cloudinary](http://cloudinary.com/documentation/image_transformations) (resizing, cropping, rotating, rounding corners, **face detection**...).

Attachinary uses [Cloudinary](http://cloudinary.com) service. Gem is structured as mountable rails engine.


## Installation

First, make sure that you have [cloudinary gem](https://github.com/cloudinary/cloudinary_gem) installed and properly configured.

Add following line to your `Gemfile`:

    gem 'attachinary'

Specify which ORM you wish to use by adding following line to your `application.rb` file (or custom initializer):

	require "attachinary/orm/YOUR_ORM" # active_record or mongoid

If you're using `ActiveRecord` ORM, then run following lines to generate required table:

	rake attachinary:install:migrations
	rake db:migrate

Next, add following line in your `routes.rb` file:

	mount Attachinary::Engine => "/attachinary"

It will generate '/attachinary/cors' which will be used for iframe file transfers (for unsupported browsers).

Finally, make sure that you have following line in head section of your application layout file:

	<%= cloudinary_js_config %>



## Usage

Lets say that we want all of our **users** to have single **avatar** and many **photos** in their gallery. We also want *avatar* to be required. We also want to limit the number of photos user can upload to 10. We can declare it like this:

```ruby
class User < ActiveRecord::Base
	...
	has_attachment  :avatar, accept: [:jpg, :png, :gif]
	has_attachments :photos, maximum: 10

	validates :avatar, presence: true
	# ...
end
```

In our `_form.html.erb` template, we need to add only this:

```erb
<%= f.attachinary_file_field :avatar %>
<%= f.attachinary_file_field :photos %>
```

If you're using [SimpleForm](https://github.com/plataformatec/simple_form), you can even shorten this to:

```erb
<%= f.input :avatar, as: :attachinary %>
<%= f.input :photos, as: :attachinary %>
```

Finally, you have to include necessary javascript files. In your `application.js`, add following lines:

```javascript
//= require jquery.ui.widget
//= require jquery.iframe-transport
//= require jquery.fileupload
//= require cloudinary/jquery.cloudinary
//= require attachinary
```

If you don't have the jQuery File Upload files, you can use following rake task to fetch (or update) them:

```
rake attachinary:fetch_fileupload
```

And, add this code on document ready:

```javascript
$('.attachinary-input').attachinary()
```

Attachinary jquery plugin is based upon [jQuery File Upload plugin](https://github.com/blueimp/jQuery-File-Upload) but without any fancy UI (it leaves it up to you to decorate it).

Plugin is fully customizable. It uses John Resig's micro templating in the background, but you can override it with whatever you like. Check out the source code for more configuration options you can set.


### Displaying avatar and photos

Here comes the good part. There is no need to transform images on your server. Instead, you can request image transformations directly from Cloudinary. First time you request image, it is created and cached on the Cloudinary server for later use. Here is sample code that you can use in your `_user.html.erb` partial:

```erb
<% if @user.avatar? %>
	<%= cl_image_tag(@user.avatar.path, { size: '50x50', crop: :thumb, gravity: :face }) %>
<% end %>

<% @user.photos.each do |photo| %>
	<%= cl_image_tag(photo.path, { size: '125x125', crop: :fit }) %>
<% end %>
```

Avatar will be automatically cropped to 50x50px to show only user face. You read it right: **face detection** :) All other user photos are just cropped to fit within 125x125.

Whenever you feel like changing image sizes, you don't need to set rake task that will take forever to re-process thousands of photos. You just change the dimension in your partial and thats it.


### Additional methods

```ruby
# uploading avatar by passing url
user.avatar_url = "http://path/to/avatar.jpg"

# uploading photos by passing multiple urls
user.photo_urls = %w[ http://path/to/photo1.jpg http://path/to/photo2.jpg]

# uploading by passing IO object (e.g. direct file upload)
user.avatar = File.open("/path/to/file", 'r')

# if you want to provide additionals parameters from http://cloudinary.com/documentation/upload_images
# you need to use diffrent syntax
user.send(:avatar=, File.open("path/to/file", 'r'), :folder => Rails.env.to_s)

# # uploading photos by passing multiple urls and optional parameters that will be added to every file.
user.send(:photo_urls=, %w[ http://path/to/photo1.jpg http://path/to/photo2.jpg], folder: Rails.env.to_s, use_filename: true, image_metadata: true)

```


### No-JS usage

If you don't want fancy JS features, all you have to do is just switch to `:input` file field:

```erb
<%= f.input :photo, as: :file %>
<%= f.input :images, as: :file, input_html: { multiple: true } %>
```

### Preventing n+1 queries when loading attachinary associations

You can eager load attachinary associations.

For example, I have a `user` model that has `photo` and `avatar` as attachments.

```rb
# user.rb
  has_attachment :avatar
  has_attachments :photos

# users_controller.rb
  User.includes(:avatar_files, :photo_files).all
```

## Conventions

* always use singular identifier after `has_attachment` (e.g. `has_attachment :photo`)
* always use plural identifier after `has_attachments` (e.g. `has_attachments :images`)
* do not use colliding identifiers (e.g. `has_attachment :photo` and `has_attachments :photos`) on same model.


## Requirements and Compatibility

* Cloudinary
* Ruby 1.9
* Rails 3.2+
* jQuery


### Browser Compatibility

Attachinary jquery plugin uses JSON2 to generate JSON data.
This works for all major browsers, but if you wish to support older ones (e.g. IE7-), include [json2.js](https://github.com/douglascrockford/JSON-js/blob/master/json2.js).


## Credits and License

Developed by Milovan Zogovic.

This software is released under the MIT License.
