from django.db import models

# Create your models here.

class Sample(models.Model):
    attachement = models.FileField()