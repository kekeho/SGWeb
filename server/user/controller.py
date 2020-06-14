from fastapi.security import OAuth2PasswordBearer
from fastapi import HTTPException, Depends
from starlette.status import HTTP_401_UNAUTHORIZED, HTTP_400_BAD_REQUEST
from datetime import timedelta, datetime
from sqlalchemy.exc import IntegrityError
import jwt
from jwt import PyJWTError
import os
import hashlib
import db.db as db
from . import models


JWT_PASSWORD = os.environ.get('JWT_PASSWORD')
ALGORITHM = 'HS512'
TOKEN_EXPIRE_MIN = 60*24*1  # 1 day


oauth2_scheme = OAuth2PasswordBearer(tokenUrl='/user/get_token')


def search_user_for_token(m: models.GetTokenModel) -> models.User:
    """
    Searching for a user when issuing a token
    """
    session = db.Session()
    hashed_password = hashlib.sha512(m.password.encode()).hexdigest()
    user = session.query(models.User).filter(models.User.username == m.username).filter(
        models.User.password == hashed_password
    ).first()
    session.close()

    return user


def create_access_token(data: dict, expires_delta):
    to_encode = data.copy()
    expire = datetime.utcnow() + expires_delta
    to_encode['exp'] = expire.timestamp()
    encode_jwt = jwt.encode(
        payload=to_encode, key=JWT_PASSWORD, algorithm=ALGORITHM
    )

    return encode_jwt


def get_user_data(token: str = Depends(oauth2_scheme)) -> models.TokenData:
    """
    Search user with token
    """

    credentials_exc = HTTPException(
        status_code=HTTP_401_UNAUTHORIZED,
        detail="Wrong token",
        headers={'WWW-Authenticate': 'Bearer'}
    )

    try:
        payload = jwt.decode(token, JWT_PASSWORD, algorithms=[ALGORITHM])
        username: str = payload.get('username')
        if username is None:
            raise credentials_exc

        token_data = models.TokenData(username=username)
    except PyJWTError:
        raise credentials_exc

    return token_data


async def regist_user(m: models.RegistUserModel) -> models.GetTokenResponseModel:
    """
    Regist user & return token
    """
    # Regist to DB
    try:
        session = db.Session()
        new_user = models.User(
            username=m.username,
            password=m.password,
            email=m.email,
        )
        session.add(new_user)
        session.commit()
        session.close()
    except IntegrityError:
        raise HTTPException(
            status_code=HTTP_400_BAD_REQUEST,
            detail='Duplicate username',
        )

    # Issue access token
    token = create_access_token(
        {'username': m.username}, timedelta(minutes=TOKEN_EXPIRE_MIN))
    return {'token': token, 'token_type': 'bearer'}


async def get_token(m: models.GetTokenModel) -> models.GetTokenResponseModel:
    user = search_user_for_token(m)
    print(user)

    if not user:
        raise HTTPException(
            status_code=HTTP_401_UNAUTHORIZED,
            detail='Wrong username or password.',
            headers={'WWW-Authenticate': 'Bearer'},
        )

    # Issue token
    token_expires = timedelta(minutes=TOKEN_EXPIRE_MIN)
    access_token = create_access_token(
        data={'username': m.username}, expires_delta=token_expires)

    return {'token': access_token, 'token_type': 'bearer'}


async def get_user(m: models.GetUserModel) -> models.TokenData:
    return get_user_data(m.token)
