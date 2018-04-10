const fs = require('fs');
const wav = require('wav');
const Detector = require('../../').Detector;
const Models = require('../../').Models;

const models = new Models();

models.add({
  file: 'resources/models/snowboy.umdl',
  sensitivity: '0.5',
  hotwords : 'snowboy'
});

const detector = new Detector({
  resource: "resources/common.res",
  models: models,
  audioGain: 1.0,
  applyFrontend: false
});

detector.on('silence', function () {
  console.log('silence');
});

detector.on('sound', function (buffer) {
  // <buffer> contains the last chunk of the audio that triggers the "sound"
  // event. It could be written to a wav stream.
  console.log('sound');
});

detector.on('error', function () {
  console.log('error');
});

detector.on('hotword', function (index, hotword, buffer) {
  // <buffer> contains the last chunk of the audio that triggers the "hotword"
  // event. It could be written to a wav stream. You will have to use it
  // together with the <buffer> in the "sound" event if you want to get audio
  // data after the hotword.
  console.log('hotword', index, hotword);
});

const file = fs.createReadStream('resources/snowboy.wav');
const reader = new wav.Reader();

file.pipe(reader).pipe(detector);
