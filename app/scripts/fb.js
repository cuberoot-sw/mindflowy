this.FB = (function() {
  var rootRef;

  function FB(name) {
    this.name = name;
  }

  rootRef = new Firebase("https://mindblowwy.firebaseio.com/nodes");

  FB.remove = function(id) {
    return rootRef.child(id).remove();
  };

  FB.update = function(id, hash) {
    return rootRef.child(id).update(hash);
  };

  FB.push = function(hash) {
    return rootRef.push(hash);
  };

  FB.child_added = function(cb) {
    return rootRef.on("child_added", function(snapshot) {
      var message;
      message = snapshot.val();
      return cb(snapshot.name(), snapshot.val());
    });
  };

  FB.child_removed = function(cb) {
    return rootRef.on("child_removed", function(snapshot) {
      return cb(snapshot.name(), snapshot.val());
    });
  };

  FB.child_changed = function(cb) {
    return rootRef.on("child_changed", function(snapshot) {
      return cb(snapshot.name(), snapshot.val());
    });
  };

  return FB;

})();

jQuery("body").on("hover", ".editable", (function() {
  return $(this).next("a").show();
}), function() {
  return $(this).next("a").hide();
});
