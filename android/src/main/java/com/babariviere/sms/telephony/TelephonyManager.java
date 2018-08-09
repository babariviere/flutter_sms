package com.babariviere.sms.telephony;

import android.annotation.TargetApi;
import android.content.Context;
import android.os.Build;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

public class TelephonyManager {

    private Context context;
    private android.telephony.TelephonyManager manager;

    public TelephonyManager(Context context) {
        this.context = context;
    }

    @TargetApi(Build.VERSION_CODES.M)
    public int getSimCount() {
        return this.getManager().getPhoneCount();
    }

    public String getSimId(int slotId) {
        return this.getManager().getDeviceId(slotId);
    }



    private android.telephony.TelephonyManager getManager() {
        if (this.manager == null) {
            this.manager = (android.telephony.TelephonyManager)this.context.getSystemService(Context.TELEPHONY_SERVICE);
        }
        return this.manager;
    }

    public int getSimState(int slotId) {
        try {
            Method getSimStateMethod = this.getManager().getClass().getMethod("getSimState", int.class);
            Object result = getSimStateMethod.invoke(this.getManager(), slotId);
            if (result != null) {
                return (int)result;
            }
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
        }

        return android.telephony.TelephonyManager.SIM_STATE_UNKNOWN;
    }
}
