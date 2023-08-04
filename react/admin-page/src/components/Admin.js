import React, { useEffect, useState } from 'react';
import { storage } from '../firebase';
import { listAll, ref, getDownloadURL, getMetadata } from "firebase/storage";
import { getFirestore, doc, updateDoc, getDoc } from "firebase/firestore";


import Logout from './Logout';
import Pagination from './Pagination';
import Modal from './Modal';
import '../App.css';

const ITEMS_PER_PAGE = 50;

const firestore = getFirestore();



const Admin = () => {
  const [images, setImages] = useState([]);
  const [tab, setTab] = useState(0);
  const [page, setPage] = useState(1);
  const [tab1Data, setTab1Data] = useState([]);
  const [tab2Data, setTab2Data] = useState([]);
  const [tab3Data, setTab3Data] = useState([]);
  const [isModalOpen, setModalOpen] = useState(false);
  const [modalContent, setModalContent] = useState(null);

  useEffect(() => {
    const fetchImages = async () => {
      const imageFolder = ref(storage, '수면미션');
      const { items } = await listAll(imageFolder);
    
      const dataPromises = items.map(async item => {
        const url = await getDownloadURL(item);
        const metadata = await getMetadata(item);
        const docRef = doc(firestore, 'missions', metadata.customMetadata.id);
        const docSnap = await getDoc(docRef);
    
        return { 
          url, 
          metadata: {
            ...metadata.customMetadata, 
            ...docSnap.data(),
            selectedTime1: new Date(metadata.customMetadata.selectedTime1),
            selectedTime2: new Date(metadata.customMetadata.selectedTime2)
          }
        };
      });
    
      const data = await Promise.all(dataPromises);
      data.sort((a, b) => new Date(b.metadata.captureTime).getTime() - new Date(a.metadata.captureTime).getTime());
    
      const today = new Date();
      today.setHours(0, 0, 0, 0);
    
      setTab1Data(data.filter(item => item.metadata.missionStatus === '실패').sort((a, b) => new Date(b.metadata.captureTime).getTime() - new Date(a.metadata.captureTime).getTime()));
      setTab2Data(data.filter(item => {
        const selectedTime2 = new Date(item.metadata.selectedTime2);
        selectedTime2.setHours(0, 0, 0, 0);
        return selectedTime2.getTime() === today.getTime();
      }).sort((a, b) => new Date(b.metadata.captureTime).getTime() - new Date(a.metadata.captureTime).getTime()));
      setTab3Data(data.filter(item => {
        const selectedTime2 = new Date(item.metadata.selectedTime2);
        selectedTime2.setHours(0, 0, 0, 0);
        return selectedTime2.getTime() < today.getTime();
      }).sort((a, b) => new Date(b.metadata.captureTime).getTime() - new Date(a.metadata.captureTime).getTime()));
    
      setImages(data);
    };
    

    fetchImages();
  }, []);

  const handleTabChange = (tabNumber) => {
    setTab(tabNumber);
    setPage(1); // Whenever the tab changes, we reset the page number to 1
  };

  const openModal = (content) => {
    setModalContent(content);
    setModalOpen(true);
  };

  const closeModal = () => {
    setModalOpen(false);
  };

  // Get the current data based on the tab selected
  const currentData = tab === 0 ? images : tab === 1 ? tab1Data : tab === 2 ? tab2Data : tab3Data;

  // Calculate the total number of pages
  const totalPages = Math.ceil(currentData.length / ITEMS_PER_PAGE);

  // Get the items for the current page
  const currentPageData = currentData.slice((page - 1) * ITEMS_PER_PAGE, page * ITEMS_PER_PAGE);

  const openConfirmationModal = (missionId) => {
    setModalContent(
      <div>
        <p>정말 미션을 실패처리 하시겠습니까?</p>
        <button onClick={() => setMissionFailure(missionId)} className="detail-button">예</button>
      </div>
    );
    setModalOpen(true);
  };


 const setMissionFailure = async (missionId) => {
    const missionDoc = doc(firestore, 'missions', missionId);
    await updateDoc(missionDoc, {
      missionStatus: '실패'
    });
    closeModal();
  };

  const formatDate = (timestamp) => {
    const date = new Date(timestamp);
    const options = { 
      year: 'numeric', 
      month: '2-digit', 
      day: '2-digit', 
      hour: '2-digit', 
      minute: '2-digit', 
      hour12: true 
    };
    return date.toLocaleString('ko-KR', options);
};


  return (
    <div>
      <Logout />
      <h1>Admin Page</h1>
      <div className="tabs">
        <button onClick={() => handleTabChange(0)} className="tab-button">전체</button>
        <button onClick={() => handleTabChange(1)} className="tab-button">실패</button>
        <button onClick={() => handleTabChange(2)} className="tab-button">당일</button>
        <button onClick={() => handleTabChange(3)} className="tab-button">과거</button>
      </div>
      <div style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(6, 1fr)',
        gap: '10px',
      }}>
        {currentPageData.map((image, index) => (
          <div key={index} style={{maxWidth: '100%'}}>
            <img src={image.url} alt="" className="image-thumbnail" />
            <button onClick={() => openModal(
              <div>
                <button onClick={() => openConfirmationModal(image.metadata.id)} className="detail-button">미션 실패</button>
                <p>Mission Status: {image.metadata.missionStatus}</p> 
                <p>Mission Type: {image.metadata.missionType}</p>
                <p>Selected Time 1: {formatDate(image.metadata.selectedTime1)}</p>
                <p>Selected Time 2: {formatDate(image.metadata.selectedTime2)}</p>
                <p>Capture Time: {formatDate(image.metadata.captureTime)}</p>
                <p>ID: {image.metadata.id}</p>
              </div>
            )} className="detail-button">자세히</button>
          </div>
        ))}
      </div>
      <div>
        {/* Pagination */}
        <Pagination 
          totalPages={totalPages} 
          currentPage={page} 
          onPaginate={setPage} 
        />
      </div>
      <Modal isOpen={isModalOpen} onClose={closeModal} content={modalContent} />
    </div>
  );
};

export default Admin;