import React from 'react';

const MissionDetailModal = ({ mission, closeModal }) => {
    return (
      <div style={{
        position: 'fixed', /* Fixed/sticky position */
        zIndex: 1, /* Sit on top */
        paddingTop: 100, /* Location of the box */
        left: 0,
        top: 0,
        width: '100%', /* Full width */
        height: '100%', /* Full height */
        overflow: 'auto', /* Enable scroll if needed */
        backgroundColor: 'rgba(0,0,0,0.4)', /* Black w/ opacity */
      }}>
        <div style={{
          backgroundColor: '#fefefe',
          margin: 'auto',
          padding: 20,
          border: '1px solid #888',
          width: '40%',
          textAlign: 'center',
        }}>
            <h2>미션 상세 정보</h2>
            <div style={{textAlign: 'left'}}>
          <p>예치금: {mission.actualAmount}</p>
          <p>상태: {mission.missionStatus}</p>
          <p>미션: {mission.missionType}</p>
          <p>시작시간: {mission.selectedTime1}</p>
          <p>종료시간: {mission.selectedTime2}</p>
          <p>사용자UID: {mission.userId}</p>
          <p>ID: {mission.id}</p>
          </div>
          <button onClick={closeModal}>닫기</button>
        </div>
      </div>
    );
  };
  

export default MissionDetailModal;
