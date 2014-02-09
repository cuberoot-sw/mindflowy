class Mind
  # add new records at the appropriate level when a button is clicked
  # alt/option key is down
  displayTitleMessage = (id, title, parentId) ->
    $parent = (if parentId then findParent(parentId) else $("#records"))
    $el = makeListItem(title, id)
    console.log "displaying id:", id, " parentId:", parentId, title

    # add a data-parent attribute, which we use to locate parent elements
    $el.appendTo($parent).attr("data-id", id).attr("data-parent-id", parentId)

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
    $node = $(this).closest("[data-id]")
    nodeId = $node.attr("data-id") or null
    parentId = $node.attr("data-parent-id") or null
    FB.push
      title: null
      parent: parentId


  jQuery("body").on 'blur', 'span.editable', (e) ->
    e.preventDefault()
    $this = $(this)
    htmlold = $this.parent("li").find('.origText').val()
    htmlnew = $this.html()

    if htmlold isnt htmlnew
      console.log htmlold, htmlnew
      if htmlold is null or htmlold is ""
        $this.trigger "change", ["newNode"]
      else if htmlnew is null or htmlnew is ""
        $this.trigger "delete", ["emptyNode"]
      else
        $this.trigger "change", ["editedNode"]

      htmlold = htmlnew



  jQuery("body").on "click", "a.delete", ->
    $rec = $(this).closest("[data-id]")
    id = $rec.attr("data-id") or null
    if id
      $rec.find("[data-id]").each ->
        FB.remove($(this).attr("data-id"))
        return

      FB.remove(id)
    false

  jQuery("body").on "change", ".editable", (event, type) ->
    title = $(this).html()
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
    $el.next(".origText").val(title)
    #$el.find("span.editable").wysiwygEvt()
    $el.prepend("<span class='nodeId'>#"+id+"</span>")
    $el.append("<input type='hidden' class='origText' value='"+title+"'/>")
    $el

