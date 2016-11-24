#!/usr/bin/env python
# coding=utf-8
import sys
import json
import requests
import os
import time
import zipfile
import hashlib
from bs4 import BeautifulSoup
import pdb

"""
Workflow in this downloader:
    parse parameter input files
    with a while loop:
        query per customer parameters
        extract url addrs per candidate files
        download files
"""

class Downloader(object):
    base_url = 'https://scihub.copernicus.eu/dhus/'
    countries_geojson_filename = os.path.dirname(os.path.realpath(__file__)) + '/countries.geo.json'

    def __init__(self, configfilename):
        self.params, self.configs = self.params_wrapper(configfilename)
        # create repo if not exists
        self._create_repo(self.configs.get('outputdirectory', None))

    def _create_repo(self, dirpath):
        if not dirpath:
            print dirpath, 'not valid, or not specified in config file'
            raise
        if not os.path.exists(dirpath):
            os.makedirs(dirpath)
        return True

    def params_wrapper(self, configfilename='../config/config.json'):
        """
        : wrap raw parameters into api acceptable ones
        : configfilename: str, indicating the path to configuration json file
        : return a wrapped dictionary for acceptable parameters
        """
        raw_params = self.make_json(configfilename)
        # return an empty parameter dictionary
        params = {
            'platformname': '{}',
            'footprint': '"Intersects(POLYGON(({})))"',
            'beginPosition': '[{} TO {}]',
            'endPosition': '[{} TO {}]',
            'producttype': '{}',
            'polarisationmode': '{}',
            # IW
            'sensoroperationalmode': '{}',
            # resolution depreciated
            #'RESOLU':'{}',
            'orbitdirection': '{}'
        }

        configs = {
            'username': '{}',
            'password': '{}',
            'outputdirectory': '{}',
        }

        # start end date shall be formatted separately
        for k in params.keys():
            try:
                if k == 'beginPosition':
                    params['beginPosition'] = params['beginPosition'].format(raw_params['startdate'], raw_params['enddate'])
                elif k == 'endPosition':
                    params['endPosition'] = params['endPosition'].format(raw_params['startdate'], raw_params['enddate'])
                elif k == 'footprint':
                    if raw_params.get(k, None):
                        print 'Err: footprint is suppose to be depreciated in dsen, please use country code'
                        sys.exit(1)
                    # new feature, use geo.json file to parse coordinates
                    params['footprint'] = params['footprint'].format(self.extract_from_geojson(raw_params['countrycode']))
                else:
                    # footprint int raw config is depreciated
                    params[k] = params[k].format(raw_params[k])
            except KeyError:
                print 'KeyError', k, 'while parsing params'
                print 'Exiting...'
                sys.exit(1)

        for k in configs.keys():
            try:
                configs[k] = configs[k].format(raw_params[k])
            except KeyError:
                print 'KeyError', k, 'while parsing configs'
                print 'Exiting...'
                sys.exit(1)

        return params, configs

    def extract_from_geojson(self, code):
        # TODO 
        countries_geojson = self.make_json(self.countries_geojson_filename)
        formatted = None
        try:
            formatted = ','.join(['%.7f %.7f' % tuple(coord) for coord in 
                                  [c['geometry']['coordinates'] for c in 
                                    countries_geojson['features'] if c['id'] == code][0][0]
                                 ])
        except (KeyError, IndexError) as e:
            print e, 'while extracting geojson, Please revise ...', code
            # simple fussy suggestion, can use trie instead
            print 'Maybe you are seeking...:'
            possiblecountries = [ c['id'] for c in countries_geojson['features'] if c['id'].startswith(code[:1]) ]
            for c in possiblecountries:
                print c
            print 'Exiting...'
            sys.exit(1)
        return formatted

    def make_json(self, configfilename):
        res_json = None
        with open(configfilename) as f:
            res_json = json.load(f)

        return res_json

    def make_query(self, params, starts=None, nrows=None):
        query = 'search?q=*'

        # limit query making
        limit = ''
        if nrows:
            limit += '&rows='+str(nrows)
        if starts:
            limit += '&start='+str(starts)

        # make main query
        for k, v in params.items():
            if v:
                query += ' AND ' + str(k) +':' + str(v)

        return self.base_url + query + limit

    def send_request(self, query_url):
        response = requests.get(query_url, auth=(self.configs['username'], self.configs['password']), verify=False)
        while response.status_code // 100 == 5:
            print "Datahub Service Down, Wait 5 min"
            time.sleep(300)
            response = requests.get(query_url, auth=(self.configs['username'], self.configs['password']), verify=False)
        return response

    def downloader(self, name, url):
        failed = True
        dir = self.configs["outputdirectory"] + name
        md5_val = self.query_md5(url)
        # if already exists
        if os.path.isfile(dir):
            # if valid file
            if not self.check_novalid(dir, md5_val):
                print name, "has already downloaded, skip"
                return not failed
            else:
                print name, " is corrupted, remove"
                os.remove(dir)
        # else
        print "Downloading " + name + " to " + dir
        try:
            response = requests.get(url, auth=(self.configs['username'], self.configs['password']), stream=True, verify=False)
            with open(dir, 'wb') as f:
                for chunk in response.iter_content(chunk_size=1024): 
                    if chunk: # filter out keep-alive new chunks
                        f.write(chunk)
            print "Downloaded " + name
        except KeyboardInterrupt:
            print "\nKeyboard interruption, remove current download and exit execution of script", name
            os.remove(dir)
            sys.exit(0)

        failed = self.check_novalid(dir, md5_val)
        return failed

    def check_novalid(self, path, md5_val):
        """
        :check:
        : 1. size is good -- note! this is not possible, strange hmmm...
        : 2. md5 checksum is good
        :return True if not valid, False else
        """
        return not( os.path.exists(path) and zipfile.is_zipfile(path) and self.md5_compare(path, md5_val))

    def md5_compare(self, file_path, checksum, block_size=2 ** 13):
        """Compare a given md5 checksum with one calculated from a file"""
        md5 = hashlib.md5()
        try:
            with open(file_path, "rb") as f:
                #progress = tqdm(desc="MD5 checksumming", total=os.path.getsize(file_path), unit="B", unit_scale=True)
                while True:
                    block_data = f.read(block_size)
                    if not block_data:
                        break
                    md5.update(block_data)
                    #progress.update(len(block_data))
                #progress.close()
        except (IOError, TypeError) as e:
            print file_path, "is not valid filepath for md5_compare"

        return md5.hexdigest().lower() == checksum.lower()

    def parse_response(self, response):
        bs_resp = BeautifulSoup(response.text)
        products = {x.title.string: {'url': x.link.get('href')} 
                    for x in bs_resp.find_all('entry')}
        return products

    def query_md5(self, d_link):
        """
        query to API for extracting corresponding md5 value
        cause download entry and description entry is different
        first_one = second_one + '/value balabala...'
        """
        query_link = None
        try:
            query_link = '/'.join(d_link.split('/')[:-1])
        except IndexError:
            print d_link, "is not parsable"
            return None

        #print "Getting MD5 from", query_link
        response = self.send_request(query_link)
        md5_val = BeautifulSoup(BeautifulSoup(response.text).entry.get_text()).hash.string
        if not md5_val:
            print "MD5 Retrieval Failed", d_link
        else:
            print "MD5 Retrieval Succeeded", d_link, md5_val

        return md5_val

    def run_one_batch(self, starts, nrows):
        suffix = '.zip'
        query_url = self.make_query(self.params, starts, nrows)

        # wait if website down, status_code 5XX
        response = self.send_request(query_url)

        if response.status_code // 100 != 2:
            raise
        
        # Download this batch
        products = self.parse_response(response)
        if not products:
            return True

        for name, attributes in products.items():
            failed = True
            while failed:
                falied = self.downloader(name + suffix, attributes['url'])
                time.sleep(1)

        return False

    def run_all(self):
        start = 0,
        nrows = 100
        while self.run_one_batch(start, nrows):
            start += nrows


def main(config):
    d = Downloader(config)
    d.run_all()


if __name__ == '__main__':
    try:
        config = sys.argv[1]
    except IndexError as e:
        config = '../config/config.json'
        print "config file not specified, use default config.json"
    main(config)
