from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from .models import HealthProgram, Client, Enrollment
from .serializers import (
    HealthProgramSerializer, 
    ClientSerializer, 
    ClientDetailSerializer, 
    EnrollmentSerializer,
    ClientEnrollmentSerializer
)


class HealthProgramViewSet(viewsets.ModelViewSet):
    queryset = HealthProgram.objects.all()
    serializer_class = HealthProgramSerializer


class ClientViewSet(viewsets.ModelViewSet):
    queryset = Client.objects.all()
    serializer_class = ClientSerializer
    
    def get_serializer_class(self):
        if self.action == 'retrieve':
            return ClientDetailSerializer
        return ClientSerializer
    
    @action(detail=False, methods=['get'])
    def search(self, request):
        query = request.query_params.get('query', '')
        if not query:
            return Response({'error': 'Query parameter is required'}, status=status.HTTP_400_BAD_REQUEST)
        
        clients = Client.objects.filter(
            first_name__icontains=query
        ) | Client.objects.filter(
            last_name__icontains=query
        )
        
        serializer = self.get_serializer(clients, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def enroll(self, request, pk=None):
        client = self.get_object()
        serializer = ClientEnrollmentSerializer(data=request.data)
        
        if serializer.is_valid():
            program_id = serializer.validated_data['program_id']
            notes = serializer.validated_data.get('notes', '')
            
            program = get_object_or_404(HealthProgram, id=program_id)
            
            # Check if enrollment already exists
            enrollment, created = Enrollment.objects.get_or_create(
                client=client,
                program=program,
                defaults={'notes': notes}
            )
            
            if not created:
                return Response(
                    {'error': 'Client is already enrolled in this program'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            return Response(
                EnrollmentSerializer(enrollment).data,
                status=status.HTTP_201_CREATED
            )
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=True, methods=['get'])
    def enrollments(self, request, pk=None):
        client = self.get_object()
        enrollments = client.enrollment_set.all()
        serializer = EnrollmentSerializer(enrollments, many=True)
        return Response(serializer.data) 