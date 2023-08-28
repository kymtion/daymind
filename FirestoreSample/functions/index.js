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

// 매일 저녁 6시에 실행되는 스케쥴러
exports.scheduledFunction = functions.pubsub.schedule('0 19 * * *').timeZone('Asia/Seoul').onRun(async (context) => {
  // Firestore에서 모든 사용자의 FCM 토큰을 가져옵니다.
  const usersSnapshot = await firestore.collection('users').get();
  
  usersSnapshot.forEach(async (doc) => {
      const userData = doc.data();
      const fcmToken = userData.fcmToken;

      if (!fcmToken) {
        console.error('FCM Token not found for the user');
        return;
      }

      // FCM 푸시 알람 보내기
      const message = {
        token: fcmToken,
        notification: {
          title: '오늘 밤 몇시에 주무실 계획이신가요? 😀',
          body: '상쾌한 아침을 위한 준비, 지금 바로 수면 미션을 등록하세요!',
        },
        apns: {
          payload: {
            aps: {
              sound: 'default', // 'default' 또는 사용자 정의 사운드
            },
          },
        },
      };

      // 알림 전송
      await admin.messaging().send(message);
  });

  console.log('Notifications sent successfully at 6 PM');
  return null;
});