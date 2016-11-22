#!/usr/bin/env python
# coding=utf-8
import sys
import json
import requests
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
    thread_number = 2
    networkerror = "ERROR 503: Service Unavailable."
    base_url = 'https://scihub.copernicus.eu/dhus/'

    def __init__(self, configfilename):
        self.params, self.configs = self.params_wrapper(configfilename)

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
            'footprint': '"Intersects(POLYGON({}))"',
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
            if k == 'beginPosition':
                params['beginPosition'] = params['beginPosition'].format(raw_params['startdate'], raw_params['enddate'])
            elif k == 'endPosition':
                params['endPosition'] = params['endPosition'].format(raw_params['startdate'], raw_params['enddate'])
            else:
                params[k] = params[k].format(raw_params[k])

        for k in configs.keys():
            configs[k] = configs[k].format(raw_params[k])

        return params, configs

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
            limit += '&rows='+nrows
        if starts:
            limit += '&start='+starts 

        # make main query
        for k, v in params.items():
            if v:
                query += ' AND ' + k +':' + v

        return self.base_url + query + limit

    def make_download(self, product):
        pass

    def send_request(self, query_url):
        response = requests.get(query_url, auth=(self.configs['username'], self.configs['password']), verify=False)
        return response

    def downloader(self, name, url):
        dir = self.configs["outputdirectory"] + name
        response = requests.get(url, auth=(self.configs['username'], self.configs['password']), stream=True, verify=False)
        with open(dir, 'wb') as f:
            for chunk in response.iter_content(chunk_size=1024): 
                if chunk: # filter out keep-alive new chunks
                    f.write(chunk)

    def parse_response(self, response):
        bs_resp = BeautifulSoup(response)
        products = {x.title.string: x.link.get('href') for x in bs_resp.find_all('entry')}
        return products

    def run(self):
        query_url = self.make_query(self.params)
        response = self.send_request(query_url)
        # TODO: raise response exception
        if response // 100 != 2:
            raise
        
        # Download this batch
        products = self.parse_response(response)
        for name, url in products:
            self.downloader(name, url)

        # TODO: MD5 checking, is it necessary?

        return


def main(config):
    pass


if __name__ == '__main__':
    try:
        config = sys.argv[1]
    except Exception as e:
        config = '../config/config.json'
        print e
    main(config)
