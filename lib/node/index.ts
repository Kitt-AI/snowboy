import * as stream from 'stream';
import * as path from 'path';
import * as fs from 'fs';
import * as binary from 'node-pre-gyp';

const bindingPath: string = binary.find(path.resolve(path.join(__dirname, '../../package.json')));
const SnowboyDetectNative: SnowboyDetectNativeInterface = require(bindingPath).SnowboyDetect;

enum DetectionResult {
  SILENCE = -2,
  ERROR = -1,
  SOUND = 0
}

enum ModelType {
  PMDL,
  UMDL
}

export interface HotwordModel {
  file: string;
  sensitivity?: string;
  hotwords: string | Array<string>;
}

interface HotwordModelsInterface {
  add(model: HotwordModel): void;
  lookup(index: number): string;
  numHotwords(): number;
}

export interface DetectorOptions {
  resource: string;
  models: HotwordModels;
  audioGain?: number;
  applyFrontend?: boolean;
  highSensitivity?: string;
}

export interface SnowboyDetectInterface {
  reset(): boolean;
  runDetection(buffer: Buffer): number;
  setSensitivity(sensitivity: string): void;
  setHighSensitivity(highSensitivity: string): void;
  getSensitivity(): string;
  setAudioGain(gain: number): void;
  updateModel(): void;
  numHotwords(): number;
  sampleRate(): number;
  numChannels(): number;
  bitsPerSample(): number;
}

export class HotwordModels implements HotwordModels {
  private models: Array<HotwordModel> = [];
  private lookupTable: Array<string>;

  add(model: HotwordModel) {
    model.hotwords = [].concat(model.hotwords);
    model.sensitivity = model.sensitivity || "0.5";

    if (fs.existsSync(model.file) === false) {
      throw new Error(`Model ${model.file} does not exists.`);
    }

    const type = path.extname(model.file).toUpperCase();

    if (ModelType[type] === ModelType.PMDL && model.hotwords.length > 1) {
      throw new Error('Personal models can define only one hotword.');
    }

    this.models.push(model);
    this.lookupTable = this.generateHotwordsLookupTable();
  }

  get modelString(): string {
    return this.models.map((model) => model.file).join();
  }

  get sensitivityString(): string {
    return this.models.map((model) => model.sensitivity).join();
  }

  lookup(index: number): string {
    const lookupIndex = index - 1;
    if (lookupIndex < 0 || lookupIndex >= this.lookupTable.length) {
      throw new Error('Index out of bounds.');
    }
    return this.lookupTable[lookupIndex];
  }

  numHotwords(): number {
    return this.lookupTable.length;
  }

  private generateHotwordsLookupTable(): Array<string> {
    return this.models.reduce((hotwords, model) => {
      return hotwords.concat(model.hotwords);
    }, new Array<string>());
  }
}

export class SnowboyDetect extends stream.Writable implements SnowboyDetectInterface {
  nativeInstance: SnowboyDetectNativeInterface;
  private models: HotwordModels;

  constructor(options: DetectorOptions) {
    super();

    this.models = options.models;
    this.nativeInstance = new SnowboyDetectNative(options.resource, options.models.modelString);

    if (this.nativeInstance.NumHotwords() !== options.models.numHotwords()) {
      throw new Error('Loaded hotwords count does not match number of hotwords defined.');
    }

    this.nativeInstance.SetSensitivity(options.models.sensitivityString);

    if (options.audioGain) {
      this.nativeInstance.SetAudioGain(options.audioGain);
    }

    if (options.applyFrontend) {
      this.nativeInstance.ApplyFrontend(options.applyFrontend);
    }

    if (options.highSensitivity) {
      this.nativeInstance.SetHighSensitivity(options.highSensitivity);
    }
  }

  reset(): boolean {
    return this.nativeInstance.Reset();
  }

  runDetection(buffer: Buffer): number {
    const index = this.nativeInstance.RunDetection(buffer);
    this.processDetectionResult(index, buffer);
    return index;
  }

  setSensitivity(sensitivity: string): void {
    this.nativeInstance.SetSensitivity(sensitivity);
  }

  setHighSensitivity(highSensitivity: string): void {
    this.nativeInstance.SetHighSensitivity(highSensitivity);
  }

  getSensitivity(): string {
    return this.nativeInstance.GetSensitivity();
  }

  setAudioGain(gain: number): void {
    this.nativeInstance.SetAudioGain(gain);
  }

  updateModel(): void {
    this.nativeInstance.UpdateModel();
  }

  numHotwords(): number {
    return this.nativeInstance.NumHotwords();
  }

  sampleRate(): number {
    return this.nativeInstance.SampleRate();
  }

  numChannels(): number {
    return this.nativeInstance.NumChannels();
  }

  bitsPerSample(): number {
    return this.nativeInstance.BitsPerSample();
  }

  // Stream implementation
  _write(chunk: Buffer, encoding: string, callback: Function) {
    const index = this.nativeInstance.RunDetection(chunk);
    this.processDetectionResult(index, chunk);
    return callback();
  }

  private processDetectionResult(index: number, buffer: Buffer): void {
    switch (index) {
      case DetectionResult.ERROR:
        this.emit('error');
        break;

      case DetectionResult.SILENCE:
        this.emit('silence');
        break;

      case DetectionResult.SOUND:
        this.emit('sound', buffer);
        break;

      default:
        const hotword = this.models.lookup(index);
        this.emit('hotword', index, hotword, buffer);
        break;
    }
  }
}

export const Detector = SnowboyDetect;
export const Models = HotwordModels;
