var Mind;

Mind = (function() {
  var displayTitleMessage, findParent, makeListItem;

  function Mind() {}

  Mind.NEW_NODE_ADDED = false;

  displayTitleMessage = function(id, title, parentId) {
    var $el, $parent;
    $parent = (parentId ? findParent(parentId) : $("#records"));
    $el = makeListItem(title, id);
    console.log("displaying id:", id, " parentId:", parentId, title);
    $el.appendTo($parent).attr("data-id", id).attr("data-parent-id", parentId);
    if (Mind.NEW_NODE_ADDED) {
      $el.find("span.editable").focus();
      return Mind.NEW_NODE_ADDED = false;
    }
  };

  jQuery("body").on('keydown.tab', 'span.editable', function(e) {
    console.log('keydown.tab', e.which);
    return e.preventDefault();
  });

  jQuery("body").on('keydown.Shift_tab', 'span.editable', function(e) {
    console.log('keydown.Shift_tab', e.which);
    return e.preventDefault();
  });

  jQuery("body").on('keydown.up', 'span.editable', function(e) {
    e.stopPropagation();
    e.preventDefault();
    console.log('keydown.up', e.which, $(this).html());
    $(this).parent().prev().children(".editable").first().focus();
    console.log("focus on: ", $(this).parent().prev().children(".editable").first().html());
    return e.preventDefault();
  });

  jQuery("body").on('keydown.down', 'span.editable', function(e) {
    e.stopPropagation();
    e.preventDefault();
    console.log('keydown.down', e.which, $(this).html());
    $(this).parent().next().children(".editable").first().focus();
    return console.log("focus on: ", $(this).parent().next().children(".editable").first().html());
  });

  jQuery("body").on('keydown.return', 'span.editable', function(e) {
    var $node, nodeId, parentId, title;
    console.log('keydown.return', e.which);
    $node = $(this).closest("[data-id]");
    nodeId = $node.attr("data-id") || null;
    parentId = $node.attr("data-parent-id") || null;
    if (parentId === null) {
      title = " ";
    } else {
      title = null;
    }
    Mind.NEW_NODE_ADDED = true;
    FB.push({
      title: title,
      parent: parentId
    });
    return e.preventDefault();
  });

  jQuery("body").on('blur', 'span.editable', function(e) {
    var $this, htmlnew, htmlold;
    e.preventDefault();
    e.stopPropagation();
    $this = $(this);
    htmlold = $this.parent("li").find('.origText').val();
    htmlnew = $this.html();
    console.log("blur", htmlold, htmlnew);
    if (htmlold !== htmlnew) {
      $this.parent("li").find('.origText').val(htmlnew);
      if (htmlold === null || htmlold === "") {
        return $this.trigger("change", ["newNode"]);
      } else if (htmlnew === null || htmlnew === "") {
        return $this.trigger("delete", ["emptyNode"]);
      } else {
        return $this.trigger("change", ["editedNode"]);
      }
    }
  });

  jQuery("body").on("click", "a.delete", function() {
    var $rec, id;
    $rec = $(this).closest("[data-id]");
    id = $rec.attr("data-id") || null;
    if (id) {
      $rec.find("[data-id]").each(function() {
        FB.remove($(this).attr("data-id"));
      });
      FB.remove(id);
    }
    return false;
  });

  jQuery("body").on("change", ".editable", function(event, type) {
    var $node, nodeId, parentId, title;
    title = $(this).html();
    $node = $(this).closest("[data-id]");
    nodeId = $node.attr("data-id") || null;
    parentId = $node.attr("data-parent-id") || null;
    console.log("in change", type, "nodeId: ", nodeId, " parentId: ", parentId, title);
    switch (type) {
      case "editedNode":
        return FB.update(nodeId, {
          title: title,
          parent: parentId
        });
    }
  });

  FB.child_added(function(id, data) {
    console.log("child_added", id);
    displayTitleMessage(id, data.title, data.parent);
  });

  FB.child_removed(function(id, data) {
    console.log("child_removed", id, "----", data.title);
    return $("#records").find("[data-id=\"" + id + "\"]").remove();
  });

  findParent = function(parentId) {
    return $("#records").find("[data-id=\"" + parentId + "\"] > ul");
  };

  makeListItem = function(title, id, parentId) {
    var $el;
    $el = $("#recordTemplate").clone().attr("id", null).find("span.editable").text(title).end();
    $el.prepend("<span class='nodeId'>#" + id + "</span>");
    return $el.prepend("<input type='hidden' class='origText' value='" + title + "'/>");
  };

  return Mind;

})();
