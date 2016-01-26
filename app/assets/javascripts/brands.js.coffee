# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
  click_flag = true
  $("#picture-input-0").change (event) ->
    preview_id = $('#upload-preview-0')
    handlePreviewImage(event, preview_id)
  $("#picture-input-1").change (event) ->
    preview_id = $('#upload-preview-1')
    handlePreviewImage(event, preview_id)

  $("#upload-button-0").click ->
    $("#picture-input-0").trigger "click"

  $("#upload-button-1").click ->
    $("#picture-input-1").trigger "click"

handlePreviewImage = (event, preview_id)->
  input = $(event.currentTarget)
  file = input[0].files[0]
  reader = new FileReader()
  reader.onload = ((file) ->
    (e) ->
      image_base64 = e.target.result
      $("#span-"+ preview_id.attr('id')).find('span').addClass('remove_img_preview')
      preview_id.attr 'src', e.target.result
  )(file)
  reader.readAsDataURL file


$("#list-image-0").on "click", ".remove_img_preview", ->
  control = $('#picture-input-0')
  control.after(control.clone( true )).remove()
  $('#upload-preview-0').attr("src", "/assets/ph.jpg")
  $(this).removeClass('remove_img_preview')
  return

$("#list-image-1").on "click", ".remove_img_preview", ->
  control = $('#picture-input-1')
  control.after(control.clone( true )).remove()
  control.attr 'require', true
  $('#upload-preview-1').attr("src", "/assets/ph.jpg")
  $(this).removeClass('remove_img_preview')
  return
$(".tracker").click ->
  type = ($(this).attr("data-tracker"))
  current = $('#'+type).text()
  $("#"+type).text(parseInt(current)+1)
