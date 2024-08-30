import React from 'react';
import { getAuth, signOut } from 'firebase/auth';

const Logout = () => {
  const auth = getAuth();
  
  const handleLogout = () => {
    signOut(auth).then(() => {
      console.log("User signed out")
    }).catch((error) => {
      console.error("Failed to sign out", error);
    });
  };

  return (
    <button style={logoutButtonStyle} onClick={handleLogout}>Logout</button>
  );
};

export default Logout;

// CSS
const logoutButtonStyle = {
  position: 'absolute',
  right: '20px',
  top: '20px',
};
