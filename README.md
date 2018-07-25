# waila

An AI powered Flutter app

Using their camera or images from their gallery, users can upload an image, have it classified based on content of the image, and generate #hashtags based on the classifications relavant to trending #hashtags online. Available for download on the PlayStore here https://play.google.com/store/apps/details?id=com.waila.akdsgn

## Built using Googles GCP and Flutter
GCP - https://cloud.google.com/
Flutter - https://flutter.io/

## Image classification is done on a nodejs backend I built - https://github.com/AshKetchumza/image-classifier-server
If you want to just use the endpoint for classification you can make a POST call to https://waila.ml/api/vision/imageClassify
It has only one required parameter, which is the image you want classified, sent as a file object.

## Contributors

Ashley Sanders - https://github.com/AshKetchumza + https://twitter.com/AshMikeKetchum


