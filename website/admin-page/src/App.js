import React, { useEffect, useState } from 'react';
import { getAuth, onAuthStateChanged } from 'firebase/auth';
import Admin from './components/Admin';
import Login from './components/Login'; 
import MissionList from './components/MissionList'; // MissionList 컴포넌트를 가져옵니다.
import UserSearch from './components/UserSearch'; 
import { BrowserRouter as Router, Route, Link, Routes } from "react-router-dom";
import './App.css';

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
    <Router>
      <div className="App">
        {user && (
          <nav>
           <ul style={{ display: 'flex', listStyle: 'none' }}>
              <li>
                <Link to="/admin" className="nav-link">인증사진</Link>  
              </li>
              <li>
                <Link to="/missionlist" className="nav-link">미션리스트</Link>  
              </li>
              <li>
                <Link to="/usersearch" className="nav-link">유저검색</Link> 
              </li>
            </ul>
          </nav>
        )}
        <Routes>
          <Route path="/" element={<Login />} />
          <Route path="/admin" element={user ? <Admin /> : <Login />} />
          <Route path="/missionlist" element={user ? <MissionList /> : <Login />} />
          <Route path="/usersearch" element={user ? <UserSearch /> : <Login />} /> 
        </Routes>
      </div>
    </Router>
  );
}

export default App;