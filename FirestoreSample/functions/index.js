const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');
const serviceAccount = require("./daymind-2f6e2-firebase-adminsdk-yba79-a6005cbb37.json");
const { Firestore } = require('@google-cloud/firestore');
const firestore = new Firestore();

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

exports.exchangeKakaoCode = functions.https.onCall(async (data, context) => {
  const accessToken = data.access_token; // 클라이언트 앱에서 전달된 액세스 토큰

  // Check the validity of the access_token
  if (!accessToken || typeof accessToken !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'The function must be called with one argument "access_token"');
  }

  try {
    // 카카오 사용자 정보 요청
    const userInfoResponse = await axios.get('https://kapi.kakao.com/v2/user/me', {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    }).catch(err => {
      throw new functions.https.HttpsError('unknown', `Failed to get Kakao user info: ${err.message}`);
    });

    const kakaoUserId = String(userInfoResponse.data.id);

    // Firebase 사용자 생성 또는 가져오기
    let firebaseUserId;

    try {
      const userRecord = await admin.auth().getUser(kakaoUserId);
      firebaseUserId = userRecord.uid;
    } catch (error) {
      if (error.code === 'auth/user-not-found') {
        // 사용자가 없다면 새로운 사용자를 생성합니다.
        try {
          const userRecord = await admin.auth().createUser({ uid: kakaoUserId });
          firebaseUserId = userRecord.uid;
        } catch (err) {
          throw new functions.https.HttpsError('unknown', `Failed to create Firebase user: ${err.message}`);
        }
      } else {
        throw new functions.https.HttpsError('unknown', `Failed to get Firebase user: ${error.message}`);
      }
    }

    // Firebase 사용자 인증 토큰 생성
    let customToken;

    try {
      customToken = await admin.auth().createCustomToken(firebaseUserId);
    } catch (error) {
      throw new functions.https.HttpsError('unknown', `Failed to create Firebase token: ${error.message}`);
    }

    return {
      firebase_token: customToken,
    };
  } catch (error) {
    if (error.response) {
      throw new functions.https.HttpsError('unknown', error.message, error.response.data);
    } else {
      // HTTP 응답 오류가 아닌 경우
      throw new functions.https.HttpsError('unknown', error.message);
    }
  }
});

// Firestore에 FCM 토큰 저장할 때 디바이스 ID도 저장
exports.saveFcmToken = functions.https.onCall(async (data, context) => {
  const userId = context.auth.uid;
  const fcmToken = data.fcmToken;
  const deviceId = data.deviceId;

  if (!fcmToken || !deviceId) {
    throw new functions.https.HttpsError('invalid-argument', 'FCM 토큰과 디바이스 ID는 필수입니다.');
  }

  // Firestore에 FCM 토큰과 디바이스 ID 저장
  await firestore.collection('users').doc(userId).set({
    fcmTokens: admin.firestore.FieldValue.arrayUnion({ token: fcmToken, deviceId: deviceId }),
  }, { merge: true });

  return { success: true };
});

// 매일 저녁 7시에 실행되는 스케쥴러
exports.scheduledFunction = functions.pubsub.schedule('0 19 * * *').timeZone('Asia/Seoul').onRun(async (context) => {
  const usersSnapshot = await firestore.collection('users').get();
  const sentDeviceIds = new Set();  // 이미 알림을 보낸 디바이스 ID를 저장하는 Set

  for (const doc of usersSnapshot.docs) {
    const userData = doc.data();
    const fcmToken = userData.fcmToken;
    const deviceId = userData.deviceId;
    const firebasePushNotificationEnabled = userData.notificationSettings ? userData.notificationSettings.firebasePushNotificationEnabled : true;

    // 알림이 비활성화된 경우 스킵
    if (!fcmToken || !firebasePushNotificationEnabled) {
      console.log('FCM Token not found for the user or push notification is disabled');
      continue;
    }

    // 이미 알림을 보낸 디바이스는 스킵
    if (sentDeviceIds.has(deviceId)) {
      console.log(`Skipping duplicate notification for device ${deviceId}`);
      continue;
    }

    const message = {
      token: fcmToken, // 단일 fcmToken 사용
      notification: {
        title: '오늘 밤 몇 시에 주무실 계획이신가요? 😀',
        body: '수면 미션을 등록하세요!',
      },
      apns: {
        payload: {
          aps: {
            sound: 'default', // 'default' 또는 사용자 정의 사운드
          },
        },
      },
    };

    try {
      await admin.messaging().send(message);
      console.log(`Notification sent to device ${deviceId}`);
      sentDeviceIds.add(deviceId);
    } catch (error) {
      console.error(`Failed to send notification to device ${deviceId}: ${error.message}`);
    }
  }

  console.log('Notifications sent successfully at 7 PM');
  return null;
});