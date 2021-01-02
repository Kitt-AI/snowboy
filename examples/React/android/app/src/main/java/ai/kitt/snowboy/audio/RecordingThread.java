package ai.kitt.snowboy.audio;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

import ai.kitt.snowboy.Constants;
import ai.kitt.snowboy.MsgEnum;
import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

import ai.kitt.snowboy.SnowboyDetect;

public class RecordingThread {
    static { System.loadLibrary("snowboy-detect-android"); }

    private static final String TAG = RecordingThread.class.getSimpleName();

    private static final String ACTIVE_RES = Constants.ACTIVE_RES;
    //private static final String ACTIVE_UMDL = Constants.ACTIVE_UMDL;
    private static final String ACTIVE_PMDL = Constants.ACTIVE_PMDL;
    
    private boolean shouldContinue;
    private AudioDataReceivedListener listener = null;
    private Handler handler = null;
    private Thread thread;
    
    private static String strEnvWorkSpace = Constants.DEFAULT_WORK_SPACE;
    private String activeModel = strEnvWorkSpace+ACTIVE_PMDL;
    private String commonRes = strEnvWorkSpace+ACTIVE_RES;   
    
    private SnowboyDetect detector = new SnowboyDetect(commonRes, activeModel);

    public RecordingThread(Handler handler, AudioDataReceivedListener listener) {
        this.handler = handler;
        this.listener = listener;
    }

    private void sendMessage(MsgEnum what, Object obj){
        if (null != handler) {
            Message msg = handler.obtainMessage(what.ordinal(), obj);
            handler.sendMessage(msg);
        }
    }

    public void startRecording() {
        detector.setSensitivity("0.60");
        //detector.setAudioGain(1);
        detector.applyFrontend(true);

        if (thread != null)
            return;

        shouldContinue = true;
        thread = new Thread(new Runnable() {
            @Override
            public void run() {
                record();
            }
        });
        thread.start();
    }

    public void stopRecording() {
        if (thread == null)
            return;

        shouldContinue = false;
        thread = null;
    }

    private void record() {
        Log.v(TAG, "Start");
        android.os.Process.setThreadPriority(android.os.Process.THREAD_PRIORITY_AUDIO);

        // Buffer size in bytes: for 0.1 second of audio
        int bufferSize = (int)(Constants.SAMPLE_RATE * 0.1 * 2);
        if (bufferSize == AudioRecord.ERROR || bufferSize == AudioRecord.ERROR_BAD_VALUE) {
            bufferSize = Constants.SAMPLE_RATE * 2;
        }

        byte[] audioBuffer = new byte[bufferSize];
        AudioRecord record = new AudioRecord(
            MediaRecorder.AudioSource.DEFAULT,
            Constants.SAMPLE_RATE,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
            bufferSize);

        if (record.getState() != AudioRecord.STATE_INITIALIZED) {
            Log.e(TAG, "Audio Record can't initialize!");
            return;
        }
        record.startRecording();
        if (null != listener) {
            listener.start();
        }
        Log.v(TAG, "Start recording");

        long shortsRead = 0;
        while (shouldContinue) {
            if(android.os.Build.VERSION.SDK_INT >= 23)
                record.read(audioBuffer, 0, audioBuffer.length, AudioRecord.READ_BLOCKING);
            else
                record.read(audioBuffer, 0, audioBuffer.length);

            if (null != listener) {
                listener.onAudioDataReceived(audioBuffer, audioBuffer.length);
            }
            
            // Converts to short array.
            short[] audioData = new short[audioBuffer.length / 2];
            ByteBuffer.wrap(audioBuffer).order(ByteOrder.LITTLE_ENDIAN).asShortBuffer().get(audioData);

            shortsRead += audioData.length;

            // Snowboy hotword detection.
            int result = detector.runDetection(audioData, audioData.length);

            if (result == -2) {
                // post a higher CPU usage:
                sendMessage(MsgEnum.MSG_VAD_NOSPEECH, null);
            } else if (result == -1) {
                sendMessage(MsgEnum.MSG_ERROR, "Unknown Detection Error");
            } else if (result == 0) {
                // post a higher CPU usage:
                sendMessage(MsgEnum.MSG_VAD_SPEECH, null);
            } else if (result > 0) {
                sendMessage(MsgEnum.MSG_ACTIVE, null);
                Log.i("Snowboy: ", "Hotword " + Integer.toString(result) + " detected!");
            }
        }

        record.stop();
        record.release();

        if (null != listener) {
            listener.stop();
        }
        Log.v(TAG, String.format("Recording stopped. Samples read: %d", shortsRead));
    }
}
