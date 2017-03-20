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

    private File saveFile = null;
    private DataOutputStream dataOutputStreamInstance = null;

    public AudioDataSaver() {
        saveFile = new File(Constants.SAVE_AUDIO);
        Log.e(TAG, Constants.SAVE_AUDIO);
    }

    @Override
    public void start() {
        if(null != saveFile) {
            if (saveFile.exists()) {
                saveFile.delete();
            }
            try {
                saveFile.createNewFile();
            } catch (IOException e) {
                e.printStackTrace();
                throw new IllegalStateException("Cannot create file: " + saveFile.toString());
            }

            try {
                BufferedOutputStream bufferedStreamInstance  = new BufferedOutputStream(
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
            if(null != dataOutputStreamInstance) {
                dataOutputStreamInstance.write(data, 0, length);
            }
        } catch (IOException e) {
            e.printStackTrace();
            throw new IllegalStateException("dataOutputStreamInstance.write(curVal)");
        }
    }

    @Override
    public void stop() {
        if(null != dataOutputStreamInstance) {
            try {
                dataOutputStreamInstance.close();
            } catch (IOException e) {
                e.printStackTrace();
                throw new IllegalStateException("Cannot close buffered writer.");
            }
            Log.e(TAG, "Recording saved to " + saveFile.toString());
        }
    }
}
