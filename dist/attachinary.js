(function() {

  (function($) {
    $.attachinary = {
      index: 0,
      config: {
        disableWith: 'Uploading...',
        indicateProgress: true,
        invalidFormatMessage: 'Invalid file format',
        template: "<ul>\n  <% for(var i=0; i<files.length; i++){ %>\n    <li>\n      <img\n        src=\"<%= $.cloudinary.url(files[i].public_id, { \"version\": files[i].version, \"format\": 'jpg', \"crop\": 'fill', \"width\": 75, \"height\": 75 }) %>\"\n        alt=\"\" width=\"75\" height=\"75\" />\n      <a href=\"#\" data-remove=\"<%= files[i].public_id %>\">Remove</a>\n    </li>\n  <% } %>\n</ul>",
        render: function(files) {
          return $.attachinary.Templating.template(this.template, {
            files: files
          });
        }
      }
    };
    $.fn.attachinary = function(options) {
      var settings;
      settings = $.extend({}, $.attachinary.config, options);
      return this.each(function() {
        var $this;
        $this = $(this);
        if (!$this.data('attachinary-bond')) {
          return $this.data('attachinary-bond', new $.attachinary.Attachinary($this, settings));
        }
      });
    };
    $.attachinary.Attachinary = (function() {

      function Attachinary($input, config) {
        this.$input = $input;
        this.config = config;
        this.options = this.$input.data('attachinary');
        this.files = this.options.files;
        this.$form = this.$input.closest('form');
        this.$submit = this.$form.find('input[type=submit]');
        this.initFileUpload();
        this.addFilesContainer();
        this.bindEventHandlers();
        this.redraw();
        this.checkMaximum();
      }

      Attachinary.prototype.initFileUpload = function() {
        var options;
        this.options.field_name = this.$input.attr('name');
        options = {
          dataType: 'json',
          paramName: 'file',
          headers: {
            "X-Requested-With": "XMLHttpRequest"
          },
          dropZone: this.config.dropZone || this.$input,
          sequentialUploads: true
        };
        if (this.$input.attr('accept')) {
          options.acceptFileTypes = new RegExp("^" + (this.$input.attr('accept').split(",").join("|")) + "$", "i");
        }
        return this.$input.fileupload(options);
      };

      Attachinary.prototype.bindEventHandlers = function() {
        var _this = this;
        this.$input.bind('fileuploadsend', function(event, data) {
          _this.$input.addClass('uploading');
          _this.$form.addClass('uploading');
          _this.$input.prop('disabled', true);
          if (_this.config.disableWith) {
            _this.$submit.each(function(index, input) {
              var $input;
              $input = $(input);
              return $input.data('old-val', $input.val());
            });
            _this.$submit.val(_this.config.disableWith);
            _this.$submit.prop('disabled', true);
          }
          return !_this.maximumReached();
        });
        this.$input.bind('fileuploaddone', function(event, data) {
          return _this.addFile(data.result);
        });
        this.$input.bind('fileuploadstart', function(event) {
          return _this.$input = $(event.target);
        });
        this.$input.bind('fileuploadalways', function(event) {
          _this.$input.removeClass('uploading');
          _this.$form.removeClass('uploading');
          _this.checkMaximum();
          if (_this.config.disableWith) {
            _this.$submit.each(function(index, input) {
              var $input;
              $input = $(input);
              return $input.val($input.data('old-val'));
            });
            return _this.$submit.prop('disabled', false);
          }
        });
        return this.$input.bind('fileuploadprogressall', function(e, data) {
          var progress;
          progress = parseInt(data.loaded / data.total * 100, 10);
          if (_this.config.disableWith && _this.config.indicateProgress) {
            return _this.$submit.val("[" + progress + "%] " + _this.config.disableWith);
          }
        });
      };

      Attachinary.prototype.addFile = function(file) {
        if (!this.options.accept || $.inArray(file.format, this.options.accept) !== -1) {
          this.files.push(file);
          this.redraw();
          return this.checkMaximum();
        } else {
          return alert(this.config.invalidFormatMessage);
        }
      };

      Attachinary.prototype.removeFile = function(fileIdToRemove) {
        var file;
        this.files = (function() {
          var _i, _len, _ref, _results;
          _ref = this.files;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            file = _ref[_i];
            if (file.public_id !== fileIdToRemove) {
              _results.push(file);
            }
          }
          return _results;
        }).call(this);
        this.redraw();
        return this.checkMaximum();
      };

      Attachinary.prototype.checkMaximum = function() {
        if (this.maximumReached()) {
          return this.$input.prop('disabled', true);
        } else {
          return this.$input.prop('disabled', false);
        }
      };

      Attachinary.prototype.maximumReached = function() {
        return this.options.maximum && this.files.length >= this.options.maximum;
      };

      Attachinary.prototype.addFilesContainer = function() {
        this.$filesContainer = $('<div class="attachinary_container">');
        return this.$input.after(this.$filesContainer);
      };

      Attachinary.prototype.redraw = function() {
        var _this = this;
        this.$filesContainer.empty();
        if (this.files.length > 0) {
          this.$filesContainer.append(this.makeHiddenField(JSON.stringify(this.files)));
          this.$filesContainer.append(this.config.render(this.files));
          this.$filesContainer.find('[data-remove]').on('click', function(event) {
            event.preventDefault();
            _this.removeFile($(event.target).data('remove'));
            return _this.$input.trigger("fileremoved");
          });
          return this.$filesContainer.show();
        } else {
          this.$filesContainer.append(this.makeHiddenField(null));
          return this.$filesContainer.hide();
        }
      };

      Attachinary.prototype.makeHiddenField = function(value) {
        var $input;
        $input = $('<input type="hidden">');
        $input.attr('name', this.options.field_name);
        $input.val(value);
        return $input;
      };

      return Attachinary;

    })();
    return $.attachinary.Templating = {
      settings: {
        start: '<%',
        end: '%>',
        interpolate: /<%=(.+?)%>/g
      },
      escapeRegExp: function(string) {
        return string.replace(/([.*+?^${}()|[\]\/\\])/g, '\\$1');
      },
      template: function(str, data) {
        var c, endMatch, fn;
        c = this.settings;
        endMatch = new RegExp("'(?=[^" + c.end.substr(0, 1) + "]*" + this.escapeRegExp(c.end) + ")", "g");
        fn = new Function('obj', 'var p=[],print=function(){p.push.apply(p,arguments);};' + 'with(obj||{}){p.push(\'' + str.replace(/\r/g, '\\r').replace(/\n/g, '\\n').replace(/\t/g, '\\t').replace(endMatch, "✄").split("'").join("\\'").split("✄").join("'").replace(c.interpolate, "',$1,'").split(c.start).join("');").split(c.end).join("p.push('") + "');}return p.join('');");
        if (data) {
          return fn(data);
        } else {
          return fn;
        }
      }
    };
  })(jQuery);

}).call(this);
