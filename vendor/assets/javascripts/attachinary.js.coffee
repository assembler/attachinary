(($) ->

  $.attachinary =
    index: 0
    config:
      disableWith: 'Uploading...'
      filesClass: 'attachinary_files'
      removeLabel: 'remove'
      removeClass: ''
      invalidFormatMessage: 'Invalid file format'
      template: """
        <ul>
          <% for(var i=0; i<files.length; i++){ %>
            <li>
              <img
                src="<%= $.cloudinary.url(files[i].public_id, { "version": files[i].version, "format": 'jpg', "crop": 'fill', "width": 75, "height": 75 }) %>"
                alt="" width="75" height="75" />
              <a href="#" data-remove="<%= files[i].public_id %>">Remove</a>
            </li>
          <% } %>
        </ul>
      """
      render: (files) ->
        $.attachinary.Templating.template(@template, files: files)


  $.fn.attachinary = (options) ->
    settings = $.extend $.attachinary.config, options

    this.each ->
      $this = $(this)

      if !$this.data('attachinary-bond')
        $this.data 'attachinary-bond', new $.attachinary.Attachinary($this, settings)



  class $.attachinary.Attachinary
    constructor: (@$input, @config) ->
      @options = @$input.data('attachinary')
      @files = @options.files

      @initFileUpload()
      @addFilesContainer()
      @bindEventHandlers()
      @redraw()
      @checkMaximum()

    initFileUpload: ->
      options =
        maxFileSize: 10000000
        dataType: 'json'
        headers: {"X-Requested-With": "XMLHttpRequest"}

      if @$input.attr('accept')
        options.acceptFileTypes = new RegExp("^#{@$input.attr('accept').split(",").join("|")}$", "i")

      @$input.fileupload(options)


    bindEventHandlers: ->
      @$input.bind 'fileuploaddone', (event, data) =>
        setTimeout (=> @addFile(data.result)), 0 # let 'fileuploadalways' finish

      @$input.bind 'fileuploadstart', (event) =>
        @$input = $(event.target)  # important! changed on every file upload
        $form = @$input.closest('form')
        $submit = $form.find('input[type=submit]')

        @$input.addClass 'uploading'
        $form.addClass  'uploading'

        @$input.prop 'disabled', true
        if @config.disableWith
          $submit.data 'old-val', $submit.val()
          $submit.val  @config.disableWith
          $submit.prop 'disabled', true

      @$input.bind 'fileuploadalways', (event) =>
        $form = @$input.closest('form')
        $submit = $form.find('input[type=submit]')

        @$input.removeClass 'uploading'
        $form.removeClass  'uploading'

        @$input.prop 'disabled', false
        if @config.disableWith
          $submit.val  $submit.data('old-val')
          $submit.prop 'disabled', false

    addFile: (file) ->
      if !@options.accept || $.inArray(file.format, @options.accept) != -1
        @files.push file
        @redraw()
        @checkMaximum()
      else
        alert @config.invalidFormatMessage

    removeFile: (fileIdToRemove) ->
      @files = (file for file in @files when file.public_id != fileIdToRemove)
      @redraw()
      @checkMaximum()

    checkMaximum: ->
      if @options.maximum && @files.length >= @options.maximum
        @$input.prop('disabled', true)
      else
        @$input.prop('disabled', false)

    addFilesContainer: ->
      @$filesContainer = $('<div class="attachinary_container">')
      @$input.after @$filesContainer

    redraw: ->
      @$filesContainer.empty()

      if @files.length > 0
        @$filesContainer.append @makeHiddenField(JSON.stringify(@files))

        @$filesContainer.append @config.render(@files)
        @$filesContainer.find('[data-remove]').on 'click', (event) =>
          event.preventDefault()
          @removeFile $(event.target).data('remove')

        @$filesContainer.show()
      else
        @$filesContainer.append @makeHiddenField(null)
        @$filesContainer.hide()

    makeHiddenField: (value) ->
      $input = $('<input type="hidden">')
      $input.attr 'name', @options.field_name
      $input.val value
      $input




  # JavaScript templating by John Resig's
  $.attachinary.Templating =
    settings:
      start:        '<%'
      end:          '%>'
      interpolate:  /<%=(.+?)%>/g

    escapeRegExp: (string) ->
      string.replace(/([.*+?^${}()|[\]\/\\])/g, '\\$1')

    template: (str, data) ->
      c = @settings
      endMatch = new RegExp("'(?=[^"+c.end.substr(0, 1)+"]*"+@escapeRegExp(c.end)+")","g")
      fn = new Function 'obj',
        'var p=[],print=function(){p.push.apply(p,arguments);};' +
        'with(obj||{}){p.push(\'' +
        str.replace(/\r/g, '\\r')
           .replace(/\n/g, '\\n')
           .replace(/\t/g, '\\t')
           .replace(endMatch,"✄")
           .split("'").join("\\'")
           .split("✄").join("'")
           .replace(c.interpolate, "',$1,'")
           .split(c.start).join("');")
           .split(c.end).join("p.push('") +
           "');}return p.join('');"
      if data then fn(data) else fn

)(jQuery)
