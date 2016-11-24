#!/usr/bin/env python
# coding=utf-8

import unittest
import zipfile
import json
import pdb
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
        


if __name__ == '__main__':
    suite = unittest.TestSuite()
    suite.addTest(Tests('testValidityChecker'))
    runner = unittest.TextTestRunner()
    runner.run(suite)
        
