from rest_framework import serializers
from .models import HealthProgram, Client, Enrollment


class HealthProgramSerializer(serializers.ModelSerializer):
    class Meta:
        model = HealthProgram
        fields = '__all__'


class EnrollmentSerializer(serializers.ModelSerializer):
    program_name = serializers.ReadOnlyField(source='program.name')
    
    class Meta:
        model = Enrollment
        fields = ['id', 'program', 'program_name', 'enrollment_date', 'notes']


class ClientSerializer(serializers.ModelSerializer):
    class Meta:
        model = Client
        fields = '__all__'


class ClientDetailSerializer(serializers.ModelSerializer):
    enrollments = EnrollmentSerializer(source='enrollment_set', many=True, read_only=True)
    
    class Meta:
        model = Client
        fields = ['id', 'first_name', 'last_name', 'date_of_birth', 'gender', 
                  'phone_number', 'email', 'address', 'registration_date', 'enrollments']


class ClientEnrollmentSerializer(serializers.Serializer):
    client_id = serializers.IntegerField()
    program_id = serializers.IntegerField()
    notes = serializers.CharField(required=False, allow_blank=True) 