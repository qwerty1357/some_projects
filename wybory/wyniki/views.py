from django.shortcuts import render, redirect, HttpResponseRedirect

from .models import Kandydat, Wyniki, Wojewodztwo, Gmina

from django.db.models import Sum

from django.db.models.functions import Coalesce

from django.contrib.auth import logout, authenticate, login

from django.contrib.auth.decorators import login_required

from django.views.decorators.csrf import csrf_protect

from django.contrib import messages

from django.http import JsonResponse

from django.core.exceptions import ValidationError

from .forms import ModifyResultsForm

import json

from rest_framework.decorators import api_view
from rest_framework.views import APIView
from rest_framework import serializers
from rest_framework.renderers import JSONRenderer




@api_view(['POST'])
def form_post(request):

    if request.method == 'POST':
        form = ModifyResultsForm(request.POST)
        if form.is_valid():
            old1 = form.cleaned_data['kandydat1_old']
            old2 = form.cleaned_data['kandydat2_old']
            k = Kandydat.objects.all()
            nazwa = form.cleaned_data['nazwa']
            new1 = Wyniki.objects.filter(gmina__nazwa=nazwa, kandydat__nazwa=k[0])[0].liczba_glosow
            new2 = Wyniki.objects.filter(gmina__nazwa=nazwa, kandydat__nazwa=k[1])[0].liczba_glosow
            if ((old1 == new1) and (old2 == new2)):
                form.save(request.user)
                print('valid!')
                return JsonResponse({'status' : 'ok'})
            else:
                user_m = Gmina.objects.filter(nazwa=nazwa)[0].uzytkownik_modyfikujacy.get_username()
                data_m = Gmina.objects.filter(nazwa=nazwa)[0].data_modyfikacji
                return JsonResponse({'status' : 'change', 'new1' : new1, 'new2' : new2, 'user_m' : user_m, 'data_m' : data_m})
        else:
            print('not valid :(')
            return JsonResponse({'status' : 'not ok'})

    else:
        form = ModifyResultsForm()



@api_view(['GET'])
def kandydaci_list(request):

    response = {}

    if request.method == 'GET':

        kandydaci = Kandydat.objects.all()

        kandydat1 = kandydaci[0]
        kandydat2 = kandydaci[1]

        response = {  'kandydaci' : [ {'kandydat1' : kandydat1.nazwa}, {'kandydat2' : kandydat2.nazwa} ] }

    return JsonResponse(response)




@api_view(['GET'])
def wojewodztwa_list(request):

    response = {}

    if request.method == 'GET':

        l = prepare_wojewodztwa()

        response = { 'wojewodztwa' : l }

    return JsonResponse(response)




@api_view(['GET'])
def rodzaj_list(request):

    response = {}

    if request.method == 'GET':

        r = prepare_rodzaj()

        response = { 'rodzaj' : r }

    return JsonResponse(response)




@api_view(['GET'])
def wysztkie_glosy_list(request):

    response = {}

    if request.method == 'GET':

        all_votes = count_all_votes()

        response = { 'wszystkie_glosy' : all_votes }

    return JsonResponse(response)




def main(request):

    return render(request, 'wyniki/main.html')




def map(request):

    kandydaci = Kandydat.objects.all()

    kandydat1 = kandydaci[0]
    kandydat2 = kandydaci[1]

    l = prepare_wojewodztwa()
    return render(request, 'wyniki/test.html', {'woj' : l, 'k1' : kandydat1, 'k2' : kandydat2})




def login_method(request):
    username = request.POST['username']
    password = request.POST['password']
    user = authenticate(username = username, password = password)
    if user is not None:
        if user.is_active:
            login(request, user)
        else:
            messages.error(request, 'Konto zablokowane')
    else:
        messages.error(request, 'Zle haslo')
    return HttpResponseRedirect('.')




@login_required
def logout_method(request):
    logout(request)
    return HttpResponseRedirect('.')




def get_votes(request):

    l = []
    desc = {}

    req = request.GET.get('req')

    if req == 'oddo':
        od = request.GET.get('od')
        do = request.GET.get('do')
        if od is None or do is None:
            return JsonResponse(l, safe=False)
        gminy = Gmina.objects.filter(liczba_mieszkancow__lte=do, liczba_mieszkancow__gte=od)

    elif req == 'rodzaj':
        typ = request.GET.get('status')
        gminy = Gmina.objects.filter(rodzaj=typ)

    elif req == 'wojewodztwo':
        woj = request.GET.get('wojewodztwo')
        gminy = Gmina.objects.filter(wojewodztwo__nazwa=woj)

    else:
        raise ValidationError('niepoprawne zapytanie!')

    kandydaci = Kandydat.objects.all()

    for g in gminy:
        r1 = Wyniki.objects.filter(gmina__nazwa=g.nazwa, kandydat__nazwa=kandydaci[0]).aggregate(x1=Coalesce(Sum('liczba_glosow'), 0))
        r2 = Wyniki.objects.filter(gmina__nazwa=g.nazwa, kandydat__nazwa=kandydaci[1]).aggregate(x2=Coalesce(Sum('liczba_glosow'), 0))
        result1_pr = percent(r1['x1'], r2['x2'])
        result2_pr = percent(r2['x2'], r1['x1'])
        desc = {'nazwa' : g.nazwa, 'result1' : r1['x1'], 'result2' : r2['x2'], 'sum' : r1['x1'] + r2['x2'], 'pr1' : result1_pr, 'pr2' : result2_pr}
        l.append(desc);

    return JsonResponse(l, safe=False)




def percent(a, b):
    if a == 0:
        return 0
    percent = "%0.2f" % (100 * a /float(a + b))
    return percent




def change_votes(request):

    if request.method == 'POST':

        form = ModifyResultsForm(request.POST)
        if form.is_valid():

            print('field; ' + str(form.cleaned_data['nazwa']))
            form.save(request.user)
            print('valid!')
        else:
            print('not valid :(')

        return HttpResponseRedirect('.')
        #return JsonResponse({'status' : 'ok'})

    else:
        form = ModifyResultsForm()

    #return redirect(main)




def get_confirmation(request):

    l = []
    desc = {}

    req = request.GET.get('gmina')

    gm = Gmina.objects.get(nazwa=req)

    uzytkownik = gm.uzytkownik_modyfikujacy.get_username()
    data = gm.data_modyfikacji

    desc = {'user' : uzytkownik, 'date' : data}
    l.append(desc)

    return JsonResponse(l, safe=False)




def prepare_wojewodztwa():
    l = []
    desc = {}
    wojewodztwa = Wojewodztwo.objects.all()
    kandydaci = Kandydat.objects.all()

    for w in wojewodztwa:
        wn1 = Wyniki.objects.filter(gmina__wojewodztwo=w, kandydat__nazwa=kandydaci[0]).aggregate(x1=Coalesce(Sum('liczba_glosow'), 0))
        wn2 = Wyniki.objects.filter(gmina__wojewodztwo=w, kandydat__nazwa=kandydaci[1]).aggregate(x2=Coalesce(Sum('liczba_glosow'), 0))
        result1_pr = percent(wn1['x1'], wn2['x2'])
        result2_pr = percent(wn2['x2'], wn1['x1'])
        desc = {'wojewodztwo' : w.nazwa, 'result1' : wn1['x1'], 'result2' : wn2['x2'], 'sum' : wn1['x1'] + wn2['x2'], 'pr1' : result1_pr, 'pr2' : result2_pr}
        l.append(desc)

    return l




def prepare_rodzaj():
    l = []
    desc = {}
    kandydaci = Kandydat.objects.all()
    types = ['statek', 'wies', 'miasto', 'zagranica']

    for t in types:
        wn1 = Wyniki.objects.filter(gmina__rodzaj=t, kandydat__nazwa=kandydaci[0]).aggregate(x1=Coalesce(Sum('liczba_glosow'), 0))
        wn2 = Wyniki.objects.filter(gmina__rodzaj=t, kandydat__nazwa=kandydaci[1]).aggregate(x2=Coalesce(Sum('liczba_glosow'), 0))
        result1_pr = percent(wn1['x1'], wn2['x2'])
        result2_pr = percent(wn2['x2'], wn1['x1'])
        desc = {'typ' : t, 'result1' : wn1['x1'], 'result2' : wn2['x2'], 'sum' : wn1['x1'] + wn2['x2'], 'pr1' : result1_pr, 'pr2' : result2_pr}
        l.append(desc)

    return l




def count_all_votes():
    desc = []
    kandydaci = Kandydat.objects.all()
    wyniki = Wyniki.objects.all()
    r1 = Wyniki.objects.filter(kandydat__nazwa=kandydaci[0]).aggregate(x1=Coalesce(Sum('liczba_glosow'), 0))
    r2 = Wyniki.objects.filter(kandydat__nazwa=kandydaci[1]).aggregate(x2=Coalesce(Sum('liczba_glosow'), 0))
    result1_pr = percent(r1['x1'], r2['x2'])
    result2_pr = percent(r2['x2'], r1['x1'])
    desc = {'result1' : r1['x1'], 'result2' : r2['x2'], 'pr1' : result1_pr, 'pr2' : result2_pr}

    return desc
