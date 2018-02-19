interface SnowboyDetectNativeInterface {
  new (resource: string, models: string): SnowboyDetectNativeInterface;
  Reset(): boolean;
  RunDetection(audioData: Buffer): number;
  SetSensitivity(sensitivity: string): void;
  SetHighSensitivity(highSensitivity: string): void;
  GetSensitivity(): string;
  SetAudioGain(audioGain: number): void;
  UpdateModel(): void;
  NumHotwords(): number;
  SampleRate(): number;
  NumChannels(): number;
  BitsPerSample(): number;
  ApplyFrontend(applyFrontend: boolean): void;
}
