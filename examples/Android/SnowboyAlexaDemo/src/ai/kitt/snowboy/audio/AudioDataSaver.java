package ai.kitt.snowboy.audio;

import java.io.BufferedOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import android.util.Log;

import ai.kitt.snowboy.Constants;

public class AudioDataSaver implements AudioDataReceivedListener {

    private static final String TAG = AudioDataSaver.class.getSimpleName();

    // file size of when to delete and create a new recording file
    private final float MAX_RECORDING_FILE_SIZE_IN_MB = 50f;

    // initial file size of recording file
    private final float INITIAL_FILE_SIZE_IN_MB = 1.3f;

    // converted max file size
    private final float MAX_RECORDING_FILE_SIZE_IN_BYTES
            = (MAX_RECORDING_FILE_SIZE_IN_MB - INITIAL_FILE_SIZE_IN_MB) * 1024 * 1024;

    // keeps track of recording file size
    private int recordingFileSizeCounterInBytes = 0;

    private File saveFile = null;
    private DataOutputStream dataOutputStreamInstance = null;

    public AudioDataSaver() {
        saveFile = new File(Constants.SAVE_AUDIO);
        Log.e(TAG, Constants.SAVE_AUDIO);
    }

    @Override
    public void start() {
        if (null != saveFile) {
            if (saveFile.exists()) {
                saveFile.delete();
            }
            try {
                saveFile.createNewFile();
            } catch (IOException e) {
                Log.e(TAG, "IO Exception on creating audio file " + saveFile.toString(), e);
            }

            try {
                BufferedOutputStream bufferedStreamInstance = new BufferedOutputStream(
                        new FileOutputStream(this.saveFile));
                dataOutputStreamInstance = new DataOutputStream(bufferedStreamInstance);
            } catch (FileNotFoundException e) {
                throw new IllegalStateException("Cannot Open File", e);
            }
        }
    }

    @Override
    public void onAudioDataReceived(byte[] data, int length) {
        try {
            if (null != dataOutputStreamInstance) {
                if (recordingFileSizeCounterInBytes >= MAX_RECORDING_FILE_SIZE_IN_BYTES) {
                    stop();
                    start();
                    recordingFileSizeCounterInBytes = 0;
                }
                dataOutputStreamInstance.write(data, 0, length);
                recordingFileSizeCounterInBytes += length;
            }
        } catch (IOException e) {
            Log.e(TAG, "IO Exception on saving audio file " + saveFile.toString(), e);
        }
    }

    @Override
    public void stop() {
        if (null != dataOutputStreamInstance) {
            try {
                dataOutputStreamInstance.close();
            } catch (IOException e) {
                Log.e(TAG, "IO Exception on finishing saving audio file " + saveFile.toString(), e);
            }
            Log.e(TAG, "Recording saved to " + saveFile.toString());
        }
    }
}
