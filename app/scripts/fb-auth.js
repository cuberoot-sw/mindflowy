define(['fb', 'main'], function(FB, Mind) {
  var $fb, auth, chatRef;
  chatRef = new Firebase("https://incandescent-fire-4492.firebaseio.com");
  $fb = null;
  auth = new FirebaseSimpleLogin(chatRef, function(error, user) {
    if ($fb !== null) {
      $fb.off();
      console.log("$fb.off");
    }
    $("#records li:not(:first)").remove();
    console.log("FirebaseSimpleLogin");
    if (error) {
      console.log(error.message);
      alert(error.message);
    } else if (user) {
      console.log("User ID: " + user.id + ", Provider: " + user.provider);
      $(".home-index-div").hide();
      $(".mind-flowy-div").show();
      $("#account").html("Welcome " + user.email).show();
      $("#forSignup").hide();
      $("#forLogin").hide();
      $("#signout").show();
      $('#myLogin').modal('hide');
      $('#mySignup').modal('hide');
      $fb = new FB("/users/" + user.id + "/");
      new Mind($fb);
    } else {
      $("#account").hide();
      $("#signout").hide();
      $("#forSignup").show();
      $("#forLogin").show();
      $fb = new FB("/public/");
      new Mind($fb);
    }
  });
  $("body").on("click", "#signup", function(e) {
    var email, password;
    e.preventDefault();
    email = $('#semail').val();
    password = $('#spassword').val();
    return auth.createUser(email, password, function(error, user) {
      if (!error) {
        auth.login('password', {
          email: email,
          password: password
        });
        return console.log("User ID: " + user.id + ", Provider: " + user.provider);
      } else {
        return console.log(error);
      }
    });
  });
  $("body").on("click", "#login", function(e) {
    var email, password;
    e.preventDefault();
    email = $('#lemail').val();
    password = $('#lpassword').val();
    return auth.login('password', {
      email: email,
      password: password
    });
  });
  return $("body").on("click", "#signout", function(e) {
    e.preventDefault();
    return auth.logout();
  });
});
