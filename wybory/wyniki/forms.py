from django import forms

from django.db import transaction

from django.utils import timezone

from wyniki import models

from .models import Kandydat, Wyniki, Wojewodztwo, Gmina

from django.contrib.auth.models import User


class ModifyResultsForm(forms.Form):

    print('jestem w formsie')

    nazwa = forms.CharField(max_length=100)
    kandydat1 = forms.IntegerField()
    kandydat2 = forms.IntegerField()
    kandydat1_old = forms.IntegerField()
    kandydat2_old = forms.IntegerField()


    @transaction.atomic
    def save(self, user):
        gm = Gmina.objects.get(nazwa=self.cleaned_data['nazwa'])
        kandydaci = Kandydat.objects.all()

        print(self.cleaned_data['kandydat1_old'])
        print(self.cleaned_data['kandydat2_old'])

        if gm is not None:
            w1 = self.cleaned_data['kandydat1']
            w2 = self.cleaned_data['kandydat2']
            try:
                val1 = int(w1)
                val2 = int(w2)
                if val1 + val2 > gm.liczba_glosow_oddanych:
                    print("za dużo")
                else:
                    if val1 < 0 or val2 < 0:
                        print("Sorry, input must be a positive integer, try again")
                    else:
                        to_save1 = Wyniki.objects.filter(gmina=gm, kandydat=kandydaci[0])
                        to_save1.update(liczba_glosow=w1)

                        to_save2 = Wyniki.objects.filter(gmina=gm, kandydat=kandydaci[1])
                        to_save2.update(liczba_glosow=w2)

                        to_update =  Gmina.objects.select_for_update().filter(id=gm.id).update(uzytkownik_modyfikujacy=user, data_modyfikacji=timezone.now())

            except ValueError:
                print("That's not an int!")
