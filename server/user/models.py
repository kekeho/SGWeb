from datetime import datetime
import db.db as db
from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.sql.functions import current_timestamp
from sqlalchemy.dialects.postgresql import INTEGER, BOOLEAN
from pydantic import BaseModel

import hashlib

Base = db.Base


class User(Base):
    """
    User Table

    id : ID
    username : Username
    password : Password
    email : E-mail Address
    date_registered : Account Registration Date
    """
    __tablename__ = 'user'
    id = Column(
        'id',
        INTEGER(),
        primary_key=True,
        autoincrement=True,
    )
    username = Column('username', String(140), nullable=False, unique=True)
    password = Column('password', String(128), nullable=False)
    email = Column('email', String(140))
    date_registered = Column('date_registered', DateTime,
                             default=datetime.now(), nullable=False)

    def __init__(self, username, password, email):
        self.username = username
        self.password = hashlib.sha512(password.encode()).hexdigest()
        self.email = email

    def __str__(self):
        return f'{self.id} : {self.username}'


class RegistUserModel(BaseModel):
    """
    /regist param
    """
    username: str
    password: str
    email: str


class GetTokenModel(BaseModel):
    """
    /get_token param
    """
    username: str
    password: str


class GetTokenResponseModel(BaseModel):
    """
    /get_token return model
    """
    token: str
    token_type: str = 'bearer'


class GetUserModel(BaseModel):
    """
    /get_user param
    """
    token: str


class TokenData(BaseModel):
    """
    /get_user return model
    """
    username: str
