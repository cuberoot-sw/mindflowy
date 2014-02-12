require.config({
    //baseUrl: '/scripts',
    paths: {
        // the left side is the module ID,
        // the right side is the path to
        // the jQuery file, relative to baseUrl.
        // Also, the path should NOT include
        // the '.js' file extension. This example
        // is using jQuery 1.9.0 located at
        // js/lib/jquery-1.9.0.js, relative to
        // the HTML page.
        fb: 'fb',
        main: 'main',
    }
});

//console.log("")

require(["delme"], function(Delme){
  console.log("inside require Delme")
})
require(["fb-auth"], function(){
  console.log("inside require fb-auth")
})
