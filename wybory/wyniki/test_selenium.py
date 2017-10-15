from selenium import webdriver
import time
from django.contrib.staticfiles.testing import StaticLiveServerTestCase
import unittest
from selenium.webdriver.common.alert import Alert
from selenium.common.exceptions import NoSuchElementException


class seleniumTest(StaticLiveServerTestCase):

    def test_login(self):

        time.sleep(2)
        ad = 'admin'
        pw = 'mimuwmimuw'

        driver = webdriver.Chrome()
        driver.get("http://127.0.0.1:8000")

        driver2 = webdriver.Chrome()
        driver2.get("http://127.0.0.1:8000")

        driver.find_element_by_id("login-input").send_keys(ad)
        driver.find_element_by_id("pass-input").send_keys(pw)
        driver.find_element_by_id("logowanie-sie").click()

        assert driver.find_element_by_id("isAuthenticated") is not None


        driver2.find_element_by_id("login-input").send_keys(ad)
        driver2.find_element_by_id("pass-input").send_keys(pw)
        driver2.find_element_by_id("logowanie-sie").click()

        assert driver2.find_element_by_id("isAuthenticated") is not None

        driver.quit()
        driver2.quit()



    def test_open_close_modal(self):

        ad = 'admin'
        pw = 'mimuwmimuw'

        driver = webdriver.Chrome()
        driver.get("http://127.0.0.1:8000")

        driver.find_element_by_id("login-input").send_keys(ad)
        driver.find_element_by_id("pass-input").send_keys(pw)
        driver.find_element_by_id("logowanie-sie").click()

        assert driver.find_element_by_id("isAuthenticated") is not None

        time.sleep(0.1)


        element = driver.find_element_by_id('mazowieckie')
        element.click()

        assert element.is_displayed()

        time.sleep(0.1)

        element = driver.find_element_by_id('zamknij-modal')
        element.click()

        time.sleep(0.1)

        assert not element.is_displayed()

        time.sleep(0.1)

        driver.quit()




    def test_change_votes(self):

        ad = 'admin'
        pw = 'mimuwmimuw'

        driver = webdriver.Chrome()
        driver.get("http://127.0.0.1:8000")

        driver.find_element_by_id("login-input").send_keys(ad)
        driver.find_element_by_id("pass-input").send_keys(pw)
        driver.find_element_by_id("logowanie-sie").click()

        assert driver.find_element_by_id("isAuthenticated") is not None

        time.sleep(0.1)


        element = driver.find_element_by_id('mazowieckie')
        element.click()

        assert element.is_displayed()

        time.sleep(0.1)
        element1 = driver.find_element_by_id('drugi').send_keys(2)
        element2 = driver.find_element_by_id('trzeci').send_keys(3)

        element = driver.find_element_by_id('czwarty')
        element.click()

        time.sleep(0.2)

        assert not element.is_displayed()

        time.sleep(0.2)

        element1 = driver.find_element_by_id('Zielonka1').get_attribute("innerHTML")
        assert element1 == '2'

        time.sleep(0.2)

        element2 = driver.find_element_by_id('Zielonka2').get_attribute("innerHTML")
        assert element2 == '3'

        driver.quit()
