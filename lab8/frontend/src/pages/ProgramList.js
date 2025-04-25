import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';

const ProgramList = () => {
  const [programs, setPrograms] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchPrograms = async () => {
      try {
        const res = await axios.get('/api/programs/');
        setPrograms(res.data);
        setLoading(false);
      } catch (err) {
        setError('Failed to fetch programs');
        setLoading(false);
      }
    };

    fetchPrograms();
  }, []);

  if (loading) {
    return <div className="loading">Loading...</div>;
  }

  return (
    <div className="page-container">
      <div className="page-header">
        <h1>Health Programs</h1>
        <Link to="/programs/new" className="btn btn-primary">
          Add New Program
        </Link>
      </div>

      {error && <div className="alert alert-danger">{error}</div>}

      <div className="program-list">
        {programs.length === 0 ? (
          <div className="alert alert-info">No programs found</div>
        ) : (
          programs.map(program => (
            <div key={program.id} className="card">
              <div className="card-body">
                <h3 className="card-title">{program.name}</h3>
                <p className="card-text">{program.description}</p>
                <div className="card-actions">
                  <Link to={`/programs/${program.id}`} className="btn">
                    View Details
                  </Link>
                  <Link to={`/programs/${program.id}/edit`} className="btn">
                    Edit
                  </Link>
                </div>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
};

export default ProgramList; 