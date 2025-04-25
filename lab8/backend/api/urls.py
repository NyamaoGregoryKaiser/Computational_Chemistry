from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import HealthProgramViewSet, ClientViewSet

router = DefaultRouter()
router.register(r'programs', HealthProgramViewSet)
router.register(r'clients', ClientViewSet)

urlpatterns = [
    path('', include(router.urls)),
] 