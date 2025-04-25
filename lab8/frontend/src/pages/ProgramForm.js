import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import axios from 'axios';

const ProgramForm = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const isEditing = !!id;

  const [formData, setFormData] = useState({
    name: '',
    description: ''
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const { name, description } = formData;

  useEffect(() => {
    if (isEditing) {
      const fetchProgram = async () => {
        try {
          setLoading(true);
          const res = await axios.get(`/api/programs/${id}/`);
          const { name, description } = res.data;
          setFormData({ name, description });
          setLoading(false);
        } catch (err) {
          setError('Failed to fetch program');
          setLoading(false);
        }
      };

      fetchProgram();
    }
  }, [id, isEditing]);

  const onChange = e => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const onSubmit = async e => {
    e.preventDefault();
    
    if (!name || !description) {
      setError('Please fill all fields');
      return;
    }

    try {
      setLoading(true);
      
      if (isEditing) {
        await axios.put(`/api/programs/${id}/`, formData);
      } else {
        await axios.post('/api/programs/', formData);
      }
      
      setLoading(false);
      navigate('/programs');
    } catch (err) {
      setError('Failed to save program');
      setLoading(false);
    }
  };

  if (loading && isEditing) {
    return <div className="loading">Loading...</div>;
  }

  return (
    <div className="page-container">
      <div className="page-header">
        <h1>{isEditing ? 'Edit' : 'Add'} Health Program</h1>
      </div>

      {error && <div className="alert alert-danger">{error}</div>}

      <div className="card">
        <div className="card-body">
          <form onSubmit={onSubmit}>
            <div className="form-group">
              <label htmlFor="name">Program Name</label>
              <input
                type="text"
                id="name"
                name="name"
                className="form-control"
                value={name}
                onChange={onChange}
                required
              />
            </div>
            <div className="form-group">
              <label htmlFor="description">Description</label>
              <textarea
                id="description"
                name="description"
                className="form-control"
                value={description}
                onChange={onChange}
                rows="4"
                required
              ></textarea>
            </div>
            <div className="form-buttons">
              <button type="submit" className="btn btn-primary" disabled={loading}>
                {loading ? 'Saving...' : 'Save Program'}
              </button>
              <button
                type="button"
                className="btn btn-secondary"
                onClick={() => navigate('/programs')}
              >
                Cancel
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default ProgramForm; 