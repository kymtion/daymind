import React, { useState, useEffect } from 'react';
import { collection, getDocs } from 'firebase/firestore';
import { db } from '../firebase';
import MissionDetailModal from './MissionDetailModal';



const MissionList = () => {
  const [missions, setMissions] = useState([]);
  const [currentMission, setCurrentMission] = useState(null);
  const [search, setSearch] = useState('');
  const [searchField, setSearchField] = useState('missionType');
  const [startDate, setStartDate] = useState(null);
  const [endDate, setEndDate] = useState(null);
  const [timeField, setTimeField] = useState('selectedTime1');
  const [searchConditions, setSearchConditions] = useState({});

 

  useEffect(() => {
    const fetchData = async () => {
      const missionCollection = collection(db, 'missions');
      const missionSnapshot = await getDocs(missionCollection);
      const missionList = missionSnapshot.docs.map(doc => {
        const data = doc.data();
        return { ...data, id: doc.id }
      });
      setMissions(missionList);
    };

    fetchData();
  }, []);

  const showModal = (mission) => {
    setCurrentMission(mission);
  };

  const closeModal = () => {
    setCurrentMission(null);
  };

  const handleSearchChange = (e) => {
    setSearch(e.target.value);
  };

  const handleFieldChange = (e) => {
    setSearchField(e.target.value);
  };

 

  const convertTimestampToDate = (timestamp) => {
    const date = new Date(timestamp);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const weekday = ['일', '월', '화', '수', '목', '금', '토'][date.getDay()];
    
    return `${year}.${month}.${day} (${weekday}) ${hours}:${minutes}`;
  };
  
  const handleSearch = () => {
    setSearchConditions({ search, searchField, startDate, endDate, timeField });
  };

  const filteredMissions = missions.filter(mission => {
    // 검색 조건이 존재하지 않으면 필터링하지 않음
    if (Object.keys(searchConditions).length === 0) return false;

    // 검색 조건에 따라 필터링
    if (searchConditions.startDate && mission[searchConditions.timeField] < searchConditions.startDate) return false;
    if (searchConditions.endDate && mission[searchConditions.timeField] > searchConditions.endDate) return false;

    if (searchConditions.searchField === 'selectedTime1' || searchConditions.searchField === 'selectedTime2') {
      const dateString = convertTimestampToDate(mission[searchConditions.searchField]);
      return dateString.toLowerCase().includes(searchConditions.search.toLowerCase());
    } else {
      return mission[searchConditions.searchField] && mission[searchConditions.searchField].toString().toLowerCase().includes(searchConditions.search.toLowerCase());
    }
  });

  const totalDeposit = filteredMissions.reduce((sum, mission) => sum + mission.actualAmount, 0);
  
  const formattedTotalDeposit = totalDeposit.toLocaleString('ko-KR') + '원';
  

   return (
    <div>
      <h1>미션리스트</h1>
      <div style={{ textAlign: 'center', marginBottom: '10px', fontSize: '20px', fontWeight: 'bold' }}>
        총 예치금: {formattedTotalDeposit}
      </div>
      <div style={{ display: 'flex', justifyContent: 'center', flexWrap: 'wrap', marginBottom: '10px' }}>
        <div style={{ margin: '0 5px' }}>
          <label>시작 날짜:</label>
          <input type="date" style={{ margin: '0 10px', width: '160px' }} onChange={e => setStartDate(new Date(e.target.value).getTime())} />
        </div>
        <div style={{ margin: '0 5px' }}>
          <label>종료 날짜:</label>
          <input type="date" style={{ margin: '0 10px', width: '160px' }} onChange={e => setEndDate(new Date(e.target.value).getTime())} />
        </div>
        <div style={{ margin: '0 5px' }}>
          <label>기준 시간:</label>
          <select value={timeField} style={{ margin: '0 10px', width: '100px' }} onChange={e => setTimeField(e.target.value)}>
            <option value="selectedTime1">시작시간</option>
            <option value="selectedTime2">종료시간</option>
          </select>
        </div>
      </div>
      <div style={{ display: 'flex', justifyContent: 'center', flexWrap: 'wrap', marginBottom: '10px' }}>
        <select value={searchField} style={{ width: '100px' }} onChange={handleFieldChange}>
          <option value="missionType">미션 타입</option>
          <option value="missionStatus">미션 상태</option>
          <option value="userId">사용자UID</option>
          <option value="selectedTime1">시작시간</option>
          <option value="selectedTime2">종료시간</option>
          {/* 필요한 필드를 여기에 추가하세요 */}
        </select>
        <input type="text" value={search} onChange={handleSearchChange} placeholder="검색..." />
        <button onClick={handleSearch}>검색</button>
      </div>
      <div style={{ width: '50%', margin: 'auto' }}>
        <table style={{ borderCollapse: 'collapse', width: '100%' }}>
          <thead>
            <tr>
              <th style={{ border: '1px solid black', padding: '10px' }}>번호</th>
              <th style={{ border: '1px solid black', padding: '10px' }}>예치금</th>
              <th style={{ border: '1px solid black', padding: '10px' }}>미션상태</th>
              <th style={{ border: '1px solid black', padding: '10px' }}>미션타입</th>
              <th style={{ border: '1px solid black', padding: '10px' }}>시작시간</th>
              <th style={{ border: '1px solid black', padding: '10px' }}>종료시간</th>
              <th style={{ border: '1px solid black', padding: '10px' }}>사용자UID</th>
              <th style={{ border: '1px solid black', padding: '10px' }}>상세 정보</th>
            </tr>
          </thead>
          <tbody>
            {filteredMissions.map((mission, index) => (
              <tr key={index}>
                <td style={{ border: '1px solid black', padding: '10px' }}>{index + 1}</td>
                <td style={{ border: '1px solid black', padding: '10px' }}>{mission.actualAmount}</td>
                <td style={{ border: '1px solid black', padding: '10px' }}>{mission.missionStatus}</td>
                <td style={{ border: '1px solid black', padding: '10px' }}>{mission.missionType}</td>
                <td style={{ border: '1px solid black', padding: '10px' }}>{convertTimestampToDate(mission.selectedTime1)}</td>
                <td style={{ border: '1px solid black', padding: '10px' }}>{convertTimestampToDate(mission.selectedTime2)}</td>
                <td style={{ border: '1px solid black', padding: '10px' }}>{mission.userId}</td>
                <td style={{ border: '1px solid black', padding: '10px' }}>
                  <button onClick={() => showModal(mission)}>자세히</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      {currentMission && <MissionDetailModal mission={currentMission} closeModal={closeModal} />}
    </div>
  );
};

export default MissionList;