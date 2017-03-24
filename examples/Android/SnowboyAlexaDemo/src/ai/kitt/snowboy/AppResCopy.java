package ai.kitt.snowboy;

import android.content.Context;
import android.util.Log;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;

public class AppResCopy {
    private final static String TAG = AppResCopy.class.getSimpleName();
    private static String envWorkSpace = Constants.DEFAULT_WORK_SPACE;

    private static void copyFilesFromAssets(Context context, String assetsSrcDir, String sdcardDstDir, boolean override) {
        try {
            String fileNames[] = context.getAssets().list(assetsSrcDir);
            if (fileNames.length > 0) {
                Log.i(TAG, assetsSrcDir +" directory has "+fileNames.length+" files.\n");
                File dir = new File(sdcardDstDir);
                if (!dir.exists()) {
                    if (!dir.mkdirs()) {
                        Log.e(TAG, "mkdir failed: "+sdcardDstDir);
                        return;
                    } else {
                        Log.i(TAG, "mkdir ok: "+sdcardDstDir);
                    }
                } else {
                     Log.w(TAG, sdcardDstDir+" already exists! ");
                }
                for (String fileName : fileNames) {
                    copyFilesFromAssets(context,assetsSrcDir + "/" + fileName,sdcardDstDir+"/"+fileName, override);
                }
            } else {
                Log.i(TAG, assetsSrcDir +" is file\n");
                File outFile = new File(sdcardDstDir);
                if (outFile.exists()) {
                    if (override) {
                        outFile.delete();
                        Log.e(TAG, "overriding file "+ sdcardDstDir +"\n");
                    } else {
                        Log.e(TAG, "file "+ sdcardDstDir +" already exists. No override.\n");
                        return;
                    }
                }
                InputStream is = context.getAssets().open(assetsSrcDir);
                FileOutputStream fos = new FileOutputStream(outFile);
                byte[] buffer = new byte[1024];
                int byteCount=0;
                while ((byteCount=is.read(buffer)) != -1) {
                    fos.write(buffer, 0, byteCount);
                }
                fos.flush();
                is.close();
                fos.close();
                Log.i(TAG, "copy to "+sdcardDstDir+" ok!");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void copyResFromAssetsToSD(Context context) {
        copyFilesFromAssets(context, Constants.ASSETS_RES_DIR, envWorkSpace+"/", true);
    }
}
