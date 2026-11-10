//
//  SnaplyAgentPackage.kt
//  @snaplyagent/react-native
//
//  Created by Gevorg Karapetyan on 11/10/26.
//  Copyright © 2026 iFixgroup. All rights reserved.
//

package com.snaplyagent.reactnative

import com.facebook.react.BaseReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider

class SnaplyAgentPackage : BaseReactPackage() {
    override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? =
        if (name == SnaplyAgentModule.NAME) SnaplyAgentModule(reactContext) else null

    override fun getReactModuleInfoProvider(): ReactModuleInfoProvider = ReactModuleInfoProvider {
        mapOf(
            SnaplyAgentModule.NAME to ReactModuleInfo(
                name = SnaplyAgentModule.NAME,
                className = SnaplyAgentModule.NAME,
                canOverrideExistingModule = false,
                needsEagerInit = false,
                isCxxModule = false,
                isTurboModule = true,
            ),
        )
    }
}
