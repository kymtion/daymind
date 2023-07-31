import React, { useEffect, useState } from 'react';
import { getAuth, onAuthStateChanged } from 'firebase/auth';
import Admin from './components/Admin';
import Login from './components/Login'; 

function App() {
  const [user, setUser] = useState(null);
  const allowedEmail = 'kymtion@kakao.com'; // 여기에 접근을 허용할 이메일 주소를 작성합니다.

  useEffect(() => {
    const auth = getAuth();
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      if (user && user.email === allowedEmail) { 
        // 사용자가 로그인했고, 그 이메일 주소가 허용된 이메일인 경우
        setUser(user);
      } else {
        setUser(null);
      }
    });

    // Clean up subscription on unmount
    return () => unsubscribe();
  }, []);

  return (
    <div className="App">
      {user ? <Admin /> : <Login />}
    </div>
  );
}

export default App;

