$ ->
  raw_name = $("#raw_name")
  name = $("#name")
  raw_name.keyup ()->
    if raw_name.val() == ""
      name.val("")
      return 
    raw_name_text = raw_name.val().replace(/\//g, '');
    $.get "../../api/kebab-case/#{raw_name_text}", (data)->
      name.val(data)
      #TODO: Handle error
      