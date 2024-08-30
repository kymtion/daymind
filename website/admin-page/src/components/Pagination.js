import React from 'react';


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

export default Pagination;
