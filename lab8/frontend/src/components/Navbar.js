import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const Navbar = () => {
  const { isAuthenticated, logout, user } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <nav className="navbar">
      <div className="navbar-brand">
        <Link to="/" className="navbar-logo">Health Information System</Link>
      </div>
      <div className="navbar-menu">
        {isAuthenticated ? (
          <>
            <div className="navbar-user">
              Welcome, {user?.name || 'Doctor'}
            </div>
            <Link to="/programs" className="navbar-item">Programs</Link>
            <Link to="/clients" className="navbar-item">Clients</Link>
            <button onClick={handleLogout} className="btn btn-logout">Logout</button>
          </>
        ) : (
          <>
            <Link to="/login" className="navbar-item">Login</Link>
            <Link to="/register" className="navbar-item">Register</Link>
          </>
        )}
      </div>
    </nav>
  );
};

export default Navbar; 