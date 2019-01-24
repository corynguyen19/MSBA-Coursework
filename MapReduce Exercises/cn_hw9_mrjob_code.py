#!/usr/bin/python

from mrjob.job import MRJob
class MRJoin(MRJob):
    def mapper(self, _, line):
        country_code = line.split('|')[-1]
        yield(country_code, line.split('|'))
    def reducer(self, key, values):
        mapvalues = [value for value in values]
        country = mapvalues[0]
        if len(mapvalues) > 1:
            for customer in mapvalues[1:]:
                yield key, [country, customer]
        else:
            customer = ['NULL','NULL','NULL']
            yield key, [country,customer]
if __name__ == '__main__':
    MRJoin.run()
