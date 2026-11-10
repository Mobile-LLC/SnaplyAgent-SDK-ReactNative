//
//  SnaplyAgentModule.kt
//  @snaplyagent/react-native
//
//  Created by Gevorg Karapetyan on 11/10/26.
//  Copyright © 2026 iFixgroup. All rights reserved.
//

package com.snaplyagent.reactnative

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.UiThreadUtil
import com.facebook.react.bridge.WritableMap
import com.facebook.react.module.annotations.ReactModule
import com.snaply.agent.CaptureResult
import com.snaply.agent.LiveSession
import com.snaply.agent.Snaply
import com.snaply.agent.SnaplyCallbacks
import com.snaply.agent.SnaplyEnvironment
import com.snaply.agent.SnaplyException
import com.snaply.agent.SnaplyUser

/** Bridges the JavaScript API to the native SDK. A React Native screen is native views: nothing else is needed. */
@ReactModule(name = SnaplyAgentModule.NAME)
class SnaplyAgentModule(reactContext: ReactApplicationContext) : NativeSnaplyAgentSpec(reactContext) {
    override fun getName(): String = NAME

    override fun configure(key: String, host: String?, userId: String?, userName: String?, collectVendorId: Boolean, language: String, promise: Promise) {
        UiThreadUtil.runOnUiThread {
            try {
                Snaply.on(callbacks)
                // The activity, when there is one: it is already on screen by the time JavaScript runs, and the
                // SDK can only learn that from being handed it.
                Snaply.init(
                    context = reactApplicationContext.currentActivity ?: reactApplicationContext,
                    key = key,
                    environment = host?.let { SnaplyEnvironment.Custom(it) } ?: SnaplyEnvironment.Live,
                    user = userId?.let { SnaplyUser(it, userName) },
                    collectVendorId = collectVendorId,
                    language = language,
                )
                promise.resolve(null)
            } catch (error: SnaplyException) {
                promise.reject(error.code, error.message, error, Arguments.createMap().apply { putInt("status", error.status) })
            }
        }
    }

    override fun identify(id: String, name: String?, phone: String?, identitySignature: String?) {
        Snaply.identify(id = id, name = name, phone = phone, identitySignature = identitySignature)
    }

    override fun reset() = Snaply.reset()

    override fun supportCode(promise: Promise) = promise.resolve(Snaply.supportCode())

    override fun showSupportCode() {
        UiThreadUtil.runOnUiThread { Snaply.showSupportCode() }
    }

    override fun stop() {
        UiThreadUtil.runOnUiThread { Snaply.stop() }
    }

    private val callbacks = object : SnaplyCallbacks {
        override fun onRequestShown() = emit("requestShown")

        override fun onAllowed(capture: CaptureResult) = emit("allowed") {
            putString("captureId", capture.captureId)
            putString("imageUrl", capture.imageUrl)
        }

        override fun onDenied() = emit("denied")

        override fun onExpired() = emit("expired")

        override fun onError(error: Exception) = emit("error") {
            val snaply = error as? SnaplyException
            putString("code", snaply?.code ?: "error")
            putString("message", error.message.orEmpty())
            putInt("status", snaply?.status ?: 0)
        }

        override fun onRemoteControl(active: Boolean) = emit("remoteControl") { putBoolean("active", active) }

        override fun onLiveEnded(session: LiveSession) = emit("liveEnded") { putString("sessionId", session.sessionId) }
    }

    private fun emit(name: String, fields: WritableMap.() -> Unit = {}) {
        emitOnSnaplyEvent(Arguments.createMap().apply { putString("name", name) }.apply(fields))
    }

    companion object {
        const val NAME = "SnaplyAgent"
    }
}
