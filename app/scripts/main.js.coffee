define ->
  class Mind
    @NEW_NODE_ADDED: false
    @NEW_NODE_PREV: null

    constructor :(fb) ->
      console.log "in Mind constructor", fb
      firebase = fb

      firebase.once (v) ->
        console.log "in once", v.val()
        if v.val() == null
          $("#records").unbind()
          firebase.push
            title: " "
            parent: null

        $(".item:first").next().find(".editable:first").focus()

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
          $child.find(".editable:first").text(data.title)
        else
          console.log "appending child"
          #change_child id, data
      this.handleUIEvents(firebase)

    handleUIEvents: (firebase)->
      jQuery("body").on 'keydown.return', '.editable', (e) ->
        e.preventDefault()
        e.stopPropagation()
        console.log 'keydown.return', e.which
        $node = $(this).closest("[data-id]")
        nodeId = $node.attr("data-id") or null
        parentId = $node.attr("data-parent-id") or null
        if parentId is null
          title = " "
        else
          title = null
        Mind.NEW_NODE_ADDED = true
        Mind.NEW_NODE_PREV = $node
        firebase.push
          title: title
          parent: parentId
        e.preventDefault()

      jQuery("body").on 'keydown.tab', '.editable', (e) ->
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
          $(this).parent().find(".editable:first").focus()

      jQuery("body").on 'keydown.Shift_tab', '.editable', (e) ->
        console.log 'keydown.Shift_tab', e.which
        e.preventDefault()
        e.stopPropagation()
        $parents = $(this).parentsUntil("#records", "li")

        return if $parents.length <= 1
        if $parents.length == 2
          newParentId = null
          $("#records").append($(this).parent())
          $(this).parent().find(".editable:first").focus()
        else
          newParentId = $($parents[2]).attr("data-id")
          $newParent = $($parents[2]).children("ul").append($(this).parent())
          $(this).parent().find(".editable:first").focus()

        nodeId = $(this).parent().attr("data-id")
        title = $(this).html()
        firebase.update nodeId,
          title: title
          parent: newParentId

      jQuery("body").on 'keydown.up', '.editable', (e) ->
        e.stopPropagation()
        e.preventDefault()
        getPrevEd($(this)).focus()

      jQuery("body").on 'keydown.down', '.editable', (e) ->
        e.stopPropagation()
        e.preventDefault()
        getNextEd($(this)).focus()

      jQuery("body").on 'blur', '.editable', (e) ->
        e.preventDefault()
        e.stopPropagation()
        $this = $(this)
        htmlold = $this.parent("li").find('.origText').text()
        #htmlold = $('<div/>').text(htmlold).html()
        htmlnew = $this.text()

        console.log "blur", htmlold, htmlnew

        if htmlold isnt htmlnew
          $this.parent("li").find('.origText:first').text(htmlnew)
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
        title = $(this).text()
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

    getItem = ($ed) ->
      $($ed).parents("li.item").first()

    getPrevEd = ($ed) ->
      next = getItemIndex($ed, "prev")
      getEd $(".item[data-id='#{next}']")

    getSubItems = ($item) ->
      $item.find(".item")

    getParentItem = ($ed) ->
      getItem($ed).parents(".item").first()

    getNextEd = ($ed) ->
      next = getItemIndex($ed, "next")
      getEd $(".item[data-id='#{next}']")

    getItemIndex = ($ed, type) ->
      $item = getItem($ed)
      all = $(".item").map ->
        $(this).attr("data-id")

      ix = $.inArray($item.attr("data-id"), all)

      if type == "next"
        if ix == all.length - 1
          ix = -1
        all[ix+1]
      else
        if ix == 0
          ix = all.length
        all[ix-1]

    getEd = ($item) ->
      $item.find(".editable").first()

    getDataId = ($item) ->
      return $($item).attr('data-id') if $($item).attr('data-id')
      getItem($item).attr('data-id')

    # add new records at the appropriate level when a button is clicked
    # alt/option key is down
    displayTitleMessage = (id, title, parentId) ->
      $parent = (if parentId then findParent(parentId) else $("#records"))
      $el = makeListItem(title, id)
      console.log "displaying id:", id, " parentId:", parentId, title

      # add a data-parent attribute, which we use to locate parent elements
      if Mind.NEW_NODE_ADDED
        $el.insertAfter(Mind.NEW_NODE_PREV).attr("data-id", id).attr("data-parent-id", parentId)
        $el.find(".editable:first").focus()
        Mind.NEW_NODE_ADDED = false
        Mind.NEW_NODE_PREV = null
      else
        $el.appendTo($parent).attr("data-id", id).attr("data-parent-id", parentId)

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
      $el = $("#recordTemplate").clone().attr("id", null).find(".editable").text(title).end()
      $el.prepend("<div class='origText'>#{title}</div>")

    Mind

$("#records").on "mouseover", "li", (e) ->
  e.stopPropagation()
  $(this).find("a:first").show()
$("#records").on "mouseout", "li", (e) ->
  $(this).find("a:first").hide()
$("a#try_it").on "click", (e) ->
  e.preventDefault()
  $(".home-index-div").hide()
  $(".mind-flowy-div").show()
  $(".item:first").next().find(".editable:first").focus()
