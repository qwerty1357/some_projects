from django.test import TestCase

from django.contrib import admin

from django.db.models import Q

from datetime import datetime

from django.utils import timezone

from django.contrib.auth.models import User

from django.core.exceptions import ValidationError

from django.db import IntegrityError

from django.db import models

from .models import Kandydat, Wyniki, Wojewodztwo, Gmina

from django.contrib.auth.models import AnonymousUser, User

from django.test import TestCase, RequestFactory




class GminaTestCase(TestCase):


    def setUp(self):

        self.factory = RequestFactory()
        self.user = User.objects.create_user(
            username='jacob', email='jacob@da.ads', password='top_secret')




    def test_gmina_votes_validation(self):
        w = Wojewodztwo.objects.create(nazwa='w1')
        b = Gmina(nazwa='A', wojewodztwo=w, rodzaj='miasto', liczba_mieszkancow=10, liczba_uprawnionych=90, liczba_wydanych_kart=80, liczba_glosow_oddanych=70, uzytkownik_modyfikujacy_id=self.user.id, data_modyfikacji=timezone.now())
        self.assertRaises(ValidationError, b.clean)
        b = Gmina(nazwa='A', wojewodztwo=w, rodzaj='miasto', liczba_mieszkancow=100, liczba_uprawnionych=90, liczba_wydanych_kart=60, liczba_glosow_oddanych=70, uzytkownik_modyfikujacy_id=self.user.id, data_modyfikacji=timezone.now())
        self.assertRaises(ValidationError, b.clean)
        b = Gmina(nazwa='A', wojewodztwo=w, rodzaj='miasto', liczba_mieszkancow=100, liczba_uprawnionych=70, liczba_wydanych_kart=80, liczba_glosow_oddanych=70, uzytkownik_modyfikujacy_id=self.user.id, data_modyfikacji=timezone.now())
        self.assertRaises(ValidationError, b.clean)



class KandydatTestCase(TestCase):


    def test_more_than_2_candidates(self):
        k1 = Kandydat.objects.create(nazwa="K1")
        k2 = Kandydat.objects.create(nazwa="K2")
        numb = Kandydat.objects.all().count()
        self.assertTrue(numb == 2)
        k3 = Kandydat(nazwa="K3")
        self.assertRaises(ValidationError, k3.clean)




class WynikiTestCase(TestCase):

    def setUp(self):

        self.factory = RequestFactory()
        self.user = User.objects.create_user(
            username='jacob', email='jacob@da.ads', password='top_secret')


    def test_wyniki_add_wrong_votes_number(self):
        w = Wojewodztwo.objects.create(nazwa='w1')
        a = Gmina.objects.create(nazwa='A', wojewodztwo=w, rodzaj='miasto', liczba_mieszkancow=100, liczba_uprawnionych=90, liczba_wydanych_kart=80, liczba_glosow_oddanych=70, uzytkownik_modyfikujacy_id=self.user.id, data_modyfikacji=timezone.now())
        k1 = Kandydat.objects.create(nazwa="K1")
        k2 = Kandydat.objects.create(nazwa="K2")
        wyniki1 = Wyniki.objects.create(gmina=a, kandydat=k1, liczba_glosow=60)
        wyniki2 = Wyniki(gmina=a, kandydat=k2, liczba_glosow=20)
        self.assertRaises(ValidationError, wyniki2.clean)


    def test_wyniki_same_creation(self):
        w = Wojewodztwo.objects.create(nazwa='w1')
        a = Gmina.objects.create(nazwa='A', wojewodztwo=w, rodzaj='miasto', liczba_mieszkancow=100, liczba_uprawnionych=90, liczba_wydanych_kart=80, liczba_glosow_oddanych=70, uzytkownik_modyfikujacy_id=self.user.id, data_modyfikacji=timezone.now())
        k1 = Kandydat.objects.create(nazwa="K1")
        k2 = Kandydat.objects.create(nazwa="K2")
        wyniki1 = Wyniki.objects.create(gmina=a, kandydat=k1, liczba_glosow=60)
        wyniki2 = Wyniki(gmina=a, kandydat=k1, liczba_glosow=5)
        self.assertRaises(IntegrityError, wyniki2.clean)
