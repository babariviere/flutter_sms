package com.babariviere.sms;

import android.content.ContentResolver;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.provider.BaseColumns;
import android.provider.Telephony;

import java.util.HashSet;
import java.util.Set;

/**
 * This code is taken from:
 * https://android.googlesource.com/platform/packages/apps/ContactsCommon/+/7aba85a08c4729123a55341e8a0f9eb5a89e1a14/src/com/android/contacts/common/compat/TelephonyThreadsCompat.java
 */

class TelephonyCompat {
  /**
   * Copied from {@link Telephony.Threads#getOrCreateThreadId(Context, String)}
   */
  private static long getOrCreateThreadIdInternal(Context context, String recipient) {
    Set<String> recipients = new HashSet<>();
    recipients.add(recipient);
    return getOrCreateThreadIdInternal(context, recipients);
  }

  // Below is code copied from Telephony and SqliteWrapper
  /**
   * Private {@code content://} style URL for this table.
   */
  private static final Uri THREAD_ID_CONTENT_URI = Uri.parse("content://mms-sms/threadID");

  public static long getOrCreateThreadId(Context context, String recipient) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      return Telephony.Threads.getOrCreateThreadId(context, recipient);
    } else {
      return getOrCreateThreadIdInternal(context, recipient);
    }
  }

  /**
   * Given the recipients list and subject of an unsaved message,
   * return its thread ID.  If the message starts a new thread,
   * allocate a new thread ID.  Otherwise, use the appropriate
   * existing thread ID.
   *
   * <p>Find the thread ID of the same set of recipients (in any order,
   * without any additions). If one is found, return it. Otherwise,
   * return a unique thread ID.</p>
   */
  private static long getOrCreateThreadIdInternal(Context context, Set<String> recipients) {
    Uri.Builder uriBuilder = THREAD_ID_CONTENT_URI.buildUpon();
    for (String recipient : recipients) {
      uriBuilder.appendQueryParameter("recipient", recipient);
    }
    Uri uri = uriBuilder.build();
    Cursor cursor = query(
        context.getContentResolver(), uri, new String[] {BaseColumns._ID});
    if (cursor != null) {
      try {
        if (cursor.moveToFirst()) {
          return cursor.getLong(0);
        }
      } finally {
        cursor.close();
      }
    }
    throw new IllegalArgumentException("Unable to find or allocate a thread ID.");
  }

  private static Cursor query(ContentResolver resolver, Uri uri, String[] projection) {
    try {
      return resolver.query(uri, projection, null, null, null);
    } catch (Exception e) {
      return null;
    }
  }
}