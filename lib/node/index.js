const stream = require('stream');
const binary = require('node-pre-gyp');
const path = require('path')
const addon = require(binary.find(path.resolve(path.join(__dirname,'../../package.json'))));

class SnowboyDetect extends stream.Writable {
  constructor (options) {
    super();

    this.nativeInstance = new addon.SnowboyDetect(options.resource, options.model);

    if (options.sensitivity !== null && options.sensitivity !== undefined) {
      this.nativeInstance.SetSensitivity(options.sensitivity);
    }

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
        this.emit('hotword', index)
        break;
    }
  }
}

module.exports = SnowboyDetect;
