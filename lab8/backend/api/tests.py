from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework import status
from .models import HealthProgram, Client, Enrollment
import json
from datetime import date


class HealthProgramTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.program_data = {
            'name': 'HIV Testing',
            'description': 'Free HIV testing program'
        }
        self.program = HealthProgram.objects.create(
            name='TB Prevention', 
            description='Tuberculosis prevention program'
        )
    
    def test_create_program(self):
        """Test creating a new health program"""
        url = reverse('healthprogram-list')
        response = self.client.post(
            url, 
            self.program_data, 
            format='json'
        )
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(HealthProgram.objects.count(), 2)
        self.assertEqual(HealthProgram.objects.filter(name='HIV Testing').count(), 1)

    def test_get_program_list(self):
        """Test retrieving a list of health programs"""
        url = reverse('healthprogram-list')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)


class ClientTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.program = HealthProgram.objects.create(
            name='Malaria Prevention',
            description='Malaria prevention program'
        )
        
        self.test_client = Client.objects.create(
            first_name='John',
            last_name='Doe',
            date_of_birth='1990-01-01',
            gender='M',
            phone_number='123456789',
            email='john@example.com'
        )
        
        self.client_data = {
            'first_name': 'Jane',
            'last_name': 'Smith',
            'date_of_birth': '1985-05-15',
            'gender': 'F',
            'phone_number': '987654321',
            'email': 'jane@example.com'
        }
    
    def test_create_client(self):
        """Test creating a new client"""
        url = reverse('client-list')
        response = self.client.post(
            url, 
            self.client_data, 
            format='json'
        )
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Client.objects.count(), 2)
        
    def test_search_client(self):
        """Test searching for a client"""
        url = reverse('client-search')
        response = self.client.get(f"{url}?query=John")
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]['first_name'], 'John')
        
    def test_enroll_client(self):
        """Test enrolling a client in a program"""
        url = reverse('client-enroll', args=[self.test_client.id])
        enrollment_data = {
            'client_id': self.test_client.id,
            'program_id': self.program.id,
            'notes': 'Test enrollment'
        }
        
        response = self.client.post(
            url, 
            enrollment_data, 
            format='json'
        )
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Enrollment.objects.count(), 1)
        
    def test_get_client_with_enrollments(self):
        """Test retrieving a client with their program enrollments"""
        # First enroll the client
        enrollment = Enrollment.objects.create(
            client=self.test_client,
            program=self.program,
            notes='Test enrollment'
        )
        
        url = reverse('client-detail', args=[self.test_client.id])
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['first_name'], 'John')
        self.assertEqual(len(response.data['enrollments']), 1)
        self.assertEqual(response.data['enrollments'][0]['program_name'], 'Malaria Prevention') 