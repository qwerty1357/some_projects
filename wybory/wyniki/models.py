from django.contrib.auth.models import User

from django.db import models

from django.db import transaction

from django.core.exceptions import ValidationError

from django.db.models import Sum

from django.db.models.functions import Coalesce

from datetime import datetime



class Wojewodztwo(models.Model):
    nazwa = models.CharField(max_length=100, unique=True)

    def __str__(self):
        return self.nazwa

    class Meta:
        verbose_name_plural = 'wojewodztwa'



class Gmina(models.Model):
    MIASTO = 'miasto'
    WIES = 'wies'
    STATKI = 'statek'
    ZAGRANICA = 'zagranica'
    RODZAJ_CHOICES = (
        (MIASTO, 'miasto'),
        (WIES, 'wies'),
        (STATKI, 'statek'),
        (ZAGRANICA, 'zagranica'),
    )
    nazwa = models.CharField(max_length=100, unique=True)
    wojewodztwo = models.ForeignKey(Wojewodztwo)
    rodzaj = models.CharField(choices=RODZAJ_CHOICES, max_length=15)
    liczba_mieszkancow = models.IntegerField()
    liczba_uprawnionych = models.IntegerField()
    liczba_wydanych_kart = models.IntegerField()
    liczba_glosow_oddanych = models.IntegerField()
    data_modyfikacji = models.DateTimeField(blank=True)
    uzytkownik_modyfikujacy = models.ForeignKey(User)

    def __str__(self):
        return self.nazwa

    class Meta:
        verbose_name_plural = 'gminy'


    def clean(self, *args, **kwargs):
        if self.liczba_mieszkancow is not None and self.liczba_uprawnionych is not None:
            if self.liczba_mieszkancow < self.liczba_uprawnionych:
                raise ValidationError("Liczba uprawnionych do glosowanie nie moze byc wieksza niz liczba mieszkancow w gminie.")
        if self.liczba_uprawnionych is not None and self.liczba_wydanych_kart is not None:
            if self.liczba_uprawnionych < self.liczba_wydanych_kart:
                raise ValidationError("Liczba wydanych kart nie moze byc wieksza niz liczba uprawnionych do glosowania w gminie.")
        if self.liczba_wydanych_kart is not None and self.liczba_glosow_oddanych is not None:
            if self.liczba_wydanych_kart < self.liczba_glosow_oddanych:
                raise ValidationError("Liczba glosow oddanych nie moze byc wieksza niz liczba wydanych kart w gminie.")

        wyniki = Wyniki.objects.filter(gmina__nazwa=self.nazwa)
        suma = 0
        for w in wyniki:
            suma += w.liczba_glosow
        if (suma > self.liczba_glosow_oddanych):
            raise ValidationError("Nie można zmienić liczby głosów, bo suma głosów oddanych na kandydatów jest większa.")




class Kandydat(models.Model):
    nazwa = models.CharField(max_length=100)

    def __str__(self):
        return self.nazwa

    class Meta:
        verbose_name_plural = 'kandydat'


    def clean(self, *args, **kwargs):
        if Kandydat.objects.count() < 2 or self.pk is not None:
          super(Kandydat, self).save(*args, **kwargs)
        else:
          raise ValidationError('Kandydatow moze byc jedynie dwoch.')



class Wyniki(models.Model):
    gmina = models.ForeignKey(Gmina)
    kandydat = models.ForeignKey(Kandydat)
    liczba_glosow = models.IntegerField()

    class Meta:
        verbose_name_plural = 'wyniki'
        unique_together = ('kandydat', 'gmina')

    def __str__(self):
        return str(self.gmina.nazwa) + " " + str(self.kandydat)


    def clean(self, *args, **kwargs):
        # sprawdzenie, czy suma lcizby glosow na dwoch kandydatow nie przekracza liczby glosow oddanych
        liczba_glosow_na_drugiego_kandydata = Wyniki.objects.filter(gmina=self.gmina).aggregate(x2=Coalesce(Sum('liczba_glosow'), 0))
        glosy_oddane_w_gminie = Gmina.objects.filter(nazwa=self.gmina.nazwa, wojewodztwo=self.gmina.wojewodztwo).aggregate(x2=Coalesce(Sum('liczba_glosow_oddanych'), 0))
        if self.liczba_glosow + liczba_glosow_na_drugiego_kandydata['x2'] < glosy_oddane_w_gminie['x2'] or self.pk is not None:
            super(Wyniki, self).save(*args, **kwargs)
        else:
            raise ValidationError("Suma glosow na dwoch kandydatow nie moze przekraczac liczby oddanych glosow.")
