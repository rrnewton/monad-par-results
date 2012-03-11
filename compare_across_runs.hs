#!/usr/bin/env runhaskell

-- TODO -- Generalize this to take command line arguments and be configurable.

import HSH
import Control.Monad
import Text.Printf

import DatfileHelpers
import ScriptHelpers

benchs = ["blackscholes","nbody","mandel","coins","matmult/MatMult","sumeuler/sumeuler","sorting/mergesort"]

vers =   ["GHC6123","GHC704","GHC721","GHC741"]

files = 
  map ("results_data/parameter_studies/vary_ghcVer_32core_Westmere/" ++) $ 
  map (++"/results_hive.dat") vers

results = "./comparison.dat"

main = do 
  printf "Processing %d files.\n"  (length files)
  printf "Producing results file: %s\n" results

  runIO $ echo ("# benchmark "++ unwords vers++"\n") -|- catTo results

  mapM_ (putStrLn . ("   "++)) files
  forM_ benchs $ \bench -> do
    times <- forM files $ \file -> do 
	       dat <- parseDatFile file 
	       printf "   Filtering out bench %s in file %s\n" bench file
	       let hits = filter ((== bench) . name) dat
	       printf "     Got %d hits: \n" (length hits)

	       let avg = mean$ map tmed hits
	       -- For geomean we'll have to convert to "speedup" (i.e. relative to 1.0):
	 --      putStrLn$ "Geomean: " ++show(geomean$ map tmed hits)
	       putStrLn$ "   Mean: " ++show avg
               return avg

    runIO $ echo (bench++"  "++ unwords (map show times) ++"\n") -|- appendTo results
    return ()


--            foldl1
geomean ls = (foldl (*) 1 ls) 
	     ** (1 / fromIntegral (length ls))

mean ls = (sum ls) / fromIntegral (length ls)
