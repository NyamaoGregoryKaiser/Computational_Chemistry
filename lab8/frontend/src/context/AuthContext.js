import React, { createContext, useState, useContext, useEffect } from 'react';
import axios from 'axios';
import { jwtDecode } from 'jwt-decode';

const AuthContext = createContext();

export const useAuth = () => useContext(AuthContext);

export const AuthProvider = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [token, setToken] = useState(localStorage.getItem('accessToken') || null);
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const initAuth = async () => {
      const accessToken = localStorage.getItem('accessToken');
      
      if (accessToken) {
        try {
          // Decode token to get user info
          const decoded = jwtDecode(accessToken);
          
          // Check if token is expired
          const currentTime = Date.now() / 1000;
          if (decoded.exp < currentTime) {
            // Token is expired, try to refresh
            await refreshToken();
          } else {
            // Token is valid
            setIsAuthenticated(true);
            setUser({
              id: decoded.user_id,
              email: decoded.email,
              name: decoded.name,
              isDoctor: decoded.is_doctor
            });
            setToken(accessToken);
            
            // Set axios authorization header
            axios.defaults.headers.common['Authorization'] = `Bearer ${accessToken}`;
          }
        } catch (error) {
          console.error('Error initializing auth:', error);
          logout();
        }
      }
      
      setLoading(false);
    };
    
    initAuth();
  }, []);

  const login = async (email, password) => {
    try {
      const response = await axios.post('/auth/token/', { email, password });
      const { access, refresh } = response.data;
      
      localStorage.setItem('accessToken', access);
      localStorage.setItem('refreshToken', refresh);
      
      const decoded = jwtDecode(access);
      
      setIsAuthenticated(true);
      setToken(access);
      setUser({
        id: decoded.user_id,
        email: decoded.email,
        name: decoded.name,
        isDoctor: decoded.is_doctor
      });
      
      axios.defaults.headers.common['Authorization'] = `Bearer ${access}`;
      
      return true;
    } catch (error) {
      console.error('Login error:', error);
      return false;
    }
  };

  const register = async (userData) => {
    try {
      await axios.post('/auth/register/', userData);
      return true;
    } catch (error) {
      console.error('Registration error:', error);
      return false;
    }
  };

  const logout = () => {
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
    setIsAuthenticated(false);
    setToken(null);
    setUser(null);
    delete axios.defaults.headers.common['Authorization'];
  };

  const refreshToken = async () => {
    const refreshToken = localStorage.getItem('refreshToken');
    
    if (!refreshToken) {
      logout();
      return false;
    }
    
    try {
      const response = await axios.post('/auth/token/refresh/', {
        refresh: refreshToken
      });
      
      const { access } = response.data;
      localStorage.setItem('accessToken', access);
      
      const decoded = jwtDecode(access);
      
      setIsAuthenticated(true);
      setToken(access);
      setUser({
        id: decoded.user_id,
        email: decoded.email,
        name: decoded.name,
        isDoctor: decoded.is_doctor
      });
      
      axios.defaults.headers.common['Authorization'] = `Bearer ${access}`;
      
      return true;
    } catch (error) {
      console.error('Token refresh error:', error);
      logout();
      return false;
    }
  };

  const value = {
    isAuthenticated,
    token,
    user,
    loading,
    login,
    register,
    logout,
    refreshToken
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}; 