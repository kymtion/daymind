import React, { useEffect, useState } from 'react';
import { storage } from '../firebase';
import { listAll, ref, getDownloadURL, getMetadata } from "firebase/storage";
import Logout from './Logout';

const ITEMS_PER_PAGE = 50;

const Pagination = ({ totalPages, currentPage, onPaginate }) => {
  const startPage = Math.max(currentPage - 2, 1);
  const endPage = Math.min(startPage + 4, totalPages);

  return (
    <div style={{ display: 'flex', justifyContent: 'center', gap: '10px' }}>
      <button
        disabled={currentPage === 1}
        onClick={() => onPaginate(currentPage - 1)}
      >
        &lt;
      </button>
      {startPage > 1 && '...'}
      {Array.from({ length: endPage - startPage + 1 }, (_, i) => i + startPage).map(page => (
        <button
          key={page}
          style={{ color: currentPage === page ? 'red' : 'black' }}
          onClick={() => onPaginate(page)}
        >
          {page}
        </button>
      ))}
      {endPage < totalPages && '...'}
      <button
        disabled={currentPage === totalPages}
        onClick={() => onPaginate(currentPage + 1)}
      >
        &gt;
      </button>
    </div>
  );
};

const Modal = ({ isOpen, onClose, content }) => {
  if (!isOpen) return null;

  return (
    <div style={{
      position: 'fixed',
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      background: 'rgba(0, 0, 0, 0.7)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
    }}>
      <div style={{
        background: '#fff',
        borderRadius: '5px',
        padding: '20px',
      }}>
        {content}
        <button onClick={onClose}>Close</button>
      </div>
    </div>
  );
};

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
        return { url, metadata: metadata.customMetadata || {} };
      });

      const data = await Promise.all(dataPromises);
      data.sort((a, b) => new Date(b.metadata.selectedTime2).getTime() - new Date(a.metadata.selectedTime2).getTime());

      const today = new Date();
      today.setHours(0, 0, 0, 0);

      const yesterday = new Date(today);
      yesterday.setDate(yesterday.getDate() - 1);

      setTab1Data(data.filter(item => new Date(item.metadata.captureTime).getTime() > new Date(item.metadata.selectedTime2).getTime()));
      setTab2Data(data.filter(item => {
        const selectedTime2 = new Date(item.metadata.selectedTime2);
        selectedTime2.setHours(0, 0, 0, 0);
        return selectedTime2.getTime() === today.getTime();
      }));
      setTab3Data(data.filter(item => {
        const selectedTime2 = new Date(item.metadata.selectedTime2);
        selectedTime2.setHours(0, 0, 0, 0);
        return selectedTime2.getTime() < today.getTime();
      }));

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

  return (
    <div>
      <Logout />
      <h1>Admin Page</h1>
      <div className="tabs">
        <button onClick={() => handleTabChange(0)}>전체</button>
        <button onClick={() => handleTabChange(1)}>실패</button>
        <button onClick={() => handleTabChange(2)}>당일</button>
        <button onClick={() => handleTabChange(3)}>과거</button>
      </div>
      <div style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(7, 1fr)',
        gap: '10px',
      }}>
        {currentPageData.map((image, index) => (
          <div key={index} style={{maxWidth: '100%'}}>
            <img src={image.url} alt="" style={{ width: '100%', height: 'auto' }} />
            <button onClick={() => openModal(
              <div>
                <p>Mission Type: {image.metadata.missionType}</p>
                <p>Capture Time: {image.metadata.captureTime}</p>
                <p>Selected Time 1: {image.metadata.selectedTime1}</p>
                <p>ID: {image.metadata.id}</p>
                <p>Selected Time 2: {image.metadata.selectedTime2}</p>
              </div>
            )}>자세히</button>
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
