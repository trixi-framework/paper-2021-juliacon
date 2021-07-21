TARGET := paper

all:
	latexmk -halt-on-error -shell-escape -bibtex -pdf $(TARGET).tex

clean:
	rm -f $(TARGET).aux
	rm -f $(TARGET).auxlock
	rm -f $(TARGET).bbl
	rm -f $(TARGET).blg
	rm -f $(TARGET).fdb_latexmk
	rm -f $(TARGET).fls
	rm -f $(TARGET).log
	rm -f $(TARGET).nav
	rm -f $(TARGET).out
	rm -f $(TARGET).snm
	rm -f $(TARGET).toc
	rm -f $(TARGET).vrb
	rm -f $(TARGET).pdf

.PHONY: all clean
