import React, { useEffect, useState } from 'react';
import { storage } from '../firebase';
import { listAll, ref, getDownloadURL } from "firebase/storage";
import Logout from './Logout';

const Admin = () => {
  const [images, setImages] = useState([]);

  useEffect(() => {
    const fetchImages = async () => {
      const imageFolder = ref(storage, '수면미션');
      const { items } = await listAll(imageFolder);

      const urlPromises = items.map(item => getDownloadURL(item));

      const urls = await Promise.all(urlPromises);

      setImages(urls);
    };

    fetchImages();
  }, []);

  return (
    <div>
      <Logout />
      <h1>Admin Page</h1>
      <div style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(7, 1fr)',
        gap: '10px',
      }}>
        {images.map((url, index) => (
          <div key={index} style={{maxWidth: '100%'}}>
            <img src={url} alt="" style={{ width: '100%', height: 'auto' }} />
          </div>
        ))}
      </div>
    </div>
  );
};

export default Admin;
