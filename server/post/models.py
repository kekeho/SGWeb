from django.db import models
import uuid
from user.models import User


class Tag(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4(),
                          null=False, blank=False, unique=True)
    name = models.CharField(max_length=140, blank=False, null=False, unique=True)


class Post(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4(),
                          null=False, blank=False, unique=True)
    author = models.ForeignKey(User, null=False, on_delete=models.CASCADE)

    content = models.TextField()
    tags = models.ManyToManyField(Tag)
    like = models.IntegerField(null=False, default=0)

    date_published = models.DateTimeField(auto_now=True)

    executed = models.BooleanField(default=False, null=False)
    result_stdout = models.TextField(null=True, blank=True)
    result_stderr = models.TextField(null=True, blank=True)
    result_image = models.ImageField(null=True)
