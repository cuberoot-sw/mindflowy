define(function() {
  var Mind;
  return Mind = (function() {
    var change_child, displayTitleMessage, findParent, getDataId, getEd, getItem, getItemIndex, getNextEd, getParentItem, getPrevEd, getSubItems, makeListItem;

    Mind.NEW_NODE_ADDED = false;

    Mind.NEW_NODE_PREV = null;

    function Mind(fb) {
      var firebase;
      console.log("in Mind constructor", fb);
      firebase = fb;
      firebase.once(function(v) {
        console.log("in once", v.val());
        if (v.val() === null) {
          $("#records").unbind();
          firebase.push({
            title: " ",
            parent: null
          });
        }
        return $(".item:first").next().find(".editable:first").focus();
      });
      firebase.child_added(function(id, data) {
        console.log("child_added", id);
        displayTitleMessage(id, data.title, data.parent);
      });
      firebase.child_removed(function(id, data) {
        console.log("child_removed", id, "----", data.title);
        return $("#records").find("[data-id=\"" + id + "\"]").remove();
      });
      firebase.child_changed(function(id, data) {
        var $child, $parent;
        console.log("child_changed", id, "----", data.title, data.parent);
        $parent = $("[data-id='" + data.parent + "']");
        $child = $("[data-id='" + id + "']");
        if ($parent.has("[data-id='" + id + "']").length > 0) {
          console.log("child exists");
          return $child.find(".editable:first").text(data.title);
        } else {
          return console.log("appending child");
        }
      });
      this.handleUIEvents(firebase);
    }

    Mind.prototype.handleUIEvents = function(firebase) {
      jQuery("body").on('keydown.return', '.editable', function(e) {
        var $node, nodeId, parentId, title;
        e.preventDefault();
        e.stopPropagation();
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
        Mind.NEW_NODE_PREV = $node;
        firebase.push({
          title: title,
          parent: parentId
        });
        return e.preventDefault();
      });
      jQuery("body").on('keydown.tab', '.editable', function(e) {
        var $prev, newParentId, nodeId, title;
        e.preventDefault();
        e.stopPropagation();
        console.log('keydown.tab', e.which);
        $prev = $(this).parent().prev();
        if ($prev.length === 0) {

        } else {
          newParentId = $prev.attr("data-id");
          nodeId = $(this).parent().attr("data-id");
          title = $(this).html();
          firebase.update(nodeId, {
            title: title,
            parent: newParentId
          });
          $prev.children("ul").append($(this).parent());
          return $(this).parent().find(".editable:first").focus();
        }
      });
      jQuery("body").on('keydown.Shift_tab', '.editable', function(e) {
        var $newParent, $parents, newParentId, nodeId, title;
        console.log('keydown.Shift_tab', e.which);
        e.preventDefault();
        e.stopPropagation();
        $parents = $(this).parentsUntil("#records", "li");
        if ($parents.length <= 1) {
          return;
        }
        if ($parents.length === 2) {
          newParentId = null;
          $("#records").append($(this).parent());
          $(this).parent().find(".editable:first").focus();
        } else {
          newParentId = $($parents[2]).attr("data-id");
          $newParent = $($parents[2]).children("ul").append($(this).parent());
          $(this).parent().find(".editable:first").focus();
        }
        nodeId = $(this).parent().attr("data-id");
        title = $(this).html();
        return firebase.update(nodeId, {
          title: title,
          parent: newParentId
        });
      });
      jQuery("body").on('keydown.up', '.editable', function(e) {
        e.stopPropagation();
        e.preventDefault();
        return getPrevEd($(this)).focus();
      });
      jQuery("body").on('keydown.down', '.editable', function(e) {
        e.stopPropagation();
        e.preventDefault();
        return getNextEd($(this)).focus();
      });
      jQuery("body").on('blur', '.editable', function(e) {
        var $this, htmlnew, htmlold;
        e.preventDefault();
        e.stopPropagation();
        $this = $(this);
        htmlold = $this.parent("li").find('.origText').text();
        htmlnew = $this.text();
        console.log("blur", htmlold, htmlnew);
        if (htmlold !== htmlnew) {
          $this.parent("li").find('.origText:first').text(htmlnew);
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
            firebase.remove($(this).attr("data-id"));
          });
          firebase.remove(id);
        }
        return false;
      });
      return jQuery("body").on("change", ".editable", function(event, type) {
        var $node, nodeId, parentId, title;
        title = $(this).text();
        $node = $(this).closest("[data-id]");
        nodeId = $node.attr("data-id") || null;
        parentId = $node.attr("data-parent-id") || null;
        console.log("in change", type, "nodeId: ", nodeId, " parentId: ", parentId, title);
        switch (type) {
          case "editedNode":
            return firebase.update(nodeId, {
              title: title,
              parent: parentId
            });
        }
      });
    };

    getItem = function($ed) {
      return $($ed).parents("li.item").first();
    };

    getPrevEd = function($ed) {
      var next;
      next = getItemIndex($ed, "prev");
      return getEd($(".item[data-id='" + next + "']"));
    };

    getSubItems = function($item) {
      return $item.find(".item");
    };

    getParentItem = function($ed) {
      return getItem($ed).parents(".item").first();
    };

    getNextEd = function($ed) {
      var next;
      next = getItemIndex($ed, "next");
      return getEd($(".item[data-id='" + next + "']"));
    };

    getItemIndex = function($ed, type) {
      var $item, all, ix;
      $item = getItem($ed);
      all = $(".item").map(function() {
        return $(this).attr("data-id");
      });
      ix = $.inArray($item.attr("data-id"), all);
      if (type === "next") {
        if (ix === all.length - 1) {
          ix = -1;
        }
        return all[ix + 1];
      } else {
        if (ix === 0) {
          ix = all.length;
        }
        return all[ix - 1];
      }
    };

    getEd = function($item) {
      return $item.find(".editable").first();
    };

    getDataId = function($item) {
      if ($($item).attr('data-id')) {
        return $($item).attr('data-id');
      }
      return getItem($item).attr('data-id');
    };

    displayTitleMessage = function(id, title, parentId) {
      var $el, $parent;
      $parent = (parentId ? findParent(parentId) : $("#records"));
      $el = makeListItem(title, id);
      console.log("displaying id:", id, " parentId:", parentId, title);
      if (Mind.NEW_NODE_ADDED) {
        $el.insertAfter(Mind.NEW_NODE_PREV).attr("data-id", id).attr("data-parent-id", parentId);
        $el.find(".editable:first").focus();
        Mind.NEW_NODE_ADDED = false;
        return Mind.NEW_NODE_PREV = null;
      } else {
        return $el.appendTo($parent).attr("data-id", id).attr("data-parent-id", parentId);
      }
    };

    findParent = function(parentId) {
      return $("#records").find("[data-id=\"" + parentId + "\"] > ul");
    };

    change_child = function(id, data) {
      if (data.parent === null) {
        return $("[data-id='" + id + "']").detach().appendTo("#records");
      } else {
        return $("[data-id='" + id + "']").detach().appendTo("[data-id='" + data.parent + "']");
      }
    };

    makeListItem = function(title, id, parentId) {
      var $el;
      $el = $("#recordTemplate").clone().attr("id", null).find(".editable").text(title).end();
      return $el.prepend("<div class='origText'>" + title + "</div>");
    };

    Mind;

    return Mind;

  })();
});

$("#records").on("mouseover", "li", function(e) {
  e.stopPropagation();
  return $(this).find("a:first").show();
});

$("#records").on("mouseout", "li", function(e) {
  return $(this).find("a:first").hide();
});

$("a#try_it").on("click", function(e) {
  e.preventDefault();
  $(".home-index-div").hide();
  $(".mind-flowy-div").show();
  return $(".item:first").next().find(".editable:first").focus();
});
