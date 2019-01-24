#!/usr/bin/python

from mrjob.job import MRJob

class salarymax(MRJob):

    def mapper(self, _, line):
        for salary in line.split():
            yield(salary, 1)
        
    def reducer(self, salary, value):
        yield('salary', sum(value))

if __name__ == '__main__':
    salarymax.run()
