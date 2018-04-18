var express = require('express'),
    router = express.Router();
var request = require('request');

// http://stackoverflow.com/questions/16866015/node-js-wait-for-callback-of-rest-service-that-makes-http-request
router.get('/get_rand', function(req, res) {
  setTimeout(function(){
    res.json({
      result: parseInt(Math.random()*100)
    });
  }, 500);
});

module.exports = router;