package ai.kitt.snowboy.audio;

import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import java.io.BufferedInputStream;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.ShortBuffer;

import ai.kitt.snowboy.Constants;

public class PcmPlayer {

    public short[] readPCM(File recordFile) {
        try {
            InputStream inputStream = new FileInputStream(recordFile);
            BufferedInputStream bufferedInputStream = new BufferedInputStream(inputStream);
            DataInputStream dataInputStream = new DataInputStream(bufferedInputStream);

            byte[] audioData = new byte[(int)recordFile.length()];

            int i = 0;
            while (dataInputStream.available() > 0) {
                audioData[i] = dataInputStream.readByte();
                i++;
            }
            dataInputStream.close();

            ShortBuffer sb = ByteBuffer.wrap(audioData).order(ByteOrder.LITTLE_ENDIAN).asShortBuffer();
            short[] samples = new short[sb.limit()];
            sb.get(samples);
            return samples;
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    public void playPCM() {
        File recordFile = new File(Constants.SAVE_AUDIO);

        int shortSizeInBytes = Short.SIZE / Byte.SIZE;
        short[] audioData = this.readPCM(recordFile);
        int bufferSizeInBytes = audioData.length / shortSizeInBytes;

        AudioTrack track = new AudioTrack(
            AudioManager.STREAM_MUSIC,
            Constants.SAMPLE_RATE,
            AudioFormat.CHANNEL_OUT_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
            bufferSizeInBytes,
            AudioTrack.MODE_STREAM);

        track.play();
        track.write(audioData, 0, bufferSizeInBytes);
    }

}
