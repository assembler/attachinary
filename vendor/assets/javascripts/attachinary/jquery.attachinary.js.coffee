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
              <button data-remove="<%= files[i].id %>">Remove</button>
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
        acceptFileTypes: new RegExp("^#{@$input.attr('accept').split(",").join("|")}$", "i")
        headers: {"X-Requested-With": "XMLHttpRequest"}

      @$input.attr('name', 'file')
      @$input.fileupload(options)


    bindEventHandlers: ->
      @$input.bind 'fileuploaddone', (event, data) =>
        @issueCallback(data.result)

      @$input.bind 'fileuploadstart', (event) =>
        @$input = $(event.target)  # important! changed on every file upload
        $form = @$input.closest('form')
        $submit = $form.find('input[type=submit]')

        @$input.addClass 'uploading'
        $form.addClass  'uploading'

        @$input.prop 'disabled', true

        if @config.disableWith
          $submit.prop 'disabled', true
          $submit.data 'old-val', $submit.val()
          $submit.val  @config.disableWith

      @$input.bind 'fileuploadalways', (event) =>
        $form = @$input.closest('form')
        $submit = $form.find('input[type=submit]')

        @$input.removeClass 'uploading'
        $form.removeClass  'uploading'

        @$input.prop 'disabled', false

        if @config.disableWith
          $submit.prop 'disabled', false
          $submit.val  $submit.data('old-val')


    issueCallback: (data) ->
      $.ajax
        url: @options.callback,
        data: data,
        success: (file) => @addFile(file)

    addFile: (file) ->
      extension = file.path.split(".")[1]
      if !@options.accept || $.inArray(extension, @options.accept) != -1
        @files.push file
        @redraw()
        @checkMaximum()
      else
        alert @config.invalidFormatMessage

    removeFile: (fileIdToRemove) ->
      @files = (file for file in @files when file.id.toString() != fileIdToRemove.toString())
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
      @$filesContainer.append @makeHiddenField(null)

      if @files.length > 0
        for file in @files
          @$filesContainer.append @makeHiddenField(file.id)

        @$filesContainer.append @config.render(@files)
        @$filesContainer.find('[data-remove]').on 'click', (event) =>
          @removeFile $(event.target).data('remove')
        @$filesContainer.show()
      else
        @$filesContainer.hide()

    makeHiddenField: (value) ->
      $input = $('<input type="hidden">')

      name = @options.field_name
      name+= "[]" unless @options.single

      $input.attr 'name', name
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
