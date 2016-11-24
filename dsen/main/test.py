#!/usr/bin/env python
# coding=utf-8

import unittest
import zipfile
import json
import pdb
import StringIO
from dsen import Downloader
from bs4 import BeautifulSoup


class Tests(unittest.TestCase):
    config = 'tests/testconfig.json'

    def testAddInfo(self, d, filename):
        info = None
        with open('/tmp/test_account_token') as f:
            info = f.readline().rstrip('\n').split(',')

        for i, k in enumerate(['username', 'password']):
            d.configs[k] = info[i]

        for i, k in enumerate(['username', 'password']):
            self.assertEqual(d.configs[k], info[i])

    def testQueryUrl(self):
        target = 'https://scihub.copernicus.eu/dhus/search?q=* AND platformname:Sentinel-1 AND footprint:"Intersects(POLYGON((-3.3368297113536087 4.394202020378941,1.4284107877773324 4.394202020378941,1.4284107877773324 11.110218557903721,-3.3368297113536087 11.110218557903721,-3.3368297113536087 4.394202020378941)))" AND beginPosition:[2016-01-01T00:00:00.000Z TO 2016-03-31T23:59:59.999Z] AND endPosition:[2016-01-01T00:00:00.000Z TO 2016-03-31T23:59:59.999Z] AND producttype:GRD AND sensoroperationalmode:IW'
        d = Downloader(self.config)
        query = d.make_query(d.params)

        target_list = target.split(' AND ')
        target_list.sort()
        query_list = query.split(' AND ')
        query_list.sort()

        self.assertEqual(len(target_list), len(query_list))
        for i in range(len(target_list)):
            self.assertEqual(target_list[i], query_list[i])

    def testNotWorkingResponse(self):
        d = Downloader(self.config)
        query = d.make_query(d.params)
        response = d.send_request(query)

        self.assertEqual(str(response.status_code), '401')

    def testWorkingResponse(self):
        d = Downloader(self.config)

        self.testAddInfo(d, '/tmp/create_test_account')
        self.assertTrue('emmanuelshs', d.configs['username'])

        query = d.make_query(d.params)
        response = d.send_request(query)

        self.assertTrue(response)

    """
    def testQueryExtraction(self):
        d = Downloader(self.config)
        self.testAddInfo(d, '/tmp/create_test_account')

        query = d.make_query(d.params)
        response = d.send_request(query)
        res = {}
        products = d.parse_response(response.text)
        
        for k, v in d.items():
            pass
    """

    def testDownloader(self):
        d = Downloader(self.config)
        self.testAddInfo(d, '/tmp/create_test_account')

        query = d.make_query(d.params)
        response = d.send_request(query)
        products = d.parse_response(response.text)

        resname = None
        for name, attributes in products.items():
            print name, attributes
            resname = name
            #failed = d.downloader(name + '.zip', attributes['url'], attributes['md5'], attributes['size'])
            failed = d.check_novalid(d.configs['outputdirectory'] + name + '.zip', attributes['md5'], attributes['size'])
            self.assertTrue(not failed)
            break

        self.assertTrue(zipfile.is_zipfile(d.configs['outputdirectory'] + resname))

    def testValidityChecker(self):
        d = Downloader(self.config)
        self.testAddInfo(d, '/tmp/create_test_account')
        filepath = d.configs['outputdirectory'] + 'S1A_IW_GRDH_1SDV_20160202T180933_20160202T181002_009771_00E48D_FDDD.zip'
        checksum = '9CF34B49AFA4CB15866F02DFA6E2C0E3'

        # exists case
        md5 = d.md5_compare(filepath, checksum)
        self.assertTrue(md5)

        novalid = d.check_novalid(filepath, checksum, 1234)
        self.assertTrue(not novalid)

        # not exists case
        self.assertFalse(d.md5_compare(d.configs['outputdirectory'] + 'balabala', checksum))
        self.assertFalse(d.md5_compare(filepath, ''))
        self.assertFalse(d.md5_compare(d.configs, checksum))

        self.assertTrue(d.check_novalid(filepath + 'balabala', checksum, ''))
        self.assertTrue(d.check_novalid(d.configs['outputdirectory'], checksum, ''))
        
    def testGeoJsonExtraction(self):
        d = Downloader('tests/countryconfig.json')
        footprint = d.params.get('footprint', None)
        res = '"Intersects(POLYGON((33.9037110 -0.9500000,34.0726200 -1.0598200,37.6986900 -3.0969900,37.7669000 -3.6771200,39.2022200 -4.6767700,38.7405400 -5.9089500,38.7997700 -6.4756600,39.4400000 -6.8400000,39.4700000 -7.1000000,39.1946900 -7.7039000,39.2520300 -8.0078100,39.1865200 -8.4855100,39.5357400 -9.1123700,39.9496000 -10.0984000,40.3165900 -10.3171000,39.5210000 -10.8968800,38.4275570 -11.2852020,37.8276400 -11.2687900,37.4712900 -11.5687600,36.7751510 -11.5945370,36.5140820 -11.7209380,35.3123980 -11.4391460,34.5599890 -11.5200200,34.2800000 -10.1600000,33.9408380 -9.6936740,33.7397200 -9.4171500,32.7593750 -9.2305990,32.1918650 -8.9303590,31.5563480 -8.7620490,31.1577510 -8.5945790,30.7400000 -8.3400000,30.2000000 -7.0800000,29.6200000 -6.5200000,29.4199930 -5.9399990,29.5199870 -5.4199790,29.3399980 -4.4999830,29.7535120 -4.4523890,30.1163200 -4.0901200,30.5055400 -3.5685800,30.7522400 -3.3593100,30.7430100 -3.0343100,30.5276600 -2.8076200,30.4696700 -2.4138300,30.7583090 -2.2872500,30.8161350 -1.6989140,30.4191050 -1.1346590,30.7698600 -1.0145500,31.8661700 -1.0273600,33.9037110 -0.9500000)))"'
        # correct answer
        self.assertEqual(res, footprint)

        # wrong input test
        wrongcode = 'meaningless'
        with self.assertRaises(SystemExit) as ec:
            d.extract_from_geojson(wrongcode)

        self.assertEqual(ec.exception.code, 1)

        # test fussy suggestion
        fussycode = 'TZ'
        with self.assertRaises(SystemExit) as ec:
            d.extract_from_geojson(fussycode)

        self.assertEqual(ec.exception.code, 1)


if __name__ == '__main__':
    suite = unittest.TestSuite()
    suite.addTest(Tests('testGeoJsonExtraction'))
    runner = unittest.TextTestRunner()
    runner.run(suite)
        
