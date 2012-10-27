namespace :attachinary do

  desc 'fetches required jQuery File Upload files from github'
  task :fetch_fileupload do
    require 'open-uri'
    require 'uri'

    urls = %w[
      https://raw.github.com/blueimp/jQuery-File-Upload/master/js/vendor/jquery.ui.widget.js
      https://raw.github.com/blueimp/jQuery-File-Upload/master/js/jquery.iframe-transport.js
      https://raw.github.com/blueimp/jQuery-File-Upload/master/js/jquery.fileupload.js
    ]

    dir = Rails.root.join("vendor/assets/javascripts")
    FileUtils.mkdir_p dir.to_s

    urls.each do |url|
      uri = URI.parse(url)
      filename = uri.path.split('/').last
      puts "Getting #{filename}"

      dest = File.open(dir.join(filename), "w")
      dest.puts open(url).read
      dest.close
    end
  end

end
