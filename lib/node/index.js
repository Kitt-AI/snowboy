'use strict';

const stream = require('stream');
const binary = require('node-pre-gyp');
const path = require('path')
const addon = require(binary.find(path.resolve(path.join(__dirname,'../../package.json'))));


class HotwordModel {
  constructor(options){
    this.file = options.file;
    this.sensitivity = options.sensitivity || "0.5";
    this.hotword = options.hotword;
  }

  get model(){
    return this;
  }
}

class HotwordModels {
  constructor() {
    this._models = [];
  }

  models() {
    return this._models;
  }

  filenames() {
    return this._models.map(model => model.file);
  }

  sensitivities() {
    return this._models.map(model => model.sensitivity);
  }

  hotwordFromIndex(index){
    return this._models[index - 1].hotword;
  }

  add(model) {
    if(this._checkHotwordExists(model.hotword)){
      throw {error: "hotword must be unique"};
    }
    this._models.push(new HotwordModel(model));
  }

  _checkHotwordExists(hotword) {
    return this._models.some(model => model.hotword === hotword);
  }
  
}

class SnowboyDetect extends stream.Writable {
  constructor (options) {
    super();

    this._options = options;

    this.nativeInstance = new addon.SnowboyDetect(options.resource, options.models.filenames().join());
    this.nativeInstance.SetSensitivity(options.models.sensitivities().join())

    if (options.audioGain !== null && options.audioGain !== undefined) {
      this.nativeInstance.SetAudioGain(options.audioGain);
    }
  }

  reset () {
    return this.nativeInstance.Reset();
  }

  runDetection (buffer) {
    const index = this.nativeInstance.RunDetection(buffer);
    this._processResult(index);
    return index;
  }

  setSensitivity (sensitivity) {
    this.nativeInstance.SetSensitivity(sensitivity);
  }

  getSensitivity () {
    return this.nativeInstance.GetSensitivity();
  }

  setAudioGain (gain) {
    this.nativeInstance.setAudioGain(gain);
  }

  updateModel () {
    this.nativeInstance.UpdateModel();
  }

  numHotwords () {
    return this.nativeInstance.NumHotwords();
  }

  sampleRate () {
    return this.nativeInstance.SampleRate();
  }

  numChannels () {
    return this.nativeInstance.NumChannels();
  }

  bitsPerSample () {
    return this.nativeInstance.BitsPerSample();
  }

  // Stream implementation
  _write (chunk, encoding, callback) {
    const index = this.nativeInstance.RunDetection(chunk);
    this._processResult(index);
    return callback();
  }

  _processResult (index) {
    switch (index) {
      case -2:
        this.emit('silence');
        break;

      case -1:
        this.emit('error');
        break;

      case 0:
        this.emit('noise');
        break;

      default:
        this.emit('hotword', this._options.models.hotwordFromIndex(index))
        break;
    }
  }
}

const Snowboy = {
  Detector : SnowboyDetect,
  Models   : HotwordModels
}

module.exports = Snowboy;
