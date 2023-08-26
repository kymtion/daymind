import React, { useState } from 'react';
import { collection, getDocs, query, where } from 'firebase/firestore';
import { db } from '../firebase';

const UserSearch = () => {
  const [searchValue, setSearchValue] = useState('');
  const [missions, setMissions] = useState([]);
  const [transactions, setTransactions] = useState([]);
  const [user, setUser] = useState(null);
  const [failedFines, setFailedFines] = useState(0);
  const [successfulRefunds, setSuccessfulRefunds] = useState(0);
  const [totalDeposit, setTotalDeposit] = useState(0);
  const [totalWithdrawal, setTotalWithdrawal] = useState(0); 



  const handleSearch = async () => {
    // userId로 검색
    let userSnapshot = await getDocs(query(collection(db, 'users'), where('userId', '==', searchValue)));
  
    if (userSnapshot.empty) {
      // userId로 찾지 못했다면 nickname으로 검색
      userSnapshot = await getDocs(query(collection(db, 'users'), where('nickname', '==', searchValue)));
    }
  
    const foundUser = userSnapshot.docs.map(doc => doc.data())[0];
    setUser(foundUser);

    if (foundUser) {
      const userId = foundUser.userId;
      const missionSnapshot = await getDocs(query(collection(db, 'missions'), where('userId', '==', userId)));
      const transactionSnapshot = await getDocs(query(collection(db, 'transactions'), where('userId', '==', userId)));
  
      const missionData = missionSnapshot.docs.map(doc => doc.data());
      const transactionData = transactionSnapshot.docs.map(doc => doc.data());
  
      setMissions(missionData);
      setTransactions(transactionData);
  
      const failedFines = missionData.reduce((sum, mission) => {
        if (mission.missionStatus === '실패') {
          return sum + mission.actualAmount;
        }
        return sum;
      }, 0);
  
      const successfulRefunds = missionData.reduce((sum, mission) => {
        if (mission.missionStatus === '성공') {
          return sum + mission.actualAmount;
        }
        return sum;
      }, 0);
  
      // 결과 저장
      setFailedFines(failedFines);
      setSuccessfulRefunds(successfulRefunds);

      const totalDepositAmount = transactionData.reduce((sum, transaction) => {
        if (transaction.type === 'deposit') {
          return sum + transaction.amount;
        }
        return sum;
      }, 0);

      const totalWithdrawalAmount = transactionData.reduce((sum, transaction) => {
        if (transaction.type === 'withdrawal') {
          return sum + transaction.amount;
        }
        return sum;
      }, 0);

      // 결과 저장
      setTotalDeposit(totalDepositAmount);
      setTotalWithdrawal(totalWithdrawalAmount);

      // 미션 데이터와 거래 데이터를 시간 기준으로 내림차순 정렬
      const sortedMissions = missionData.sort((a, b) => new Date(b.selectedTime2) - new Date(a.selectedTime2));
      const sortedTransactions = transactionData.sort((a, b) => new Date(b.date) - new Date(a.date));

      setMissions(sortedMissions);
      setTransactions(sortedTransactions);

    }
  };
  

  return (
    <div>
      <h1>유저검색</h1>
      <div>
        <input type="text" value={searchValue} onChange={e => setSearchValue(e.target.value)} placeholder="닉네임 또는 아이디 검색" />
        <button onClick={handleSearch}>검색</button>
      </div>
      {user && (
        <div style={{ width: '100%', textAlign: 'center' }}>
          <h2>사용자 정보</h2>
          <table style={{ borderCollapse: 'collapse', width: '30%', margin: '0 auto' }}>
            <thead>
             <tr style={{ fontWeight: 'bold' }}>
                <td>UID</td>
                <td>닉네임</td>
                <td>잔액</td>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>{user.userId}</td>
                <td>{user.nickname}</td>
                <td>{user.balance}원</td>
              </tr>
            </tbody>
          </table>
        </div>
      )}
      <div style={{ display: 'flex', justifyContent: 'space-around' }}>
      <div style={{ width: '45%' }}>
        <h2>환급 및 벌금 내역</h2>
        <table style={{ borderCollapse: 'collapse', width: '100%', textAlign: 'center' }}>
          <tbody>
            <tr>
              <td style={{ fontWeight: 'bold', border: '1px solid black' }}>벌금 총액:</td>
              <td style={{ border: '1px solid black' }}>{failedFines}원</td>
              <td style={{ fontWeight: 'bold', border: '1px solid black' }}>총 환급 금액:</td>
              <td style={{ border: '1px solid black' }}>{successfulRefunds}원</td>
            </tr>
          </tbody>
        </table>
          <table style={{ borderCollapse: 'collapse', width: '100%' }}>
            <thead>
              <tr>
                <th>번호</th>
                <th>시작 시간</th>
                <th>종료 시간</th>
                <th>미션 타입</th>
                <th>미션 상태</th>
                <th>예치금</th>
              </tr>
            </thead>
            <tbody>
              {missions.map((mission, index) => (
                <tr key={index}>
                  <td>{index + 1}</td>
                  <td>{new Date(mission.selectedTime1).toLocaleString()}</td>
                  <td>{new Date(mission.selectedTime2).toLocaleString()}</td>
                  <td>{mission.missionType}</td>
                  <td>{mission.missionStatus}</td>
                  <td>{mission.actualAmount}원</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div style={{ width: '45%' }}>
          <h2>충전 및 출금 현황</h2>
          <table style={{ borderCollapse: 'collapse', width: '100%', textAlign: 'center' }}>
          <tbody>
            <tr>
              <td style={{ fontWeight: 'bold', border: '1px solid black' }}>총 충전 금액:</td>
              <td style={{ border: '1px solid black' }}>{totalDeposit}원</td>
              <td style={{ fontWeight: 'bold', border: '1px solid black' }}>총 출금 금액:</td>
              <td style={{ border: '1px solid black' }}>{totalWithdrawal}원</td>
            </tr>
          </tbody>
        </table>
          <table style={{ borderCollapse: 'collapse', width: '100%' }}>
            <thead>
              <tr>
                <th>번호</th>
                <th>거래 타입</th>
                <th>금액</th>
                <th>날짜</th>
              </tr>
            </thead>
            <tbody>
              {transactions.map((transaction, index) => (
                <tr key={index}>
                  <td>{index + 1}</td>
                  <td>{transaction.type}</td>
                  <td>{transaction.amount}원</td>
                  <td>{new Date(transaction.date).toLocaleString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
  
};

export default UserSearch;
