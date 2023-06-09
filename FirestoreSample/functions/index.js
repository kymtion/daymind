const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');
const serviceAccount = require("./daymind-2f6e2-firebase-adminsdk-yba79-a6005cbb37.json");

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




