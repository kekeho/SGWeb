from django.urls import path

from rest_framework_jwt.views import obtain_jwt_token
from .views import UserRegister, AuthUserInfo, AuthUserUpdate, AuthUserDelete, UserGet

urlpatterns = [
    # Auth
    path('jwt-token/', obtain_jwt_token),
    path('register/', UserRegister.as_view()),
    path('auth-userinfo/', AuthUserInfo.as_view()),
    path('update/', AuthUserUpdate.as_view()),
    path('delete/', AuthUserDelete.as_view()),

    path('info/<str:username>', UserGet.as_view()),
]
