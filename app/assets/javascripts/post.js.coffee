#########################
# Init section
#########################
ready = ->
  $("#editor").wysiwyg(hotKeys:
    "ctrl+b meta+b": "bold"
    "ctrl+i meta+i": "italic"
    "ctrl+u meta+u": "underline"
    "ctrl+z meta+z": "undo"
    "ctrl+y meta+y meta+shift+z": "redo"
  ).on "blur", ->
    $("#post_content").val($("#editor").html())

  $("#editor").html($("#post_content").val())
  $(".btn-toolbar a").tooltip()

$(document).ready(ready)
$(document).on('page:load', ready)


#########################
# Help functions
#########################

#########################
# Click event
#########################

