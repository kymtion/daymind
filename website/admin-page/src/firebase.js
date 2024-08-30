// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import { getStorage } from "firebase/storage";

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyDkjiqBcCEO5uq2L-gfnepJGAk2pa4ZvHU",
  authDomain: "daymind-2f6e2.firebaseapp.com",
  projectId: "daymind-2f6e2",
  storageBucket: "daymind-2f6e2.appspot.com",
  messagingSenderId: "343251538549",
  appId: "1:343251538549:web:fa83ed75fab8e52765de3c",
  measurementId: "G-ZM8X1MQQE8"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firestore and Storage
const db = getFirestore(app);
const storage = getStorage(app);

// Export Firestore and Storage so that they can be used in other files
export { db, storage };
