from . import controller
from . import models

path_list = [
    (['POST'], 'get_token/', controller.get_token, models.GetTokenResponseModel),
    (['POST'], 'get_user/', controller.get_user, models.TokenData),
    (['POST'], 'regist/', controller.regist_user, models.GetTokenResponseModel),
]
