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
    private static final String LOG_TAG = PlaybackThread.class.getSimpleName();

    public PlaybackThread() {
    }

    private Thread mThread;
    private boolean mShouldContinue;
    private PlaybackListener mListener;

    public boolean playing() {
        return mThread != null;
    }

    public void startPlayback() {
        if (mThread != null)
            return;

        // Start streaming in a thread
        mShouldContinue = true;
        mThread = new Thread(new Runnable() {
            @Override
            public void run() {
                play();
            }
        });
        mThread.start();
    }

    public void stopPlayback() {
        if (mThread == null)
            return;

        mShouldContinue = false;
        mThread = null;
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
            Log.v(LOG_TAG, "audioData size: " + audioData.length);

            ShortBuffer sb = ByteBuffer.wrap(audioData).order(ByteOrder.LITTLE_ENDIAN).asShortBuffer();
            short[] samples = new short[sb.limit() - sb.position()];
            sb.get(samples);
            return samples;
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    private void play() {
        short[] samples = this.readPCM();
        int shortSizeInBytes = Short.SIZE / Byte.SIZE;
        int bufferSizeInBytes = samples.length * shortSizeInBytes;
        Log.v(LOG_TAG, "shortSizeInBytes: " + shortSizeInBytes + " bufferSizeInBytes: " + bufferSizeInBytes);

        AudioTrack audioTrack = new AudioTrack(
                AudioManager.STREAM_MUSIC,
                Constants.SAMPLE_RATE,
                AudioFormat.CHANNEL_OUT_MONO,
                AudioFormat.ENCODING_PCM_16BIT,
                bufferSizeInBytes,
                AudioTrack.MODE_STREAM);

        audioTrack.play();

        audioTrack.write(samples, 0, samples.length);
        Log.v(LOG_TAG, "Audio playback started");

        if (!mShouldContinue) {
            audioTrack.release();
        }
    }
}
