var auth, chatRef;

chatRef = new Firebase("https://mindblowwy.firebaseio.com");

auth = new FirebaseSimpleLogin(chatRef, function(error, user) {
  if (error) {
    console.log(error);
  } else if (user) {
    console.log("User ID: " + user.id + ", Provider: " + user.provider);
    $("#forSignup").hide();
    $("#forEmail").hide();
  } else {
    $("#forSignup").show();
    $("#forEmail").show();
  }
});

$("body").on("click", "#signup", function(e) {
  var email, password;
  email = $('#email').val();
  password = $('#password').val();
  auth.createUser(email, password, function(error, user) {});
  $('#mySignup').modal('hide');
  e.preventDefault();
  return false;
});

$("body").on("click", "#login", function(e) {
  var email, password;
  email = $('#email').val();
  password = $('#password').val();
  auth.login(email, password, function() {});
  $('#myLogin').modal('hide');
  e.preventDefault();
  return false;
});
