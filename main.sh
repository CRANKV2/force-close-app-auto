#!/system/bin/sh

# Register broadcast receiver
am broadcast -a "android.intent.action.CLOSE_SYSTEM_DIALOGS" -n "com.example.forceclosereceiver/.ForceCloseReceiver"

# Define broadcast receiver class
cat > /data/local/tmp/ForceCloseReceiver.java << EOF
package com.example.forceclosereceiver;

import android.app.ActivityManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

public class ForceCloseReceiver extends BroadcastReceiver {
    private static final String TAG = "ForceCloseReceiver";

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent.getAction().equals("android.intent.action.CLOSE_SYSTEM_DIALOGS")) {
            // Get current foreground activity
            ActivityManager am = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
            String packageName = am.getRunningTasks(1).get(0).topActivity.getPackageName();
            // Force close activity
            am force-stop "$packageName"
            Log.i(TAG, "Force closed app: " + packageName);
        }
    }
}
EOF

# Compile broadcast receiver class
javac /data/local/tmp/ForceCloseReceiver.java

# Install broadcast receiver class
dex2oat --dex-file=/data/local/tmp/ForceCloseReceiver.dex --oat-file=/data/local/tmp/ForceCloseReceiver.oat

# Set permissions on broadcast receiver class
chmod 755 /data/local/tmp/ForceCloseReceiver.oat

###
