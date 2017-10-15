from django.conf.urls import url

from . import views

urlpatterns = [
    url(r'^$', views.main, name='main'),
    url(r'^login$', views.login_method, name='login'),
    url(r'^logout$', views.logout_method, name='logout'),
    url(r'^wyniki/mapa$', views.map, name='mapa'),
    url(r'^ajax/get_votes/$', views.get_votes, name='get_votes_oddo'),
    url(r'^change_votes$', views.change_votes, name='change_votes'),
    url(r'^get_confirmation/$', views.get_confirmation, name='confirmation'),
    url(r'^kandydaci_list/$', views.kandydaci_list, name='kandydaci_list'),
    url(r'^wojewodztwa_list/$', views.wojewodztwa_list, name='wojewodztwa_list'),
    url(r'^rodzaj_list/$', views.rodzaj_list, name='rodzaj_list'),
    url(r'^wszystkie_glosy_list/$', views.wysztkie_glosy_list, name='wysztkie_glosy_list'),
    url(r'^form_post/$', views.form_post, name='form_post'),
]
