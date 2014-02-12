define ->
  class Mind
    @NEW_NODE_ADDED: false

    constructor :(fb) ->
      console.log "in Mind constructor", fb
      firebase = fb
      firebase.child_added (id, data)->
        console.log "child_added", id
        displayTitleMessage id, data.title, data.parent
        #jQuery(".editable").wysiwygEvt()
        #jQuery(".editable").addClass("blue")
        return

      firebase.child_removed (id, data) ->
        console.log "child_removed", id, "----", data.title
        $("#records").find("[data-id=\"" + id + "\"]").remove()

      firebase.child_changed (id, data) ->
        console.log "child_changed", id, "----", data.title, data.parent
        $parent = $("[data-id='"+data.parent+"']")
        $child = $("[data-id='"+id+"']")
        if $parent.has("[data-id='"+id+"']").length > 0
          console.log "child exists"
          $child.find("span.editable").html(data.title)
        else
          console.log "appending child"
          #change_child id, data
      this.handleUIEvents(firebase)

    handleUIEvents: (firebase)->
      jQuery("body").on 'keydown.return', 'span.editable', (e) ->
        console.log 'keydown.return', e.which
        $node = $(this).closest("[data-id]")
        nodeId = $node.attr("data-id") or null
        parentId = $node.attr("data-parent-id") or null
        if parentId is null
          title = " "
        else
          title = null
        Mind.NEW_NODE_ADDED = true
        firebase.push
          title: title
          parent: parentId
        e.preventDefault()

      jQuery(document).on 'keydown.tab', 'span.editable', (e) ->
        e.preventDefault()
        e.stopPropagation()
        console.log 'keydown.tab', e.which
        $prev = $(this).parent().prev()
        if $prev.length == 0
          #no parent
          return
        else
          newParentId = $prev.attr("data-id")
          nodeId = $(this).parent().attr("data-id")
          title = $(this).html()
          firebase.update nodeId,
            title: title
            parent: newParentId
          $prev.children("ul").append($(this).parent())

      jQuery("body").on 'keydown.Shift_tab', 'span.editable', (e) ->
        console.log 'keydown.Shift_tab', e.which
        e.preventDefault()
        e.stopPropagation()
        $parents = $(this).parentsUntil("#records", "li")

        return if $parents.length <= 1
        if $parents.length == 2
          newParentId = null
          $("#records").append($(this).parent())
        else
          newParentId = $($parents[2]).attr("data-id")
          $newParent = $($parents[2]).children("ul").append($(this).parent())

        nodeId = $(this).parent().attr("data-id")
        title = $(this).html()
        firebase.update nodeId,
          title: title
          parent: newParentId

      jQuery("body").on 'keydown.up', 'span.editable', (e) ->
        e.stopPropagation()
        e.preventDefault()
        console.log 'keydown.up', e.which, $(this).html()
        $(this).parent().prev().children(".editable").first().focus()
        console.log("focus on: ",$(this).parent().prev().children(".editable").first().html())
        e.preventDefault()

      jQuery("body").on 'keydown.down', 'span.editable', (e) ->
        e.stopPropagation()
        e.preventDefault()
        console.log 'keydown.down', e.which, $(this).html()
        $(this).parent().next().children(".editable").first().focus()
        console.log("focus on: ",$(this).parent().next().children(".editable").first().html())

      jQuery("body").on 'blur', 'span.editable', (e) ->
        e.preventDefault()
        e.stopPropagation()
        $this = $(this)
        htmlold = $this.parent("li").find('.origText').val()
        htmlnew = $this.html()

        console.log "blur", htmlold, htmlnew

        if htmlold isnt htmlnew
          $this.parent("li").find('.origText').val(htmlnew)
          if htmlold is null or htmlold is ""
            $this.trigger "change", ["newNode"]
          else if htmlnew is null or htmlnew is ""
            $this.trigger "delete", ["emptyNode"]
          else
            $this.trigger "change", ["editedNode"]


      jQuery("body").on "click", "a.delete", ->
        $rec = $(this).closest("[data-id]")
        id = $rec.attr("data-id") or null
        if id
          $rec.find("[data-id]").each ->
            firebase.remove($(this).attr("data-id"))
            return

          firebase.remove(id)
        false

      jQuery("body").on "change", ".editable", (event, type) ->
        title = $(this).html()
        $node = $(this).closest("[data-id]")
        nodeId = $node.attr("data-id") or null
        parentId = $node.attr("data-parent-id") or null
        console.log "in change", type, "nodeId: ", nodeId, " parentId: ", parentId, title
        switch type
          #when "newNode"
            #Mind.NEW_NODE_ADDED = true
            #firebase.push
              #title: title
              #parent: parentId
          when "editedNode"
            firebase.update nodeId,
              title: title
              parent: parentId

      #jQuery("body").on "keypress", ".editable", '$', (event) ->
        #console.log "aaaa: ", e.which

    # add new records at the appropriate level when a button is clicked
    # alt/option key is down
    displayTitleMessage = (id, title, parentId) ->
      $parent = (if parentId then findParent(parentId) else $("#records"))
      $el = makeListItem(title, id)
      console.log "displaying id:", id, " parentId:", parentId, title

      # add a data-parent attribute, which we use to locate parent elements
      $el.appendTo($parent).attr("data-id", id).attr("data-parent-id", parentId)
      if Mind.NEW_NODE_ADDED
        $el.find("span.editable").focus()
        Mind.NEW_NODE_ADDED = false

    # Helpers
    findParent = (parentId) ->
      $("#records").find "[data-id=\"" + parentId + "\"] > ul"

    change_child = (id, data) ->
      if data.parent is null
        $("[data-id='"+id+"']").detach().appendTo("#records")
      else
        $("[data-id='"+id+"']").detach().appendTo("[data-id='"+data.parent+"']")

    makeListItem = (title, id, parentId) ->
      # remove the id attr
      # enter the <span> tag and use .text() to escape title
      # navigate back to the cloned element and return it
      $el = $("#recordTemplate").clone().attr("id", null).find("span.editable").text(title).end()
      #$el.find("span.editable").wysiwygEvt()
      #$el.prepend("<span class='nodeId'>#"+id+"</span>")
      $el.prepend("<input type='hidden' class='origText' value='"+title+"'/>")

    Mind
