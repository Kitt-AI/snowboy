const fs = require('fs');
const wav = require('wav');
const Detector = require('../../').Detector;
const Models = require('../../').Models;

const models = new Models();

models.add({
  file: 'resources/snowboy.umdl',
  sensitivity: '0.5',
  hotwords : 'snowboy'
});

const detector = new Detector({
  resource: "resources/common.res",
  models: models,
  audioGain: 1.0
});

detector.on('silence', function () {
  console.log('silence');
});

detector.on('sound', function (buffer) { // Buffer arguments contains sound that triggered the event, for example, it could be written to a wav stream 
  console.log('sound');
});

detector.on('error', function () {
  console.log('error');
});

detector.on('hotword', function (index, hotword, buffer) { // Buffer arguments contains sound that triggered the event, for example, it could be written to a wav stream 
  console.log('hotword', index, hotword);
});

const file = fs.createReadStream('resources/snowboy.wav');
const reader = new wav.Reader();

file.pipe(reader).pipe(detector);
