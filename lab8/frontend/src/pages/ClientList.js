import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';

const ClientList = () => {
  const [clients, setClients] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    const fetchClients = async () => {
      try {
        const res = await axios.get('/api/clients/');
        setClients(res.data);
        setLoading(false);
      } catch (err) {
        setError('Failed to fetch clients');
        setLoading(false);
      }
    };

    fetchClients();
  }, []);

  const handleSearch = async () => {
    if (!searchQuery.trim()) {
      return;
    }
    
    try {
      setLoading(true);
      const res = await axios.get(`/api/clients/search/?query=${searchQuery}`);
      setClients(res.data);
      setLoading(false);
    } catch (err) {
      setError('Search failed');
      setLoading(false);
    }
  };

  const handleReset = async () => {
    setSearchQuery('');
    try {
      setLoading(true);
      const res = await axios.get('/api/clients/');
      setClients(res.data);
      setLoading(false);
    } catch (err) {
      setError('Failed to reset search');
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="loading">Loading...</div>;
  }

  return (
    <div className="page-container">
      <div className="page-header">
        <h1>Clients</h1>
        <Link to="/clients/new" className="btn btn-primary">
          Register New Client
        </Link>
      </div>

      {error && <div className="alert alert-danger">{error}</div>}

      <div className="search-container">
        <div className="search-form">
          <input
            type="text"
            className="form-control"
            placeholder="Search by name..."
            value={searchQuery}
            onChange={e => setSearchQuery(e.target.value)}
            onKeyPress={e => e.key === 'Enter' && handleSearch()}
          />
          <button className="btn btn-primary" onClick={handleSearch}>
            Search
          </button>
          <button className="btn btn-secondary" onClick={handleReset}>
            Reset
          </button>
        </div>
      </div>

      <div className="client-list">
        {clients.length === 0 ? (
          <div className="alert alert-info">No clients found</div>
        ) : (
          clients.map(client => (
            <div key={client.id} className="card">
              <div className="card-body">
                <h3 className="card-title">{client.first_name} {client.last_name}</h3>
                <div className="client-info">
                  <p><strong>Gender:</strong> {client.gender === 'M' ? 'Male' : client.gender === 'F' ? 'Female' : 'Other'}</p>
                  <p><strong>Email:</strong> {client.email || 'N/A'}</p>
                  <p><strong>Phone:</strong> {client.phone_number || 'N/A'}</p>
                  <p><strong>Registered:</strong> {new Date(client.registration_date).toLocaleDateString()}</p>
                </div>
                <div className="card-actions">
                  <Link to={`/clients/${client.id}`} className="btn">
                    View Profile
                  </Link>
                  <Link to={`/clients/${client.id}/edit`} className="btn">
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

export default ClientList; 