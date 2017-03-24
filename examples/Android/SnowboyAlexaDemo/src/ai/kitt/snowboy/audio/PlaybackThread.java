package ai.kitt.snowboy.audio;

import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.util.Log;
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

public class PlaybackThread {
    private static final String TAG = PlaybackThread.class.getSimpleName();

    public PlaybackThread() {
    }

    private Thread thread;
    private boolean shouldContinue;

    public boolean playing() {
        return thread != null;
    }

    public void startPlayback() {
        if (thread != null)
            return;

        // Start streaming in a thread
        shouldContinue = true;
        thread = new Thread(new Runnable() {
            @Override
            public void run() {
                play();
            }
        });
        thread.start();
    }

    public void stopPlayback() {
        if (thread == null)
            return;

        shouldContinue = false;
        thread = null;
    }

    public short[] readPCM() {
        try {
            File recordFile = new File(Constants.SAVE_AUDIO);
            InputStream inputStream = new FileInputStream(recordFile);
            BufferedInputStream bufferedInputStream = new BufferedInputStream(inputStream);
            DataInputStream dataInputStream = new DataInputStream(bufferedInputStream);

            byte[] audioData = new byte[(int)recordFile.length()];

            // int i = 0;
            // while (dataInputStream.available() > 0) {
            //     audioData[i] = dataInputStream.readByte();
            //     i++;
            // }
            dataInputStream.read(audioData);
            dataInputStream.close();
            Log.v(TAG, "audioData size: " + audioData.length);

            ShortBuffer sb = ByteBuffer.wrap(audioData).order(ByteOrder.LITTLE_ENDIAN).asShortBuffer();
            short[] samples = new short[sb.limit() - sb.position()];
            sb.get(samples);
            return samples;
        } catch (FileNotFoundException e) {
            Log.e(TAG, "Cannot find saved audio file", e);
        } catch (IOException e) {
            Log.e(TAG, "IO Exception on saved audio file", e);
        }
        return null;
    }

    private void play() {
        short[] samples = this.readPCM();
        int shortSizeInBytes = Short.SIZE / Byte.SIZE;
        int bufferSizeInBytes = samples.length * shortSizeInBytes;
        Log.v(TAG, "shortSizeInBytes: " + shortSizeInBytes + " bufferSizeInBytes: " + bufferSizeInBytes);

        AudioTrack audioTrack = new AudioTrack(
                AudioManager.STREAM_MUSIC,
                Constants.SAMPLE_RATE,
                AudioFormat.CHANNEL_OUT_MONO,
                AudioFormat.ENCODING_PCM_16BIT,
                bufferSizeInBytes,
                AudioTrack.MODE_STREAM);

        audioTrack.play();

        audioTrack.write(samples, 0, samples.length);
        Log.v(TAG, "Audio playback started");

        if (!shouldContinue) {
            audioTrack.release();
        }
    }
}
