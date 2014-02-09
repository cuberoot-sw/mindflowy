class Mind
  # add new records at the appropriate level when a button is clicked
  # alt/option key is down
  displayTitleMessage = (id, title, parentId) ->
    $parent = (if parentId then findParent(parentId) else $("#records"))
    $el = makeListItem(title, id)
    console.log "displaying id:", id, " parentId:", parentId, title

    # add a data-parent attribute, which we use to locate parent elements
    $el.appendTo($parent).attr("data-id", id).attr("data-parent-id", parentId)
    $el.on "down", (event, key) ->
      console.log "on-down", "---", key.which
      $el.find("span.editable").next().addClass("red")
    $el.on "up", (event, key) ->
      console.log "on-up", "---", key.which
    $el.on "tab", (event, key) ->
      console.log "on-tab", "---", key.which
    $el.on "shiftTab", (event, key) ->
      console.log "on-shiftTab", "---", key.which
    $el.on "delete", (event, type) ->
      console.log "on-delete", "---", type
    #$el.on "change", (event, type) ->
      # not needed, down should trigger blur and it should "update" record

  jQuery("body").on 'keydown.tab', 'span.editable', (e) ->
    console.log 'keydown.tab', e.which
    e.preventDefault()

  jQuery("body").on 'keydown.Shift_tab', 'span.editable', (e) ->
    console.log 'keydown.Shift_tab', e.which
    e.preventDefault()

  jQuery("body").on 'keydown.up', 'span.editable', (e) ->
    console.log 'keydown.up', e.which, $(this).html()
    e.preventDefault()

  jQuery("body").on 'keydown.down', 'span.editable', (e) ->
    console.log 'keydown.down', e.which, $(this).html()
    e.preventDefault()

  jQuery("body").on 'keydown.return', 'span.editable', (e) ->
    console.log 'keydown.return', e.which
    e.preventDefault()

  jQuery("body").on 'blur', 'span.editable', (e) ->
    console.log 'blur', e.which, $(this).html()
    e.preventDefault()


  jQuery("body").on "click", "a.delete", ->
    $rec = $(this).closest("[data-id]")
    id = $rec.attr("data-id") or null
    if id
      $rec.find("[data-id]").each ->
        FB.remove($(this).attr("data-id"))
        return

      FB.remove(id)
    false

  jQuery("body").on "blur", ".editable", () ->
    #console.log "blur "
    #title = $(this).html()
    #parent = $(this).closest("[data-id]").attr("data-id") or null
    #console.log "blur creating", parent, title
    #if title
      #FB.push
        #title: title
        #parent: parent

  jQuery("body").on "change", ".editable", (event, type) ->
    title = $(this).find("span.editable").html()
    $node = $(this).closest("[data-id]")
    nodeId = $node.attr("data-id") or null
    parentId = $node.attr("data-parent-id") or null
    console.log "in change", type, "nodeId: ", nodeId, " parentId: ", parentId, title
    switch type
      when "newNode"
        FB.push
          title: title
          parent: parentId
      when "editedNode"
        FB.update nodeId,
          title: title
          parent: parentId

  #jQuery("body").on "keypress", ".editable", '$', (event) ->
    #console.log "aaaa: ", e.which

  FB.child_added (id, data)->
    console.log "child_added", id
    displayTitleMessage id, data.title, data.parent
    #jQuery(".editable").wysiwygEvt()
    #jQuery(".editable").addClass("blue")
    return

  FB.child_removed (id, data) ->
    console.log "child_removed", id, "----", data.title
    $("#records").find("[data-id=\"" + id + "\"]").remove()


  # Helpers
  findParent = (parentId) ->
    $("#records").find "[data-id=\"" + parentId + "\"] > ul"

  makeListItem = (title, id, parentId) ->
    # remove the id attr
    # enter the <span> tag and use .text() to escape title
    # navigate back to the cloned element and return it
    $el = $("#recordTemplate").clone().attr("id", null).find("span.editable").text(title).end()
    #$el.find("span.editable").wysiwygEvt()
    $el.prepend("<span class='nodeId'>#"+id+"</span>")
    $el

