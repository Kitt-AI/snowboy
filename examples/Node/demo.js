const record = require('node-record-lpcm16');
const {Detector, Models} = require('../../');

const m = new Models();

m.add({
  file: 'resources/snowboy.umdl',
  sensitivity: '0.5',
  hotword : 'snowboy'
});

const d = new Detector({
  resource: "resources/common.res",
  models: m,
  audioGain: 2.0
});

d.on('silence', function () {
  console.log('silence');
});

d.on('noise', function () {
  console.log('noise');
});

d.on('error', function () {
  console.log('error');
});

d.on('hotword', function (index) {
  console.log('hotword', index);
});

const r = record.start({
  threshold: 0,
  verbose: true
});

r.pipe(d);
