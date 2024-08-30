import React from 'react';
import '../App.css';

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
          <button onClick={onClose} className="detail-button">닫기</button>
        </div>
      </div>
    );
  };

  export default Modal;