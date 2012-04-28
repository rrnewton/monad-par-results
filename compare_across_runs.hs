#!/usr/bin/env runhaskell
{-# LANGUAGE RecordWildCards #-}

-- TODO -- Generalize this to take command line arguments and be configurable.

import HSH
import Control.Monad
import Text.Printf

import DatfileHelpers
import ScriptHelpers

benchs = ["blackscholes","nbody","mandel","coins","matmult/MatMult","sumeuler/sumeuler","sorting/mergesort"]

-- vers =   ["GHC6123","GHC704","GHC721","GHC741"]
vers =   ["GHC6123","GHC704","GHC721","GHC741","GHC741_noCAS"]

files = 
  map ("results_data/parameter_studies/vary_ghcVer_32core_Westmere/" ++) $ 
  map (++"/results_hive.dat") vers

results = "./comparison.dat"

-- This file will contain rotated data where the scheduler has been replaced by GHC version:
-- It's a valid .dat file for input to plot_scaling:
rotated = "./rotated.dat"


main = do 
  printf "Processing %d files.\n"  (length files)
  printf "Producing results file: %s\n" results

  runIO $ echo ("# benchmark "++ unwords vers++"\n") -|- catTo results
  runIO $ echo ("# TestName Variant Scheduler NumThreads   MinTime MedianTime MaxTime  Productivity1 Productivity2 Productivity3\n")
   -- sorting/mergesort    cpu_24_8192          Sparks  16   2.693111 2.710449 2.765516   80.160 80.022 79.535
           -|- catTo rotated

  mapM_ (putStrLn . ("   "++)) files
  forM_ benchs $ \bench -> do
    times <- forM (zip vers files) $ \(ver,file) -> do 
	       dat <- parseDatFile file 
	       printf "   Filtering out bench %s in file %s\n" bench file
               -- Doing JUST trace for now:
	       let hits = filter ((== bench) . name)    $
--			  filter ((== "Trace") . sched) $
			  filter ((== "Direct") . sched) $
			  dat
	       printf "     Got %d hits: \n" (length hits)

	       let avg = mean$ map tmed hits
	       -- For geomean we'll have to convert to "speedup" (i.e. relative to 1.0):
	 --      putStrLn$ "Geomean: " ++show(geomean$ map tmed hits)
	       putStrLn$ "   Mean: " ++show avg

               forM_ hits $ \ Entry{..} -> do
                  runIO$ echo (printf "%s %s %s %d   %3f %3f %3f  %s \n" 
			       name variant ver threads tmin tmed tmax 
			       (case productivities of 
				  Nothing -> ""
				  Just (prod1,prod2,prod3) -> 
				       (printf "%3f %3f %3f " prod1 prod2 prod3)
			        ):: String)
                         -|- appendTo rotated

               return avg

    runIO $ echo (bench++"  "++ unwords (map show times) ++"\n") -|- appendTo results
    return ()


--            foldl1
geomean ls = (foldl (*) 1 ls) 
	     ** (1 / fromIntegral (length ls))

mean ls = (sum ls) / fromIntegral (length ls)
