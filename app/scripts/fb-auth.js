var auth, chatRef;

chatRef = new Firebase("https://incandescent-fire-4492.firebaseio.com");

auth = new FirebaseSimpleLogin(chatRef, function(error, user) {
  console.log("FirebaseSimpleLogin");
  if (error) {
    console.log(error.message);
    alert(error.message);
  } else if (user) {
    console.log("User ID: " + user.id + ", Provider: " + user.provider);
    $("#account").html(user.email).show();
    $("#forSignup").hide();
    $("#forLogin").hide();
    $('#myLogin').modal('hide');
    $('#mySignup').modal('hide');
  } else {
    $("#account").hide();
    $("#forSignup").hide();
    $("#forSignup").show();
    $("#forLogin").show();
  }
});

$("body").on("click", "#signup", function(e) {
  var email, password;
  e.preventDefault();
  email = $('#semail').val();
  password = $('#spassword').val();
  auth.createUser(email, password, function(error, user) {
    if (user) {
      return console.log("User ID: " + user.id + ", Provider: " + user.provider);
    }
  });
  return false;
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

$("body").on("click", "#signout", function(e) {
  e.preventDefault();
  return auth.logout();
});
