package ai.kitt.snowboy.audio;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

import ai.kitt.snowboy.Constants;
import ai.kitt.snowboy.MsgEnum;
import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import android.media.MediaPlayer;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

import ai.kitt.snowboy.SnowboyDetect;

public class RecordingThread {
    static { System.loadLibrary("snowboy-detect-android"); }

    private static final String LOG_TAG = RecordingThread.class.getSimpleName();

    private static final String ACTIVE_RES = Constants.ACTIVE_RES;
    private static final String ACTIVE_UMDL = Constants.ACTIVE_UMDL;
    

    public RecordingThread(Handler handler, AudioDataReceivedListener listener) {
        mListener = listener;
        mHandler = handler;
    }
    
    private boolean mShouldContinue;
    private AudioDataReceivedListener mListener = null;
    private Handler mHandler = null;
    private Thread mThread;
    
    private static String strEnvWorkSpace = Constants.DEFAULT_WORK_SPACE;
    private String activeModel = strEnvWorkSpace+ACTIVE_UMDL;    
    private String commonRes = strEnvWorkSpace+ACTIVE_RES;   
    
    private SnowboyDetect mDetector = new SnowboyDetect(commonRes, activeModel);
    private MediaPlayer mPlayer = new MediaPlayer();
    
    private void SendMessage(MsgEnum what, Object obj){
        if (null != mHandler) {
            Message msg = mHandler.obtainMessage(what.ordinal(), obj);
            mHandler.sendMessage(msg);
        }
    }

    public void startRecording() {
        mDetector.SetSensitivity("0.6");
        //-mDetector.SetAudioGain(1);
        mDetector.ApplyFrontend(true);
        try {
            mPlayer.setDataSource(strEnvWorkSpace+"ding.wav");
            mPlayer.prepare();
        } catch (Exception e) {
            e.printStackTrace();
        }
        if (mThread != null)
            return;

        mShouldContinue = true;
        mThread = new Thread(new Runnable() {
            @Override
            public void run() {
                record();
            }
        });
        mThread.start();
    }

    public void stopRecording() {
        if (mThread == null)
            return;

        mShouldContinue = false;
        mThread = null;
    }

    private void record() {
        Log.v(LOG_TAG, "Start");
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
            Log.e(LOG_TAG, "Audio Record can't initialize!");
            return;
        }
        record.startRecording();
        if (null != mListener) {
            mListener.start();
        }
        Log.v(LOG_TAG, "Start recording");

        long shortsRead = 0;
        while (mShouldContinue) {
            record.read(audioBuffer, 0, audioBuffer.length, AudioRecord.READ_BLOCKING);

            if (null != mListener) {
                mListener.onAudioDataReceived(audioBuffer, audioBuffer.length);
            }
            
            // Converts to short array.
            short[] audioData = new short[audioBuffer.length / 2];
            ByteBuffer.wrap(audioBuffer).order(ByteOrder.LITTLE_ENDIAN).asShortBuffer().get(audioData);

            shortsRead += audioData.length;

            // Snowboy hotword detection.
            int result = mDetector.RunDetection(audioData, audioData.length);

            if (result == -2) {
                SendMessage(MsgEnum.MSG_VAD_NOSPEECH, null);
            } else if (result == -1) {
                SendMessage(MsgEnum.MSG_ERROR, "Unknown Detection Error");
            } else if (result == 0) {
                SendMessage(MsgEnum.MSG_VAD_SPEECH, null);
            } else if (result > 0) {
                SendMessage(MsgEnum.MSG_ACTIVE, null);
                Log.i("Snowboy: ", "Hotword " + Integer.toString(result) + " detected!");
                mPlayer.start();
            }
        }

        record.stop();
        record.release();

        if (null != mListener) {
            mListener.stop();
        }
        Log.v(LOG_TAG, String.format("Recording stopped. Samples read: %d", shortsRead));
    }
}
