from django.shortcuts import render, Http404
from rest_framework import generics, permissions
from rest_framework.response import Response
from rest_framework import status
from django.db import transaction

from .models import User
from .serializer import UserSerializer

# Regist user (POST)
class UserRegister(generics.CreateAPIView):
    permission_classes = (permissions.AllowAny,)
    queryset = User.objects.all()
    serializer_class = UserSerializer

    @transaction.atomic
    def post(self, request, format=None):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# Get authenticated user info (GET)
class AuthUserInfo(generics.RetrieveAPIView):
    permission_classes = (permissions.IsAuthenticated, permissions.IsAdminUser)
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def get(self, request, format=None):
        return Response(
            data={
                'username': request.user.username,
                'email': request.user.email,

                'display_name': request.user.display_name,
                'first_name': request.user.first_name,
                'last_name': request.user.last_name,

                'profile': request.user.profile,
            },
            status=status.HTTP_200_OK
        )


# Update user info (PATCH)
class AuthUserUpdate(generics.UpdateAPIView):
    permission_classes = (permissions.IsAuthenticated, permissions.IsAdminUser)
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def get_object(self):
        try:
            instance = self.queryset.get(id=self.request.user.id)
            return instance
        
        except User.DoesNotExist:
            raise Http404



# Delete user (DELETE)
class AuthUserDelete(generics.DestroyAPIView):
    permission_classes = (permissions.IsAuthenticated, permissions.IsAdminUser)
    serializer_class = UserSerializer
    queryset = User.objects.all()

    def get_object(self):
        try:
            instance = self.queryset.get(id=self.request.user.id)
            return instance
        except User.DoesNotExist:
            raise Http404
