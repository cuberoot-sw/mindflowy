chatRef = new Firebase("https://mindblowwy.firebaseio.com")

auth = new FirebaseSimpleLogin(chatRef, (error, user) ->
  if error
    # an error occurred while attempting login
    console.log error
  else if user
    # user authenticated with Firebase
    console.log "User ID: " + user.id + ", Provider: " + user.provider
    $("#forSignup").hide()
    $("#forEmail").hide()
  else
    # user is logged out
    $("#forSignup").show()
    $("#forEmail").show()

  return
)

$("body").on "click", "#signup", (e) ->
  email = $('#email').val()
  password = $('#password').val()
  auth.createUser email, password, (error, user) ->
  $('#mySignup').modal('hide')
  e.preventDefault()
  return false

$("body").on "click", "#login", (e) ->
  email = $('#email').val()
  password = $('#password').val()
  auth.login email, password, ->
  $('#myLogin').modal('hide')
  e.preventDefault()
  return false
