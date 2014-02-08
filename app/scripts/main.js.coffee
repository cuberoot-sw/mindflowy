class Mind
  # add new records at the appropriate level when a button is clicked
  # alt/option key is down
  displayTitleMessage = (id, title, parentId) ->
    $parent = (if parentId then findParent(parentId) else $("#records"))
    $el = makeListItem(title)
    console.log "displaying", id, parentId, $parent, title

    # add a data-parent attribute, which we use to locate parent elements
    $el.appendTo($parent).attr "data-id", id
    return

  findParent = (parentId) ->
    $("#records").find "[data-id=\"" + parentId + "\"] > ul"

  makeListItem = (title) ->
    # remove the id attr
    # enter the <span> tag and use .text() to escape title
    # navigate back to the cloned element and return it
    $("#recordTemplate").clone().attr("id", null).find("span").text(title).end()

  jQuery("body").on "click", "a.delete", ->
    $rec = $(this).closest("[data-id]")
    id = $rec.attr("data-id") or null
    if id
      $rec.find("[data-id]").each ->
        FB.remove($(this).attr("data-id"))
        return

      FB.remove(id)
    false

  jQuery("body").on "click", "button", ->
    $input = $(this).prev("input")
    title = $input.val()
    parent = $input.closest("[data-id]").attr("data-id") or null
    console.log "creating", parent, title
    if title
      FB.push
        title: title
        parent: parent

    $input.val ""
    false

  jQuery("body").on "keydown", ".node", (key) ->
    if key.shiftKey
      console.log "shift " + key.which
      false
    else
      console.log key.which
    return

  FB.child_added (id, data)->
    console.log "child_added", id
    displayTitleMessage id, data.title, data.parent
    return

  FB.child_removed (id, data) ->
    console.log "child_removed", id, "----", data.title
    $("#records").find("[data-id=\"" + id + "\"]").remove()

