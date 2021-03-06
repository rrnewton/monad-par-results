

ifeq (,$(GHC))
  GHC= ghc
endif

all: plot_scaling.exe plot_ALL.exe  compare_across_runs.exe all_benchmarks_one_graph.exe 
# compare_two.exe


plot_scaling.exe: plot_scaling.hs
	$(GHC) --make plot_scaling.hs -o plot_scaling.exe

plot_ALL.exe: plot_ALL.hs
	$(GHC) --make plot_ALL.hs -o plot_ALL.exe

compare_across_runs.exe: compare_across_runs.hs
	$(GHC) --make $^ -o $@

all_benchmarks_one_graph.exe: all_benchmarks_one_graph.hs
	$(GHC) --make $^ -o $@


# Download the (bulkier) full run logs from the web:
getlogs: 
	wget ???

plot: plot_ALL.exe
	./plot_ALL.exe

deps: 
	cabal install prettyclass

wipeplots:
#	ls "*/*/*.summary" 
#	ls "*/*/*_graphs"
	find -type f -name "*.summary" -exec rm {} \;
#	find -type d -name "*_graphs" -exec rm -r "{}" \;
	find -type d -name "*_graphs" | xargs -i rm -r {} 

clean:
	rm -f *.hi *.o *.exe


