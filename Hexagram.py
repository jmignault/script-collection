#!/usr/bin/env python

import random
import itertools

class Hexagram:
    thelines = {
        6: {'moving':True,'alt':7},
        7: {'moving':False},
        8: {'moving':False},
        9: {'moving':True, 'alt':8},
    }
    
    def __init__(self):
        self.thrownlines = []
        self.movinglines = []
        self.throw()
        self.uppertrigram = self.thrownlines[0:3]
        self.lowertrigram = self.thrownlines[3:]
    
    def throw(self):
        lines = [6, 7, 8, 9]
        for _ in itertools.repeat(None, 6):
            random.seed()
            thrown = random.choice(lines)
            self.thrownlines.append(thrown)
            if self.thelines[thrown]['moving']:
                self.movinglines.append(self.thelines[thrown]['alt'])
            else:
                self.movinglines.append(thrown)
    
    def prettyprint(self):
        linetxt = {
            6:'=======X=======',
            7:'===============',
            8:'======= =======',
            9:'=======O======='}
        
        for i in reversed(self.thrownlines):
          print(linetxt[i])
        if len(self.movinglines) > 0:
          print(' ')
          for i in reversed(self.movinglines):
            print(linetxt[i])

def main():
    hg = Hexagram()
    hg.prettyprint()

if __name__ == "__main__":
    main()

