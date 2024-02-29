package com.example.ra9mana
import io.flutter.embedding.android.FlutterActivity

import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.telephony.SubscriptionInfo
import android.telephony.SubscriptionManager
import android.os.Build

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example/carrier_info"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getCarrierNames") {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
                    val sm = getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
                    val infoList: List<SubscriptionInfo> = sm.activeSubscriptionInfoList
                    val carrierNames = mutableListOf<String>()
                    for (info in infoList) {
                        carrierNames.add(info.carrierName.toString())
                    }
                    result.success(carrierNames)
                } else {
                    result.error("UNAVAILABLE", "Carrier name not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}