// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// ‼️ NOTE: Changes should also be reflected in `objc-module-import-test.m`.

// TODO(Xcode 14.3): Re-enable contest when GHA supports Xcode 14.3.
// @import Firebase;
// @import FirebaseABTesting;
// @import FirebaseAnalytics;
// @import FirebaseAppCheck;
// #if TARGET_OS_IOS && !TARGET_OS_MACCATALYST
// @import FirebaseAppDistribution;
// #endif
// @import FirebaseAuth;
// @import FirebaseCore;
// @import FirebaseCrashlytics;
// @import FirebaseDatabase;
// #if TARGET_OS_IOS && !TARGET_OS_MACCATALYST
// @import FirebaseDynamicLinks;
// #endif
// @import FirebaseFirestore;
// @import FirebaseFunctions;
// #if (TARGET_OS_IOS || TARGET_OS_TV) && !TARGET_OS_MACCATALYST
// @import FirebaseInAppMessaging;
// #endif
// @import FirebaseInstallations;
// @import FirebaseMessaging;
// #if (TARGET_OS_IOS && !TARGET_OS_MACCATALYST) || TARGET_OS_TV
// @import FirebasePerformance;
// #endif
// @import FirebaseRemoteConfig;
// @import FirebaseStorage;
