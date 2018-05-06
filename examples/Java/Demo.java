import ai.kitt.snowboy.*;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.DataLine;
import javax.sound.sampled.SourceDataLine;
import javax.sound.sampled.TargetDataLine;

public class Demo {
  static {
    System.loadLibrary("snowboy-detect-java");
  }

  public static void main(String[] args) {
    // Sets up audio.
    AudioFormat format = new AudioFormat(16000, 16, 1, true, false);
    DataLine.Info targetInfo = new DataLine.Info(TargetDataLine.class, format);

    // Sets up Snowboy.
    SnowboyDetect detector = new SnowboyDetect("resources/common.res",
                                               "resources/models/snowboy.umdl");
    detector.SetSensitivity("0.5");
    detector.SetAudioGain(1);
    detector.ApplyFrontend(false);

    try {
      TargetDataLine targetLine =
        (TargetDataLine) AudioSystem.getLine(targetInfo);
      targetLine.open(format);
      targetLine.start();
      
      // Reads 0.1 second of audio in each call.
      byte[] targetData = new byte[3200];
      short[] snowboyData = new short[1600];
      int numBytesRead;

      while (true) {
        // Reads the audio data in the blocking mode. If you are on a very slow
        // machine such that the hotword detector could not process the audio
        // data in real time, this will cause problem...
        numBytesRead = targetLine.read(targetData, 0, targetData.length);

        if (numBytesRead == -1) {
          System.out.print("Fails to read audio data.");
          break;
        }

        // Converts bytes into int16 that Snowboy will read.
        ByteBuffer.wrap(targetData).order(
            ByteOrder.LITTLE_ENDIAN).asShortBuffer().get(snowboyData);

        // Detection.
        int result = detector.RunDetection(snowboyData, snowboyData.length);
        if (result > 0) {
          System.out.print("Hotword " + result + " detected!\n");
        }
      }
    } catch (Exception e) {
      System.err.println(e);
    }
  }
}
