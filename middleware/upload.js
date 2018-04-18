var express = require('express'),
    router = express.Router(),
    request = require('request'),
    fs = require('fs'),
    //knox = require('knox');
    // AWS = require('aws-sdk');
    s3 = require('s3');
var multipart = require('connect-multiparty');
var multipartMiddleware = multipart();

// var s3client = knox.createClient({
//     key: 'AKIAJDIBNZUCTQZFMZZA',
//     secret: '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',
//     bucket: 'cityknowledge'
// });

// AWS.config.update({
//   accessKeyId: 'JiLJ5Xc/xho5yrMKuUSmc1TstkIBibBmi6dyplOV',
//   secretAccessKey: 'AKIAJDIBNZUCTQZFMZZA'
// });
// var s3 = new AWS.S3();

var s3client = s3.createClient({
  // maxAsyncS3: 20,     // this is the default
  // s3RetryCount: 3,    // this is the default
  // s3RetryDelay: 1000, // this is the default
  // multipartUploadThreshold: 20971520, // this is the default (20 MB)
  // multipartUploadSize: 15728640, // this is the default (15 MB)
  s3Options: {
    accessKeyId: 'AKIAJZL5OYD7VTRN35FA',
    secretAccessKey: 'N08KwGmsXMyrOy6lKD7EQrXUG/xlQPZHWc24zXac',
    // region: "your region"
    // any other options are passed to new AWS.S3()
    // See: http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/Config.html#constructor-property
  },
});

router.post('/image', multipartMiddleware, function(req, res) {
  console.log("REQ", req.body, req.files);
  // res.setHeader('Content-Type', 'text/html');
  if (req.files.length == 0 || req.files.file.size == 0)
    res.json({ status: 'ko', msg: 'No file uploaded at ' + new Date().toString() });
  else {
    var file = req.files.file;
    var file_ext = file.name.split('.')[file.name.split('.').length - 1];
    console.log("file", file);
    
    console.log("UPLOAD TO:", 'ckdata/'+req.body.ckid+'.'+file_ext);
    
    var actual = new Date;
    
    var file_key = 'ckdata/' + req.body.ckid + '_';
    file_key += [
      actual.getYear(),
      actual.getMonth(),
      actual.getDay(),
      actual.getHours(),
      actual.getMinutes()
    ].join('.');
    file_key += file_ext;
    var params = {
      localFile: file.path,

      s3Params: {
        Bucket: 'cityknowledge',
        Key: file_key,
        ACL: 'public-read'
        // other options supported by putObject, except Body and ContentLength.
        // See: http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/S3.html#putObject-property
      },
    };
    var uploader = s3client.uploadFile(params);
    uploader.on('error', function(err) {
      res.json({ status: 'ko', msg: err.stack });
      console.error("unable to upload:", err.stack);
    });
    // uploader.on('progress', function() {
    //   console.log("progress", uploader.progressMd5Amount,
    //             uploader.progressAmount, uploader.progressTotal);
    // });
    uploader.on('end', function() {
      res.json({ status: 'ok', msg: 'ok', file: ("https://s3.amazonaws.com/cityknowledge/"+file_key) });
      console.log("done uploading");
    });
    
    // fs.readFile(file.path, function (err, data) {
    //   if (err) { return res.json({ status: 'ko', msg: err }); }
    // 
    //   //var base64data = new Buffer(data, 'binary');
    // 
    //   var s3 = new AWS.S3();
    //   s3.client.putObject({
    //     Bucket: 'cityknowledge',
    //     Key: ('ckdata/'+req.body.ckid+'.'+file_ext),
    //     //Body: base64data,
    //     Body: data,
    //     ACL: 'public-read'
    //   },function (resp) {
    //     // console.log(arguments);
    //     console.log('Successfully uploaded package.');
    //     res.json({ status: 'ok', msg: 'ok' });
    //   });
    // });
    
    // s3client.putFile(file.path,
    //   ('ckdata/'+req.body.ckid+'.'+file_ext),
    //   { 'x-amz-acl': 'public-read' },
    //   function(err, response){
    //     fs.unlink(file.path, function(){
    //       if (err)
    //         res.json({ status: 'ko', msg: err });
    //       else
    //         res.json({ status: 'ok', msg: 'ok' });
    //     });
    //   }
    // );
  }
});

module.exports = router;